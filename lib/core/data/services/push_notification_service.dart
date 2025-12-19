import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/services/logger_service.dart';

/// FCM 푸시 알림 서비스
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  factory PushNotificationService() => _instance;

  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    app: Firebase.app(),
  );

  String? _fcmToken;
  GoRouter? _router;
  String? _currentUserId;
  Timer? _apnsTokenCheckTimer;

  String? get fcmToken => _fcmToken;

  /// GoRouter 설정 (네비게이션을 위해 필요)
  void setRouter(GoRouter router) {
    _router = router;
  }

  /// FCM 초기화
  Future<void> initialize() async {
    try {
      // 알림 권한 요청
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      AppLogger.notification('알림 권한 상태: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // iOS에서는 APNS 토큰을 먼저 설정해야 함
        bool apnsTokenReady = true;
        if (Platform.isIOS) {
          try {
            AppLogger.notification('iOS APNS 토큰 가져오기 시도...');
            final apnsToken = await _messaging.getAPNSToken();
            if (apnsToken != null) {
              AppLogger.notification('APNS 토큰 가져오기 성공: $apnsToken');
              apnsTokenReady = true;
            } else {
              AppLogger.warning('APNS 토큰이 아직 준비되지 않았습니다. 나중에 자동으로 설정됩니다.');
              apnsTokenReady = false;
              // APNS 토큰이 없으면 FCM 토큰을 가져올 수 없음
            }
          } catch (e) {
            AppLogger.warning('APNS 토큰 가져오기 실패 (나중에 자동으로 설정됨): $e');
            apnsTokenReady = false;
          }
        }

        // APNS 토큰이 준비된 경우에만 FCM 토큰 가져오기 시도
        if (apnsTokenReady) {
          try {
            // FCM 토큰 가져오기
            AppLogger.notification('FCM 토큰 가져오기 시도...');
            _fcmToken = await _messaging.getToken();
            AppLogger.notification('FCM 토큰 가져오기 성공: $_fcmToken');
            // 토큰을 가져온 후 현재 사용자가 있으면 자동으로 저장
            if (_fcmToken != null && _currentUserId != null) {
              await _saveTokenToFirestore(_currentUserId!);
            }
          } catch (e, stackTrace) {
            AppLogger.error('FCM 토큰 가져오기 실패: $e', e, stackTrace);
            // iOS에서 APNS 토큰이 없으면 FCM 토큰도 가져올 수 없음
            if (Platform.isIOS) {
              if (e.toString().contains('apns-token-not-set')) {
                AppLogger.warning(
                  'APNS 토큰이 아직 준비되지 않았습니다. 토큰이 준비되면 자동으로 저장됩니다.',
                );
              } else {
                AppLogger.warning(
                  'iOS 시뮬레이터에서는 FCM 토큰을 가져올 수 없을 수 있습니다. 실제 기기에서 테스트해주세요.',
                );
              }
            }
            // 토큰이 없어도 리스너는 설정 (나중에 토큰이 생성될 수 있음)
          }
        } else {
          AppLogger.warning(
            'APNS 토큰이 준비되지 않아 FCM 토큰 가져오기를 건너뜁니다. '
            '토큰이 준비되면 자동으로 저장됩니다.',
          );
        }

        // 토큰 갱신 리스너 - 갱신된 토큰을 자동으로 Firestore에 저장
        _messaging.onTokenRefresh.listen((newToken) async {
          AppLogger.notification('토큰 갱신: $newToken');
          _fcmToken = newToken;
          // 현재 로그인된 사용자가 있으면 자동으로 토큰 저장
          if (_currentUserId != null) {
            await _saveTokenToFirestore(_currentUserId!);
          }
        });

        // iOS에서 APNS 토큰이 없었던 경우, 주기적으로 확인하여 FCM 토큰 가져오기
        if (Platform.isIOS && !apnsTokenReady) {
          _checkAndRetrieveTokenWhenReady();
        }

        // 포그라운드 메시지 리스너
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // 백그라운드에서 알림 탭 리스너
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        // 앱이 종료된 상태에서 알림 탭으로 열린 경우
        try {
          final initialMessage = await _messaging.getInitialMessage();
          if (initialMessage != null) {
            _handleMessageOpenedApp(initialMessage);
          }
        } catch (e, stackTrace) {
          AppLogger.error('초기 메시지 가져오기 실패: $e', e, stackTrace);
        }

        // iOS 포그라운드 알림 표시 설정
        if (Platform.isIOS) {
          try {
            await _messaging.setForegroundNotificationPresentationOptions(
              alert: true,
              badge: true,
              sound: true,
            );
            AppLogger.notification('iOS 포그라운드 알림 설정 완료');
          } catch (e, stackTrace) {
            AppLogger.error('iOS 포그라운드 알림 설정 실패: $e', e, stackTrace);
          }
        }
      } else {
        AppLogger.warning('알림 권한이 없습니다: ${settings.authorizationStatus}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('FCM 초기화 에러', e, stackTrace);
      AppLogger.error('에러 타입: ${e.runtimeType}', null);
      // FCM 초기화 실패해도 앱은 계속 실행되도록 함
    }
  }

  /// 사용자 FCM 토큰 저장
  Future<void> saveTokenForUser(String userId) async {
    _currentUserId = userId;

    if (_fcmToken == null) {
      AppLogger.notification('토큰이 아직 준비되지 않았습니다. 토큰을 다시 가져오는 중...');
      
      // iOS에서는 APNS 토큰을 먼저 확인
      if (Platform.isIOS) {
        try {
          final apnsToken = await _messaging.getAPNSToken();
          if (apnsToken == null) {
            AppLogger.warning('APNS 토큰이 아직 준비되지 않았습니다. 나중에 자동으로 저장됩니다.');
            _currentUserId = userId;
            return;
          }
        } catch (e) {
          AppLogger.warning('APNS 토큰 확인 실패: $e');
        }
      }
      
      // 토큰이 없으면 다시 시도
      try {
        _fcmToken = await _messaging.getToken();
        if (_fcmToken != null) {
          AppLogger.notification('토큰 가져오기 성공, 저장 중...');
          await _saveTokenToFirestore(userId);
          return;
        }
      } catch (e, stackTrace) {
        AppLogger.error('토큰 재시도 실패: $e', e, stackTrace);
        // iOS에서 APNS 토큰이 없으면 에러 메시지 표시하지 않음 (정상적인 상황)
        if (Platform.isIOS && e.toString().contains('apns-token-not-set')) {
          AppLogger.warning('APNS 토큰이 아직 준비되지 않았습니다. 토큰이 준비되면 자동으로 저장됩니다.');
        }
      }
      AppLogger.notification('토큰이 아직 준비되지 않았습니다. 토큰이 준비되면 자동으로 저장됩니다.');
      // 토큰이 나중에 준비되면 자동으로 저장되도록 _currentUserId는 설정해둠
      // onTokenRefresh 리스너에서 자동으로 저장됨
      _currentUserId = userId;
      return;
    }

    await _saveTokenToFirestore(userId);
  }

  /// Firestore에 토큰 저장 (내부 헬퍼)
  Future<void> _saveTokenToFirestore(String userId) async {
    if (_fcmToken == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': _fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.notification('사용자 토큰 저장 완료: userId=$userId');
    } catch (e, stackTrace) {
      AppLogger.error('사용자 토큰 저장 실패', e, stackTrace);
    }
  }

  /// FCM 토큰을 다시 가져와서 Firestore에 저장 (테스트 알림 전 호출)
  Future<bool> refreshAndSaveToken(String userId) async {
    try {
      AppLogger.notification('FCM 토큰 갱신 시도...');

      // iOS에서는 APNS 토큰을 먼저 확인 (재시도 로직 포함)
      if (Platform.isIOS) {
        String? apnsToken;

        // 실제 기기에서 APNS 토큰이 준비될 때까지 최대 3번 시도
        for (int i = 0; i < 3; i++) {
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) break;

          AppLogger.notification('APNS 토큰 대기 중... (${i + 1}/3)');
          await Future.delayed(const Duration(seconds: 1));
        }

        if (apnsToken == null) {
          AppLogger.warning('APNS 토큰을 가져올 수 없습니다. (시뮬레이터이거나 설정 문제)');
          return false;
        }
        AppLogger.notification('APNS 토큰 확인됨: $apnsToken');
      }

      // FCM 토큰 가져오기
      final token = await _messaging.getToken();
      if (token == null) {
        AppLogger.warning('FCM 토큰을 가져올 수 없습니다.');
        return false;
      }

      _fcmToken = token;
      _currentUserId = userId;
      AppLogger.notification('FCM 토큰 갱신 성공: $token');

      // Firestore에 저장
      await _saveTokenToFirestore(userId);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('FCM 토큰 갱신 실패: $e', e, stackTrace);
      return false;
    }
  }

  /// iOS에서 APNS 토큰이 준비될 때까지 확인하고 FCM 토큰 가져오기
  void _checkAndRetrieveTokenWhenReady() {
    if (!Platform.isIOS) return;

    // 기존 타이머가 있으면 취소
    _apnsTokenCheckTimer?.cancel();

    int attempts = 0;
    const maxAttempts = 20; // 최대 20번 시도 (약 1분)
    const checkInterval = Duration(seconds: 3);

    _apnsTokenCheckTimer = Timer.periodic(checkInterval, (timer) async {
      attempts++;
      
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          AppLogger.notification('APNS 토큰이 준비되었습니다. FCM 토큰 가져오기 시도...');
          timer.cancel();
          _apnsTokenCheckTimer = null;

          try {
            _fcmToken = await _messaging.getToken();
            AppLogger.notification('FCM 토큰 가져오기 성공: $_fcmToken');
            
            // 현재 사용자가 있으면 자동으로 저장
            if (_fcmToken != null && _currentUserId != null) {
              await _saveTokenToFirestore(_currentUserId!);
            }
          } catch (e, stackTrace) {
            AppLogger.error('FCM 토큰 가져오기 실패: $e', e, stackTrace);
          }
        } else if (attempts >= maxAttempts) {
          AppLogger.warning('APNS 토큰 확인 시도 횟수 초과. 나중에 토큰이 준비되면 자동으로 저장됩니다.');
          timer.cancel();
          _apnsTokenCheckTimer = null;
        }
      } catch (e) {
        if (attempts >= maxAttempts) {
          AppLogger.warning('APNS 토큰 확인 실패 (최대 시도 횟수 초과): $e');
          timer.cancel();
          _apnsTokenCheckTimer = null;
        }
      }
    });
  }

  /// 사용자 FCM 토큰 삭제 (로그아웃 시)
  Future<void> removeTokenForUser(String userId) async {
    _currentUserId = null;

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });
      AppLogger.notification('사용자 토큰 삭제 완료: userId=$userId');
    } catch (e, stackTrace) {
      AppLogger.error('사용자 토큰 삭제 실패', e, stackTrace);
    }
  }

  /// 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.notification('포그라운드 메시지 수신');
    AppLogger.debug('title: ${message.notification?.title}');
    AppLogger.debug('body: ${message.notification?.body}');
    AppLogger.debug('data: ${message.data}');
  }

  /// 백그라운드에서 알림 탭 처리
  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.notification('알림 탭으로 앱 열림');
    AppLogger.debug('data: ${message.data}');

    // 알림 데이터에서 postId와 parishId 추출하여 해당 게시글로 이동
    final postId = message.data['postId'];
    final parishId = message.data['parishId'];

    if (postId != null && parishId != null && _router != null) {
      final path = AppRoutes.postDetailPath(parishId, postId);
      AppLogger.notification('게시글 상세 화면으로 이동: $path');
      _router!.go(path);
    } else if (postId != null) {
      AppLogger.warning('postId=$postId로 이동 필요 (parishId 또는 router 없음)');
    }
  }

  /// FCM 테스트 알림 전송
  Future<Map<String, dynamic>> sendTestNotification() async {
    try {
      AppLogger.notification('FCM 테스트 알림 전송 시작...');
      
      final callable = _functions.httpsCallable('sendTestNotification');
      
      // 타임아웃 설정 (30초)
      final result = await callable.call().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('테스트 알림 전송이 30초 내에 완료되지 않았습니다.');
        },
      );
      
      AppLogger.notification('FCM 테스트 알림 전송 성공: ${result.data}');
      
      return {
        'success': true,
        'message': result.data['message'] ?? '테스트 알림이 전송되었습니다.',
        'messageId': result.data['messageId'],
      };
    } catch (e, stackTrace) {
      AppLogger.error('FCM 테스트 알림 전송 실패: $e', e, stackTrace);
      AppLogger.error('에러 타입: ${e.runtimeType}', null);
      
      String errorMessage = '테스트 알림 전송에 실패했습니다.';
      
      // Firebase Functions 에러 코드별 처리
      if (e is FirebaseFunctionsException) {
        switch (e.code) {
          case 'failed-precondition':
            if (e.message?.contains('FCM 토큰') ?? false) {
              errorMessage = 'FCM 토큰이 없습니다. '
                  '알림 권한을 허용하고 앱을 완전히 재시작해주세요. '
                  '(iOS의 경우 APNS 토큰이 필요합니다)';
            } else {
              errorMessage = e.message ?? '전제 조건이 충족되지 않았습니다.';
            }
            break;
          case 'unauthenticated':
            errorMessage = '로그인이 필요합니다.';
            break;
          case 'not-found':
            errorMessage = '사용자 정보를 찾을 수 없습니다.';
            break;
          case 'internal':
            errorMessage = 'Cloud Functions 내부 오류가 발생했습니다. '
                '잠시 후 다시 시도해주세요.';
            break;
          case 'deadline-exceeded':
            errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
            break;
          default:
            errorMessage = e.message ?? '알 수 없는 오류가 발생했습니다.';
        }
      } else {
        // 플랫폼 채널 연결 오류 처리
        if (e.toString().contains('Unable to establish connection') ||
            e.toString().contains('connection on channel')) {
          errorMessage = '네트워크 연결을 확인할 수 없습니다. '
              '앱을 완전히 종료한 후 다시 실행해주세요. '
              '(핫 리로드가 아닌 완전 재시작 필요)';
        } else if (e.toString().contains('FCM 토큰이 없습니다') ||
            e.toString().contains('failed-precondition')) {
          errorMessage = 'FCM 토큰이 없습니다. '
              '알림 권한을 허용하고 앱을 완전히 재시작해주세요.';
        } else if (e.toString().contains('인증이 필요합니다') ||
            e.toString().contains('인증') ||
            e.toString().contains('unauthenticated')) {
          errorMessage = '로그인이 필요합니다.';
        } else if (e.toString().contains('사용자를 찾을 수 없습니다')) {
          errorMessage = '사용자 정보를 찾을 수 없습니다.';
        } else if (e.toString().contains('not found') ||
            e.toString().contains('404') ||
            e.toString().contains('NOT_FOUND')) {
          errorMessage = 'Cloud Functions가 배포되지 않았습니다. '
              '관리자에게 문의해주세요.';
        } else if (e.toString().contains('TimeoutException') ||
            e.toString().contains('timeout')) {
          errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
        }
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'error': e.toString(),
      };
    }
  }
}
