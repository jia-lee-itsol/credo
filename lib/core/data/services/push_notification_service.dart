import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
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
  // Firebase Functions region 명시 (서버에서 region이 명시되지 않으면 기본값 us-central1 사용)
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    app: Firebase.app(),
    region: 'us-central1', // Firebase Functions v2 기본 region
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
      AppLogger.debug('=== FCM 초기화 시작 ===');
      AppLogger.debug('플랫폼: ${Platform.isIOS ? "iOS" : "Android"}');
      AppLogger.debug('Firebase 앱 초기화 상태 확인 중...');

      // 알림 권한 요청
      AppLogger.debug('알림 권한 요청 시작...');
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      AppLogger.notification('알림 권한 상태: ${settings.authorizationStatus}');
      AppLogger.debug('권한 상세 정보:');
      AppLogger.debug('  - alert: ${settings.alert}');
      AppLogger.debug('  - badge: ${settings.badge}');
      AppLogger.debug('  - sound: ${settings.sound}');
      AppLogger.debug('  - announcement: ${settings.announcement}');
      AppLogger.debug('  - carPlay: ${settings.carPlay}');
      AppLogger.debug('  - criticalAlert: ${settings.criticalAlert}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // iOS에서는 APNS 토큰을 먼저 설정해야 함
        bool apnsTokenReady = true;
        if (Platform.isIOS) {
          try {
            AppLogger.debug('=== iOS APNS 토큰 확인 시작 ===');
            AppLogger.notification('iOS APNS 토큰 가져오기 시도...');
            final apnsToken = await _messaging.getAPNSToken();
            AppLogger.debug(
              'APNS 토큰 조회 결과: ${apnsToken != null ? "성공" : "null"}',
            );
            if (apnsToken != null) {
              AppLogger.notification('APNS 토큰 가져오기 성공: $apnsToken');
              AppLogger.debug('APNS 토큰 길이: ${apnsToken.length}');
              AppLogger.debug(
                'APNS 토큰 앞 20자: ${apnsToken.substring(0, apnsToken.length > 20 ? 20 : apnsToken.length)}...',
              );
              apnsTokenReady = true;
            } else {
              AppLogger.warning('APNS 토큰이 아직 준비되지 않았습니다. 나중에 자동으로 설정됩니다.');
              AppLogger.debug(
                'APNS 토큰이 null인 이유: iOS 시뮬레이터이거나 앱이 처음 실행되었을 수 있습니다.',
              );
              apnsTokenReady = false;
              // APNS 토큰이 없으면 FCM 토큰을 가져올 수 없음
            }
          } catch (e, stackTrace) {
            AppLogger.warning('APNS 토큰 가져오기 실패 (나중에 자동으로 설정됨): $e');
            AppLogger.error('APNS 토큰 가져오기 에러 상세', e, stackTrace);
            AppLogger.debug('에러 타입: ${e.runtimeType}');
            AppLogger.debug('에러 메시지: ${e.toString()}');
            apnsTokenReady = false;
          }
        } else {
          AppLogger.debug('Android 플랫폼이므로 APNS 토큰 확인 건너뜀');
        }

        // APNS 토큰이 준비된 경우에만 FCM 토큰 가져오기 시도
        if (apnsTokenReady) {
          try {
            // FCM 토큰 가져오기
            AppLogger.debug('=== FCM 토큰 가져오기 시작 ===');
            AppLogger.notification('FCM 토큰 가져오기 시도...');
            AppLogger.debug('FirebaseMessaging 인스턴스 상태 확인 중...');
            _fcmToken = await _messaging.getToken();
            AppLogger.debug(
              'FCM 토큰 조회 완료, 결과: ${_fcmToken != null ? "성공" : "null"}',
            );
            if (_fcmToken != null) {
              AppLogger.notification('FCM 토큰 가져오기 성공: $_fcmToken');
              AppLogger.debug('FCM 토큰 길이: ${_fcmToken!.length}');
              AppLogger.debug(
                'FCM 토큰 앞 30자: ${_fcmToken!.substring(0, _fcmToken!.length > 30 ? 30 : _fcmToken!.length)}...',
              );
              AppLogger.debug('현재 사용자 ID: $_currentUserId');
              // 토큰을 가져온 후 현재 사용자가 있으면 자동으로 저장
              if (_currentUserId != null) {
                AppLogger.debug('사용자 ID가 있으므로 Firestore에 토큰 저장 시도...');
                await _saveTokenToFirestore(_currentUserId!);
                AppLogger.notification('FCM 토큰이 Firestore에 저장되었습니다.');
              } else {
                AppLogger.warning('현재 사용자 ID가 없어 FCM 토큰을 저장하지 못했습니다.');
                AppLogger.debug('토큰은 나중에 사용자가 로그인하면 자동으로 저장됩니다.');
              }
            } else {
              AppLogger.warning('FCM 토큰이 null입니다.');
              AppLogger.debug('토큰이 null인 가능한 이유:');
              AppLogger.debug('  - iOS: APNS 토큰이 아직 준비되지 않음');
              AppLogger.debug('  - Android: Firebase 설정 문제 또는 네트워크 문제');
              AppLogger.debug('  - 시뮬레이터/에뮬레이터에서 실행 중');
            }
          } catch (e, stackTrace) {
            AppLogger.error('FCM 토큰 가져오기 실패: $e', e, stackTrace);
            AppLogger.error('에러 상세: ${e.toString()}', null);
            AppLogger.debug('에러 타입: ${e.runtimeType}');
            AppLogger.debug('스택 트레이스: $stackTrace');
            // iOS에서 APNS 토큰이 없으면 FCM 토큰도 가져올 수 없음
            if (Platform.isIOS) {
              AppLogger.debug('iOS 플랫폼에서 에러 발생');
              if (e.toString().contains('apns-token-not-set')) {
                AppLogger.warning(
                  'APNS 토큰이 아직 준비되지 않았습니다. 토큰이 준비되면 자동으로 저장됩니다.',
                );
                AppLogger.debug('APNS 토큰이 설정되지 않은 상태입니다.');
              } else {
                AppLogger.warning(
                  'iOS 시뮬레이터에서는 FCM 토큰을 가져올 수 없을 수 있습니다. 실제 기기에서 테스트해주세요.',
                );
                AppLogger.debug('iOS 시뮬레이터 제한사항 또는 설정 문제일 수 있습니다.');
              }
            } else {
              AppLogger.debug('Android 플랫폼에서 에러 발생');
              AppLogger.debug('Android FCM 토큰 가져오기 실패 원인 확인 필요');
            }
            // 토큰이 없어도 리스너는 설정 (나중에 토큰이 생성될 수 있음)
          }
        } else {
          AppLogger.warning(
            'APNS 토큰이 준비되지 않아 FCM 토큰 가져오기를 건너뜁니다. '
            '토큰이 준비되면 자동으로 저장됩니다.',
          );
          AppLogger.debug('APNS 토큰 준비 대기 중...');
        }

        // 토큰 갱신 리스너 - 갱신된 토큰을 자동으로 Firestore에 저장
        AppLogger.debug('토큰 갱신 리스너 설정 중...');
        _messaging.onTokenRefresh.listen((newToken) async {
          AppLogger.debug('=== FCM 토큰 갱신 이벤트 발생 ===');
          AppLogger.notification('토큰 갱신: $newToken');
          AppLogger.debug('이전 토큰: ${_fcmToken ?? "null"}');
          AppLogger.debug('새 토큰 길이: ${newToken.length}');
          AppLogger.debug(
            '새 토큰 앞 30자: ${newToken.substring(0, newToken.length > 30 ? 30 : newToken.length)}...',
          );
          _fcmToken = newToken;
          AppLogger.debug('현재 사용자 ID: $_currentUserId');
          // 현재 로그인된 사용자가 있으면 자동으로 토큰 저장
          if (_currentUserId != null) {
            AppLogger.debug('사용자 ID가 있으므로 Firestore에 새 토큰 저장 시도...');
            await _saveTokenToFirestore(_currentUserId!);
            AppLogger.debug('토큰 갱신 및 저장 완료');
          } else {
            AppLogger.warning('사용자 ID가 없어 토큰 갱신만 저장하고 Firestore 저장은 건너뜁니다.');
          }
        });
        AppLogger.debug('토큰 갱신 리스너 설정 완료');

        // iOS에서 APNS 토큰이 없었던 경우, 주기적으로 확인하여 FCM 토큰 가져오기
        if (Platform.isIOS && !apnsTokenReady) {
          _checkAndRetrieveTokenWhenReady();
        }

        // 포그라운드 메시지 리스너
        AppLogger.debug('포그라운드 메시지 리스너 설정 중...');
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        AppLogger.debug('포그라운드 메시지 리스너 설정 완료');

        // 백그라운드에서 알림 탭 리스너
        AppLogger.debug('백그라운드 알림 탭 리스너 설정 중...');
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
        AppLogger.debug('백그라운드 알림 탭 리스너 설정 완료');

        // 앱이 종료된 상태에서 알림 탭으로 열린 경우
        AppLogger.debug('초기 메시지 확인 중...');
        try {
          final initialMessage = await _messaging.getInitialMessage();
          AppLogger.debug(
            '초기 메시지 조회 결과: ${initialMessage != null ? "있음" : "없음"}',
          );
          if (initialMessage != null) {
            AppLogger.debug('초기 메시지 처리 시작...');
            AppLogger.debug('초기 메시지 데이터: ${initialMessage.data}');
            AppLogger.debug(
              '초기 메시지 notification: ${initialMessage.notification?.title} - ${initialMessage.notification?.body}',
            );
            _handleMessageOpenedApp(initialMessage);
            AppLogger.debug('초기 메시지 처리 완료');
          } else {
            AppLogger.debug('초기 메시지가 없습니다 (앱이 정상적으로 시작됨)');
          }
        } catch (e, stackTrace) {
          AppLogger.error('초기 메시지 가져오기 실패: $e', e, stackTrace);
          AppLogger.debug('에러 타입: ${e.runtimeType}');
          AppLogger.debug('에러 메시지: ${e.toString()}');
        }

        // 앱 시작 시 뱃지 초기화
        await clearBadge();

        // iOS 포그라운드 알림 표시 설정
        if (Platform.isIOS) {
          try {
            AppLogger.debug('iOS 포그라운드 알림 표시 옵션 설정 중...');
            await _messaging.setForegroundNotificationPresentationOptions(
              alert: true,
              badge: true,
              sound: true,
            );
            AppLogger.notification('iOS 포그라운드 알림 설정 완료');
            AppLogger.debug(
              'iOS 포그라운드 알림 옵션: alert=true, badge=true, sound=true',
            );
          } catch (e, stackTrace) {
            AppLogger.error('iOS 포그라운드 알림 설정 실패: $e', e, stackTrace);
            AppLogger.debug('에러 타입: ${e.runtimeType}');
            AppLogger.debug('에러 메시지: ${e.toString()}');
          }
        } else {
          AppLogger.debug('Android 플랫폼이므로 iOS 포그라운드 알림 설정 건너뜀');
        }

        AppLogger.debug('=== FCM 초기화 완료 ===');
      } else {
        AppLogger.warning('알림 권한이 없습니다: ${settings.authorizationStatus}');
        AppLogger.debug('권한 상태 상세:');
        AppLogger.debug(
          '  - authorized: ${settings.authorizationStatus == AuthorizationStatus.authorized}',
        );
        AppLogger.debug(
          '  - denied: ${settings.authorizationStatus == AuthorizationStatus.denied}',
        );
        AppLogger.debug(
          '  - notDetermined: ${settings.authorizationStatus == AuthorizationStatus.notDetermined}',
        );
        AppLogger.debug(
          '  - provisional: ${settings.authorizationStatus == AuthorizationStatus.provisional}',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('FCM 초기화 에러', e, stackTrace);
      AppLogger.error('에러 타입: ${e.runtimeType}', null);
      AppLogger.debug('에러 메시지: ${e.toString()}');
      AppLogger.debug('스택 트레이스: $stackTrace');
      AppLogger.debug('플랫폼: ${Platform.isIOS ? "iOS" : "Android"}');
      // FCM 초기화 실패해도 앱은 계속 실행되도록 함
    }
  }

  /// 사용자 FCM 토큰 저장
  Future<void> saveTokenForUser(String userId) async {
    AppLogger.debug('=== 사용자 토큰 저장 요청 ===');
    AppLogger.debug('사용자 ID: $userId');
    AppLogger.debug('현재 FCM 토큰 상태: ${_fcmToken != null ? "있음" : "null"}');
    AppLogger.debug('이전 사용자 ID: $_currentUserId');

    _currentUserId = userId;
    AppLogger.debug('현재 사용자 ID 설정 완료: $_currentUserId');

    if (_fcmToken == null) {
      AppLogger.notification('토큰이 아직 준비되지 않았습니다. 토큰을 다시 가져오는 중...');
      AppLogger.debug('토큰이 null이므로 재시도 시작');

      // iOS에서는 APNS 토큰을 먼저 확인
      if (Platform.isIOS) {
        AppLogger.debug('iOS 플랫폼이므로 APNS 토큰 확인 중...');
        try {
          final apnsToken = await _messaging.getAPNSToken();
          AppLogger.debug(
            'APNS 토큰 조회 결과: ${apnsToken != null ? "성공" : "null"}',
          );
          if (apnsToken == null) {
            AppLogger.warning('APNS 토큰이 아직 준비되지 않았습니다. 나중에 자동으로 저장됩니다.');
            AppLogger.debug('APNS 토큰이 없으므로 FCM 토큰 가져오기 불가');
            _currentUserId = userId;
            return;
          } else {
            AppLogger.debug(
              'APNS 토큰 확인됨: ${apnsToken.substring(0, apnsToken.length > 20 ? 20 : apnsToken.length)}...',
            );
          }
        } catch (e, stackTrace) {
          AppLogger.warning('APNS 토큰 확인 실패: $e');
          AppLogger.error('APNS 토큰 확인 에러 상세', e, stackTrace);
        }
      } else {
        AppLogger.debug('Android 플랫폼이므로 APNS 토큰 확인 건너뜀');
      }

      // 토큰이 없으면 다시 시도
      AppLogger.debug('FCM 토큰 재시도 시작...');
      try {
        _fcmToken = await _messaging.getToken();
        AppLogger.debug('FCM 토큰 재시도 결과: ${_fcmToken != null ? "성공" : "null"}');
        if (_fcmToken != null) {
          AppLogger.notification('토큰 가져오기 성공, 저장 중...');
          AppLogger.debug('토큰 길이: ${_fcmToken!.length}');
          await _saveTokenToFirestore(userId);
          return;
        } else {
          AppLogger.warning('FCM 토큰 재시도 결과가 null입니다.');
        }
      } catch (e, stackTrace) {
        AppLogger.error('토큰 재시도 실패: $e', e, stackTrace);
        AppLogger.debug('에러 타입: ${e.runtimeType}');
        AppLogger.debug('에러 메시지: ${e.toString()}');
        // iOS에서 APNS 토큰이 없으면 에러 메시지 표시하지 않음 (정상적인 상황)
        if (Platform.isIOS && e.toString().contains('apns-token-not-set')) {
          AppLogger.warning('APNS 토큰이 아직 준비되지 않았습니다. 토큰이 준비되면 자동으로 저장됩니다.');
          AppLogger.debug('APNS 토큰 미설정으로 인한 정상적인 실패');
        }
      }
      AppLogger.notification('토큰이 아직 준비되지 않았습니다. 토큰이 준비되면 자동으로 저장됩니다.');
      AppLogger.debug('토큰이 나중에 준비되면 자동 저장되도록 사용자 ID 설정 완료');
      // 토큰이 나중에 준비되면 자동으로 저장되도록 _currentUserId는 설정해둠
      // onTokenRefresh 리스너에서 자동으로 저장됨
      _currentUserId = userId;
      return;
    }

    AppLogger.debug('FCM 토큰이 이미 있으므로 바로 Firestore에 저장');
    await _saveTokenToFirestore(userId);
  }

  /// Firestore에 토큰 저장 (내부 헬퍼)
  Future<void> _saveTokenToFirestore(String userId) async {
    AppLogger.debug('=== Firestore 토큰 저장 시작 ===');
    AppLogger.debug('사용자 ID: $userId');
    AppLogger.debug('FCM 토큰 상태: ${_fcmToken != null ? "있음" : "null"}');

    if (_fcmToken == null) {
      AppLogger.warning('FCM 토큰이 null이어서 Firestore에 저장할 수 없습니다.');
      AppLogger.debug('토큰이 null인 이유 확인 필요');
      return;
    }

    try {
      AppLogger.notification(
        'Firestore에 FCM 토큰 저장 시도: userId=$userId, token=${_fcmToken!.substring(0, _fcmToken!.length > 20 ? 20 : _fcmToken!.length)}...',
      );
      AppLogger.debug('토큰 전체 길이: ${_fcmToken!.length}');
      AppLogger.debug('Firestore 경로: users/$userId');
      AppLogger.debug('업데이트할 필드: fcmToken, fcmTokenUpdatedAt');

      await _firestore.collection('users').doc(userId).update({
        'fcmToken': _fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.notification('✅ 사용자 토큰 저장 완료: userId=$userId');
      AppLogger.debug('Firestore 업데이트 성공');

      // 저장 확인 (선택적)
      try {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          final savedToken = doc.data()?['fcmToken'] as String?;
          AppLogger.debug('저장된 토큰 확인: ${savedToken != null ? "성공" : "없음"}');
          if (savedToken != null) {
            AppLogger.debug(
              '저장된 토큰 앞 20자: ${savedToken.substring(0, savedToken.length > 20 ? 20 : savedToken.length)}...',
            );
            AppLogger.debug('토큰 일치 여부: ${savedToken == _fcmToken}');
          }
        }
      } catch (e) {
        AppLogger.debug('저장 확인 중 에러 (무시 가능): $e');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ 사용자 토큰 저장 실패: userId=$userId', e, stackTrace);
      AppLogger.error('에러 상세: ${e.toString()}', null);
      AppLogger.debug('에러 타입: ${e.runtimeType}');
      AppLogger.debug('스택 트레이스: $stackTrace');

      // Firestore 에러 상세 정보
      if (e.toString().contains('permission-denied')) {
        AppLogger.error('Firestore 권한 거부: 사용자 문서에 쓰기 권한이 없습니다.', null);
      } else if (e.toString().contains('not-found')) {
        AppLogger.error('사용자 문서를 찾을 수 없습니다.', null);
      } else if (e.toString().contains('unavailable')) {
        AppLogger.error('Firestore 서비스가 사용 불가능합니다. 네트워크를 확인해주세요.', null);
      }
    }
  }

  /// FCM 토큰을 다시 가져와서 Firestore에 저장 (테스트 알림 전 호출)
  Future<bool> refreshAndSaveToken(String userId) async {
    AppLogger.debug('=== FCM 토큰 갱신 및 저장 시작 ===');
    AppLogger.debug('사용자 ID: $userId');
    AppLogger.debug(
      '현재 FCM 토큰: ${_fcmToken != null ? "${_fcmToken!.substring(0, _fcmToken!.length > 30 ? 30 : _fcmToken!.length)}..." : "null"}',
    );
    AppLogger.debug('플랫폼: ${Platform.isIOS ? "iOS" : "Android"}');

    try {
      AppLogger.notification('FCM 토큰 갱신 시도...');

      // iOS에서는 APNS 토큰을 먼저 확인 (재시도 로직 포함)
      if (Platform.isIOS) {
        AppLogger.debug('iOS 플랫폼이므로 APNS 토큰 확인 시작 (최대 3번 시도)');
        String? apnsToken;

        // 실제 기기에서 APNS 토큰이 준비될 때까지 최대 3번 시도
        for (int i = 0; i < 3; i++) {
          AppLogger.debug('APNS 토큰 확인 시도 ${i + 1}/3');
          apnsToken = await _messaging.getAPNSToken();
          AppLogger.debug(
            'APNS 토큰 조회 결과: ${apnsToken != null ? "성공" : "null"}',
          );
          if (apnsToken != null) {
            AppLogger.debug('APNS 토큰 확인 성공, 루프 종료');
            break;
          }

          AppLogger.notification('APNS 토큰 대기 중... (${i + 1}/3)');
          AppLogger.debug('1초 대기 후 재시도...');
          await Future.delayed(const Duration(seconds: 1));
        }

        if (apnsToken == null) {
          AppLogger.warning('APNS 토큰을 가져올 수 없습니다. (시뮬레이터이거나 설정 문제)');
          AppLogger.debug('APNS 토큰 확인 실패로 인해 FCM 토큰 갱신 중단');
          return false;
        }
        AppLogger.notification('APNS 토큰 확인됨: $apnsToken');
        AppLogger.debug('APNS 토큰 길이: ${apnsToken.length}');
        AppLogger.debug(
          'APNS 토큰 앞 20자: ${apnsToken.substring(0, apnsToken.length > 20 ? 20 : apnsToken.length)}...',
        );
      } else {
        AppLogger.debug('Android 플랫폼이므로 APNS 토큰 확인 건너뜀');
      }

      // FCM 토큰 가져오기
      AppLogger.debug('FCM 토큰 가져오기 시작...');
      final token = await _messaging.getToken();
      AppLogger.debug('FCM 토큰 조회 결과: ${token != null ? "성공" : "null"}');
      if (token == null) {
        AppLogger.warning('FCM 토큰을 가져올 수 없습니다.');
        AppLogger.debug('FCM 토큰이 null이므로 갱신 실패');
        return false;
      }

      AppLogger.debug('이전 토큰: ${_fcmToken ?? "null"}');
      AppLogger.debug('새 토큰 길이: ${token.length}');
      AppLogger.debug(
        '새 토큰 앞 30자: ${token.substring(0, token.length > 30 ? 30 : token.length)}...',
      );
      _fcmToken = token;
      _currentUserId = userId;
      AppLogger.debug('FCM 토큰 및 사용자 ID 업데이트 완료');
      AppLogger.notification('FCM 토큰 갱신 성공: $token');

      // Firestore에 저장
      AppLogger.debug('Firestore에 토큰 저장 시작...');
      await _saveTokenToFirestore(userId);
      AppLogger.debug('FCM 토큰 갱신 및 저장 완료');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('FCM 토큰 갱신 실패: $e', e, stackTrace);
      AppLogger.debug('에러 타입: ${e.runtimeType}');
      AppLogger.debug('에러 메시지: ${e.toString()}');
      AppLogger.debug('스택 트레이스: $stackTrace');
      return false;
    }
  }

  /// iOS에서 APNS 토큰이 준비될 때까지 확인하고 FCM 토큰 가져오기
  void _checkAndRetrieveTokenWhenReady() {
    AppLogger.debug('=== APNS 토큰 준비 확인 시작 ===');
    if (!Platform.isIOS) {
      AppLogger.debug('iOS 플랫폼이 아니므로 APNS 토큰 확인 건너뜀');
      return;
    }

    // 기존 타이머가 있으면 취소
    if (_apnsTokenCheckTimer != null) {
      AppLogger.debug('기존 APNS 토큰 확인 타이머 취소');
      _apnsTokenCheckTimer?.cancel();
    }

    int attempts = 0;
    const maxAttempts = 20; // 최대 20번 시도 (약 1분)
    const checkInterval = Duration(seconds: 3);

    AppLogger.debug('APNS 토큰 확인 설정:');
    AppLogger.debug('  - 최대 시도 횟수: $maxAttempts');
    AppLogger.debug('  - 확인 간격: ${checkInterval.inSeconds}초');
    AppLogger.debug('  - 총 대기 시간: ${maxAttempts * checkInterval.inSeconds}초');

    _apnsTokenCheckTimer = Timer.periodic(checkInterval, (timer) async {
      attempts++;
      AppLogger.debug('APNS 토큰 확인 시도 $attempts/$maxAttempts');

      try {
        final apnsToken = await _messaging.getAPNSToken();
        AppLogger.debug('APNS 토큰 조회 결과: ${apnsToken != null ? "성공" : "null"}');
        if (apnsToken != null) {
          AppLogger.notification('APNS 토큰이 준비되었습니다. FCM 토큰 가져오기 시도...');
          AppLogger.debug('APNS 토큰 확인 성공, 타이머 취소');
          timer.cancel();
          _apnsTokenCheckTimer = null;

          try {
            AppLogger.debug('FCM 토큰 가져오기 시작...');
            _fcmToken = await _messaging.getToken();
            AppLogger.debug(
              'FCM 토큰 조회 결과: ${_fcmToken != null ? "성공" : "null"}',
            );
            if (_fcmToken != null) {
              AppLogger.notification('FCM 토큰 가져오기 성공: $_fcmToken');
              AppLogger.debug('FCM 토큰 길이: ${_fcmToken!.length}');
              AppLogger.debug('현재 사용자 ID: $_currentUserId');

              // 현재 사용자가 있으면 자동으로 저장
              if (_fcmToken != null && _currentUserId != null) {
                AppLogger.debug('사용자 ID가 있으므로 Firestore에 토큰 저장 시도...');
                await _saveTokenToFirestore(_currentUserId!);
                AppLogger.debug('토큰 저장 완료');
              } else {
                AppLogger.debug('사용자 ID가 없어 토큰 저장 건너뜀');
              }
            } else {
              AppLogger.warning('FCM 토큰이 null입니다.');
            }
          } catch (e, stackTrace) {
            AppLogger.error('FCM 토큰 가져오기 실패: $e', e, stackTrace);
            AppLogger.debug('에러 타입: ${e.runtimeType}');
            AppLogger.debug('에러 메시지: ${e.toString()}');
          }
        } else if (attempts >= maxAttempts) {
          AppLogger.warning('APNS 토큰 확인 시도 횟수 초과. 나중에 토큰이 준비되면 자동으로 저장됩니다.');
          AppLogger.debug('최대 시도 횟수($maxAttempts)에 도달하여 타이머 취소');
          timer.cancel();
          _apnsTokenCheckTimer = null;
        } else {
          AppLogger.debug('APNS 토큰이 아직 준비되지 않음, 다음 확인 대기 중...');
        }
      } catch (e, stackTrace) {
        AppLogger.debug('APNS 토큰 확인 중 에러 발생: $e');
        if (attempts >= maxAttempts) {
          AppLogger.warning('APNS 토큰 확인 실패 (최대 시도 횟수 초과): $e');
          AppLogger.error('APNS 토큰 확인 최종 실패', e, stackTrace);
          AppLogger.debug('최대 시도 횟수($maxAttempts)에 도달하여 타이머 취소');
          timer.cancel();
          _apnsTokenCheckTimer = null;
        } else {
          AppLogger.debug('에러 발생했지만 재시도 가능 (시도 $attempts/$maxAttempts)');
        }
      }
    });

    AppLogger.debug('APNS 토큰 확인 타이머 시작 완료');
  }

  /// 사용자 FCM 토큰 삭제 (로그아웃 시)
  Future<void> removeTokenForUser(String userId) async {
    AppLogger.debug('=== 사용자 토큰 삭제 시작 ===');
    AppLogger.debug('사용자 ID: $userId');
    AppLogger.debug('이전 사용자 ID: $_currentUserId');
    AppLogger.debug(
      '현재 FCM 토큰: ${_fcmToken != null ? "${_fcmToken!.substring(0, _fcmToken!.length > 30 ? 30 : _fcmToken!.length)}..." : "null"}',
    );

    _currentUserId = null;
    AppLogger.debug('현재 사용자 ID를 null로 설정');

    try {
      AppLogger.debug('Firestore에서 토큰 삭제 시도...');
      AppLogger.debug('Firestore 경로: users/$userId');
      AppLogger.debug('삭제할 필드: fcmToken, fcmTokenUpdatedAt');

      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });

      AppLogger.notification('사용자 토큰 삭제 완료: userId=$userId');
      AppLogger.debug('Firestore 업데이트 성공');

      // 삭제 확인 (선택적)
      try {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          final savedToken = doc.data()?['fcmToken'] as String?;
          AppLogger.debug(
            '삭제 확인: ${savedToken == null ? "성공 (토큰 없음)" : "실패 (토큰 존재)"}',
          );
        }
      } catch (e) {
        AppLogger.debug('삭제 확인 중 에러 (무시 가능): $e');
      }
    } catch (e, stackTrace) {
      AppLogger.error('사용자 토큰 삭제 실패', e, stackTrace);
      AppLogger.debug('에러 타입: ${e.runtimeType}');
      AppLogger.debug('에러 메시지: ${e.toString()}');
      AppLogger.debug('스택 트레이스: $stackTrace');

      // Firestore 에러 상세 정보
      if (e.toString().contains('permission-denied')) {
        AppLogger.error('Firestore 권한 거부: 사용자 문서에 쓰기 권한이 없습니다.', null);
      } else if (e.toString().contains('not-found')) {
        AppLogger.error('사용자 문서를 찾을 수 없습니다.', null);
      }
    }
  }

  /// 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.debug('=== 포그라운드 메시지 수신 ===');
    AppLogger.notification('포그라운드 메시지 수신');
    AppLogger.debug('메시지 ID: ${message.messageId}');
    AppLogger.debug('발신 시간: ${message.sentTime}');
    AppLogger.debug('발신자: ${message.from}');
    AppLogger.debug('알림 제목: ${message.notification?.title}');
    AppLogger.debug('알림 본문: ${message.notification?.body}');
    AppLogger.debug('알림 아이콘: ${message.notification?.android?.smallIcon}');
    AppLogger.debug('알림 이미지: ${message.notification?.android?.imageUrl}');
    AppLogger.debug('알림 채널: ${message.notification?.android?.channelId}');
    AppLogger.debug('데이터 페이로드: ${message.data}');
    AppLogger.debug('데이터 키 목록: ${message.data.keys.toList()}');
    AppLogger.debug('postId: ${message.data['postId']}');
    AppLogger.debug('parishId: ${message.data['parishId']}');
    AppLogger.debug('TTL: ${message.ttl}');
    AppLogger.debug('콜랩스 키: ${message.collapseKey}');

    try {
      // 데이터 검증
      if (message.data.isEmpty) {
        AppLogger.warning('메시지 데이터가 비어있습니다.');
      }

      // 알림 정보 확인
      if (message.notification == null) {
        AppLogger.warning('알림 정보가 없습니다 (데이터만 전송)');
      }
    } catch (e, stackTrace) {
      AppLogger.error('포그라운드 메시지 처리 중 에러', e, stackTrace);
    }
  }

  /// 백그라운드에서 알림 탭 처리
  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.debug('=== 알림 탭으로 앱 열림 ===');
    AppLogger.notification('알림 탭으로 앱 열림');

    // 알림 탭 시 뱃지 초기화
    clearBadge();
    AppLogger.debug('메시지 ID: ${message.messageId}');
    AppLogger.debug('발신 시간: ${message.sentTime}');
    AppLogger.debug('발신자: ${message.from}');
    AppLogger.debug('알림 제목: ${message.notification?.title}');
    AppLogger.debug('알림 본문: ${message.notification?.body}');
    AppLogger.debug('데이터 페이로드: ${message.data}');
    AppLogger.debug('데이터 키 목록: ${message.data.keys.toList()}');

    // 알림 데이터에서 postId와 parishId 추출하여 해당 게시글로 이동
    final postId = message.data['postId'];
    final parishId = message.data['parishId'];

    AppLogger.debug('추출된 데이터:');
    AppLogger.debug('  - postId: $postId (타입: ${postId.runtimeType})');
    AppLogger.debug('  - parishId: $parishId (타입: ${parishId.runtimeType})');
    AppLogger.debug('  - router: ${_router != null ? "설정됨" : "null"}');

    try {
      if (postId != null && parishId != null && _router != null) {
        final path = AppRoutes.postDetailPath(parishId, postId);
        AppLogger.notification('게시글 상세 화면으로 이동: $path');
        AppLogger.debug('네비게이션 경로: $path');
        AppLogger.debug('Router 상태 확인 중...');
        _router!.go(path);
        AppLogger.debug('네비게이션 완료');
      } else {
        if (postId == null) {
          AppLogger.warning('postId가 없습니다.');
        }
        if (parishId == null) {
          AppLogger.warning('parishId가 없습니다.');
        }
        if (_router == null) {
          AppLogger.warning('router가 설정되지 않았습니다.');
        }
        if (postId != null) {
          AppLogger.warning('postId=$postId로 이동 필요 (parishId 또는 router 없음)');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('알림 탭 처리 중 네비게이션 에러', e, stackTrace);
      AppLogger.debug('에러 타입: ${e.runtimeType}');
      AppLogger.debug('에러 메시지: ${e.toString()}');
    }
  }

  /// FCM 테스트 알림 전송
  Future<Map<String, dynamic>> sendTestNotification() async {
    AppLogger.debug('=== FCM 테스트 알림 전송 시작 ===');
    AppLogger.debug('현재 사용자 ID: $_currentUserId');
    AppLogger.debug(
      '현재 FCM 토큰: ${_fcmToken != null ? "${_fcmToken!.substring(0, _fcmToken!.length > 30 ? 30 : _fcmToken!.length)}..." : "null"}',
    );
    AppLogger.debug('플랫폼: ${Platform.isIOS ? "iOS" : "Android"}');
    AppLogger.debug('Firebase Functions 인스턴스 확인 중...');

    // Firebase Functions 인스턴스 상세 정보
    try {
      final firebaseApp = Firebase.app();
      final options = firebaseApp.options;
      AppLogger.debug('Firebase 앱 인스턴스: ${firebaseApp.name}');
      AppLogger.debug('Firebase 프로젝트 ID: ${options.projectId}');
      AppLogger.debug('Firebase Functions 인스턴스 타입: ${_functions.runtimeType}');
      AppLogger.debug('Firebase 앱 옵션:');
      final apiKey = options.apiKey;
      AppLogger.debug(
        '  - apiKey: ${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...',
      );
      AppLogger.debug('  - appId: ${options.appId}');
      AppLogger.debug('  - messagingSenderId: ${options.messagingSenderId}');
    } catch (e) {
      AppLogger.debug('Firebase 인스턴스 정보 확인 중 에러: $e');
    }

    try {
      AppLogger.notification('FCM 테스트 알림 전송 시작...');
      AppLogger.debug('Cloud Function 호출 준비: sendTestNotification');
      AppLogger.debug('호출 시간: ${DateTime.now().toIso8601String()}');
      AppLogger.debug('Firebase Functions region: us-central1');

      final callable = _functions.httpsCallable('sendTestNotification');
      AppLogger.debug('Callable 생성 완료');
      AppLogger.debug('Callable 타입: ${callable.runtimeType}');
      AppLogger.debug('타임아웃 설정: 30초');

      // 타임아웃 설정 (30초)
      final startTime = DateTime.now();
      AppLogger.debug(
        'Cloud Function 호출 시작... (시작 시간: ${startTime.toIso8601String()})',
      );
      AppLogger.debug('전송할 데이터: {} (빈 맵, 서버에서 request.auth로 사용자 인증)');

      // 명시적으로 빈 데이터 전달 (서버에서 request.auth?.uid 사용)
      final result = await callable
          .call<Map<String, dynamic>>(<String, dynamic>{})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              final elapsed = DateTime.now().difference(startTime);
              AppLogger.error('타임아웃 발생: 30초 내에 응답을 받지 못했습니다.', null);
              AppLogger.debug('경과 시간: ${elapsed.inSeconds}초');
              AppLogger.debug(
                '타임아웃 발생 시간: ${DateTime.now().toIso8601String()}',
              );
              throw TimeoutException('테스트 알림 전송이 30초 내에 완료되지 않았습니다.');
            },
          );

      final elapsed = DateTime.now().difference(startTime);
      AppLogger.debug(
        'Cloud Function 호출 완료 (경과 시간: ${elapsed.inMilliseconds}ms)',
      );

      AppLogger.debug('Cloud Function 응답 수신');
      AppLogger.debug('응답 수신 시간: ${DateTime.now().toIso8601String()}');
      AppLogger.debug('응답 데이터: ${result.data}');
      AppLogger.debug('응답 데이터 타입: ${result.data.runtimeType}');

      // 응답 데이터 상세 분석
      final responseMap = result.data;
      AppLogger.debug('응답 데이터 맵 크기: ${responseMap.length}');
      AppLogger.debug('응답 데이터 키 목록: ${responseMap.keys.toList()}');
      responseMap.forEach((key, value) {
        AppLogger.debug('  - $key: $value (타입: ${value.runtimeType})');
      });

      AppLogger.notification('FCM 테스트 알림 전송 성공: ${result.data}');

      final response = {
        'success': true,
        'message': result.data['message'] ?? '테스트 알림이 전송되었습니다.',
        'messageId': result.data['messageId'],
      };
      AppLogger.debug('응답 객체 생성 완료: $response');

      return response;
    } catch (e, stackTrace) {
      final errorTime = DateTime.now();
      AppLogger.error('FCM 테스트 알림 전송 실패: $e', e, stackTrace);
      AppLogger.error('에러 타입: ${e.runtimeType}', null);
      AppLogger.debug('에러 발생 시간: ${errorTime.toIso8601String()}');
      AppLogger.debug('에러 메시지: ${e.toString()}');
      AppLogger.debug('스택 트레이스: $stackTrace');

      // 에러 객체의 모든 속성 확인
      try {
        AppLogger.debug('에러 객체 속성 확인 중...');
        if (e is Exception) {
          AppLogger.debug('Exception 타입 확인됨');
        }
        if (e is Error) {
          AppLogger.debug('Error 타입 확인됨');
        }

        // 에러 객체의 모든 public 속성 로깅
        try {
          final errorString = e.toString();
          AppLogger.debug('에러 toString(): $errorString');
        } catch (_) {
          AppLogger.debug('에러 toString() 호출 실패');
        }
      } catch (debugError) {
        AppLogger.debug('에러 객체 분석 중 에러: $debugError');
      }

      // FirebaseFunctionsException의 상세 정보 로깅
      if (e is FirebaseFunctionsException) {
        AppLogger.debug('=== FirebaseFunctionsException 상세 정보 ===');
        AppLogger.error('FirebaseFunctionsException 상세:', null);
        AppLogger.error('  - code: ${e.code}', null);
        AppLogger.error('  - message: ${e.message}', null);
        AppLogger.error('  - details: ${e.details}', null);
        AppLogger.error('  - stackTrace: ${e.stackTrace}', null);
        AppLogger.debug('에러 코드 타입: ${e.code.runtimeType}');
        AppLogger.debug('에러 메시지 타입: ${e.message.runtimeType}');
        AppLogger.debug('에러 상세 타입: ${e.details.runtimeType}');
        AppLogger.debug('에러 상세 null 여부: ${e.details == null}');

        // details가 Map인 경우 상세 로깅 (서버에서 전달한 errorDetails)
        if (e.details != null) {
          AppLogger.debug('Details가 null이 아님, 타입 확인 중...');
          if (e.details is Map) {
            AppLogger.debug('Details는 Map 타입');
            final detailsMap = e.details as Map;
            AppLogger.debug('Details 맵 크기: ${detailsMap.length}');
            AppLogger.debug('Details 맵 키 목록: ${detailsMap.keys.toList()}');

            // 서버에서 전달한 errorDetails의 주요 필드들을 명확하게 로깅
            AppLogger.error('=== 서버에서 전달한 에러 상세 정보 (errorDetails) ===', null);

            // errorMessage (FCM 메시지 전송 실패 메시지)
            if (detailsMap.containsKey('errorMessage')) {
              final errorMessage = detailsMap['errorMessage'];
              AppLogger.error(
                '  🔴 errorMessage (FCM 전송 실패 메시지): $errorMessage',
                null,
              );
              AppLogger.debug('    이 메시지가 원인 그 자체입니다!');
            }

            // errorName
            if (detailsMap.containsKey('errorName')) {
              AppLogger.error(
                '  - errorName: ${detailsMap['errorName']}',
                null,
              );
            }

            // errorType
            if (detailsMap.containsKey('errorType')) {
              AppLogger.error(
                '  - errorType: ${detailsMap['errorType']}',
                null,
              );
            }

            // code (FCM 에러 코드)
            if (detailsMap.containsKey('code')) {
              final code = detailsMap['code'];
              AppLogger.error('  🔴 code (FCM 에러 코드): $code', null);
              AppLogger.debug('    이 코드가 원인 그 자체입니다!');
            }

            // httpErrorCode (HTTP 에러 코드)
            if (detailsMap.containsKey('httpErrorCode')) {
              final httpErrorCode = detailsMap['httpErrorCode'];
              AppLogger.error(
                '  🔴 httpErrorCode (HTTP 에러 코드): $httpErrorCode',
                null,
              );
              AppLogger.debug('    이 코드가 원인 그 자체입니다!');
            }

            // originalDetails (원본 FCM 에러 상세 정보)
            if (detailsMap.containsKey('originalDetails')) {
              final originalDetails = detailsMap['originalDetails'];
              AppLogger.error(
                '  🔴 originalDetails (원본 FCM 에러 상세): $originalDetails',
                null,
              );
              AppLogger.debug('    이 정보가 원인 그 자체입니다!');
              if (originalDetails is Map) {
                AppLogger.debug('    originalDetails 맵 내용:');
                originalDetails.forEach((key, value) {
                  AppLogger.debug('      $key: $value');
                });
              }
            }

            // 모든 필드 출력 (위에서 누락된 필드가 있을 수 있음)
            AppLogger.debug('Details 맵 전체 내용:');
            detailsMap.forEach((key, value) {
              AppLogger.debug('    $key: $value (타입: ${value.runtimeType})');
            });
          } else if (e.details is String) {
            AppLogger.debug('Details는 String 타입: ${e.details}');
            AppLogger.error('Details (String): ${e.details}', null);
          } else {
            AppLogger.debug(
              'Details 타입: ${e.details.runtimeType}, 값: ${e.details}',
            );
            AppLogger.error('Details: ${e.details}', null);
            try {
              AppLogger.debug('Details toString(): ${e.details.toString()}');
            } catch (_) {
              AppLogger.debug('Details toString() 호출 실패');
            }
          }
        } else {
          AppLogger.debug('Details가 null입니다. 서버에서 상세 정보를 제공하지 않았습니다.');
          AppLogger.error(
            '⚠️ 서버의 errorDetails가 전달되지 않았습니다. Cloud Functions 로그를 확인하세요.',
            null,
          );
          AppLogger.debug('Cloud Functions 로그에서 다음을 확인하세요:');
          AppLogger.debug('  - "FCM 메시지 전송 실패: ..." 로그');
          AppLogger.debug('  - "에러 상세 정보: ..." 로그');
        }

        // 에러 코드별 추가 정보
        AppLogger.debug('에러 코드 분석: ${e.code}');
        if (e.code == 'internal') {
          AppLogger.debug('INTERNAL 에러 - Cloud Functions 서버 측 문제일 가능성이 높습니다.');
          AppLogger.debug('가능한 원인:');
          AppLogger.debug('  1. Cloud Functions 서버 에러');
          AppLogger.debug('  2. Firebase Admin SDK 초기화 실패');
          AppLogger.debug('  3. FCM API 호출 실패');
          AppLogger.debug('  4. 서비스 계정 권한 문제');
          AppLogger.debug('  5. 네트워크 연결 문제');
        }
      } else {
        AppLogger.debug(
          'FirebaseFunctionsException이 아닌 다른 에러 타입: ${e.runtimeType}',
        );

        // TimeoutException 확인
        if (e is TimeoutException) {
          AppLogger.debug('TimeoutException 감지');
          AppLogger.debug('타임아웃 메시지: ${e.message ?? "없음"}');
        }

        // 다른 Exception 타입 확인
        if (e.toString().contains('PlatformException')) {
          AppLogger.debug('PlatformException으로 보임');
        }
        if (e.toString().contains('SocketException')) {
          AppLogger.debug('SocketException으로 보임 - 네트워크 연결 문제');
        }
        if (e.toString().contains('HttpException')) {
          AppLogger.debug('HttpException으로 보임 - HTTP 요청 문제');
        }
      }

      String errorMessage = '테스트 알림 전송에 실패했습니다.';
      AppLogger.debug('에러 메시지 생성 시작...');

      // Firebase Functions 에러 코드별 처리
      if (e is FirebaseFunctionsException) {
        AppLogger.debug('FirebaseFunctionsException 에러 코드 처리: ${e.code}');
        switch (e.code) {
          case 'failed-precondition':
            AppLogger.debug('failed-precondition 에러 처리');
            if (e.message?.contains('FCM 토큰') ?? false) {
              AppLogger.debug('FCM 토큰 관련 failed-precondition 에러');
              errorMessage =
                  'FCM 토큰이 없습니다. '
                  '알림 권한을 허용하고 앱을 완전히 재시작해주세요. '
                  '(iOS의 경우 APNS 토큰이 필요합니다)';
            } else {
              AppLogger.debug('일반 failed-precondition 에러');
              errorMessage = e.message ?? '전제 조건이 충족되지 않았습니다.';
            }
            break;
          case 'unauthenticated':
            AppLogger.debug('unauthenticated 에러 처리');
            errorMessage = '로그인이 필요합니다.';
            break;
          case 'not-found':
            AppLogger.debug('not-found 에러 처리');
            errorMessage = '사용자 정보를 찾을 수 없습니다.';
            break;
          case 'internal':
            AppLogger.debug('internal 에러 처리');
            // INTERNAL 에러의 경우 details에 더 자세한 정보가 있을 수 있음
            final details = e.details?.toString() ?? '';
            AppLogger.debug('INTERNAL 에러 details: $details');
            if (details.isNotEmpty) {
              errorMessage = 'Cloud Functions 내부 오류: $details';
              AppLogger.error('INTERNAL 에러 상세: $details', null);
            } else {
              errorMessage =
                  'Cloud Functions 내부 오류가 발생했습니다. '
                  '잠시 후 다시 시도해주세요. '
                  'Cloud Functions 로그를 확인해주세요.';
            }
            break;
          case 'deadline-exceeded':
            AppLogger.debug('deadline-exceeded 에러 처리');
            errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
            break;
          default:
            AppLogger.debug('알 수 없는 FirebaseFunctionsException 코드: ${e.code}');
            errorMessage = e.message ?? '알 수 없는 오류가 발생했습니다.';
        }
      } else {
        AppLogger.debug('FirebaseFunctionsException이 아닌 다른 에러 타입 처리');
        // 플랫폼 채널 연결 오류 처리
        AppLogger.debug('에러 문자열 분석 중: ${e.toString()}');
        if (e.toString().contains('Unable to establish connection') ||
            e.toString().contains('connection on channel')) {
          AppLogger.debug('플랫폼 채널 연결 오류 감지');
          errorMessage =
              '네트워크 연결을 확인할 수 없습니다. '
              '앱을 완전히 종료한 후 다시 실행해주세요. '
              '(핫 리로드가 아닌 완전 재시작 필요)';
        } else if (e.toString().contains('FCM 토큰이 없습니다') ||
            e.toString().contains('failed-precondition')) {
          AppLogger.debug('FCM 토큰 관련 에러 감지');
          errorMessage =
              'FCM 토큰이 없습니다. '
              '알림 권한을 허용하고 앱을 완전히 재시작해주세요.';
        } else if (e.toString().contains('인증이 필요합니다') ||
            e.toString().contains('인증') ||
            e.toString().contains('unauthenticated')) {
          AppLogger.debug('인증 관련 에러 감지');
          errorMessage = '로그인이 필요합니다.';
        } else if (e.toString().contains('사용자를 찾을 수 없습니다')) {
          AppLogger.debug('사용자 찾기 실패 에러 감지');
          errorMessage = '사용자 정보를 찾을 수 없습니다.';
        } else if (e.toString().contains('not found') ||
            e.toString().contains('404') ||
            e.toString().contains('NOT_FOUND')) {
          AppLogger.debug('리소스 찾기 실패 에러 감지');
          errorMessage =
              'Cloud Functions가 배포되지 않았습니다. '
              '관리자에게 문의해주세요.';
        } else if (e.toString().contains('TimeoutException') ||
            e.toString().contains('timeout')) {
          AppLogger.debug('타임아웃 에러 감지');
          errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
        } else {
          AppLogger.debug('알 수 없는 에러 패턴');
        }
      }

      AppLogger.debug('최종 에러 메시지: $errorMessage');
      final errorResponse = {
        'success': false,
        'message': errorMessage,
        'error': e.toString(),
      };
      AppLogger.debug('에러 응답 객체: $errorResponse');

      return errorResponse;
    }
  }

  /// 알림 유형별 테스트 알림 전송
  /// [notificationType]: test, official_notice, comment 중 하나
  Future<Map<String, dynamic>> sendTypedTestNotification(
    String notificationType,
  ) async {
    AppLogger.debug('=== 알림 유형별 테스트 시작 ===');
    AppLogger.debug('알림 유형: $notificationType');
    AppLogger.debug('현재 사용자 ID: $_currentUserId');
    AppLogger.debug(
      '현재 FCM 토큰: ${_fcmToken != null ? "${_fcmToken!.substring(0, _fcmToken!.length > 30 ? 30 : _fcmToken!.length)}..." : "null"}',
    );

    // 지원되는 알림 유형 확인
    final supportedTypes = ['test', 'official_notice', 'comment'];
    if (!supportedTypes.contains(notificationType)) {
      AppLogger.warning('지원하지 않는 알림 유형: $notificationType');
      return {
        'success': false,
        'message':
            '지원하지 않는 알림 유형입니다: $notificationType. '
            '지원 유형: ${supportedTypes.join(", ")}',
      };
    }

    try {
      AppLogger.notification('알림 유형별 테스트 전송 시작: $notificationType');
      AppLogger.debug('Cloud Function 호출 준비: sendTypedTestNotification');

      final callable = _functions.httpsCallable('sendTypedTestNotification');
      AppLogger.debug('Callable 생성 완료');

      final startTime = DateTime.now();
      AppLogger.debug('Cloud Function 호출 시작...');

      final result = await callable
          .call<Map<String, dynamic>>(<String, dynamic>{
            'type': notificationType,
          })
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              final elapsed = DateTime.now().difference(startTime);
              AppLogger.error('타임아웃 발생: 30초 내에 응답을 받지 못했습니다.', null);
              AppLogger.debug('경과 시간: ${elapsed.inSeconds}초');
              throw TimeoutException('테스트 알림 전송이 30초 내에 완료되지 않았습니다.');
            },
          );

      final elapsed = DateTime.now().difference(startTime);
      AppLogger.debug(
        'Cloud Function 호출 완료 (경과 시간: ${elapsed.inMilliseconds}ms)',
      );

      AppLogger.debug('응답 데이터: ${result.data}');
      AppLogger.notification('알림 유형별 테스트 전송 성공: ${result.data}');

      return {
        'success': true,
        'type': notificationType,
        'message':
            result.data['message'] ?? '$notificationType 테스트 알림이 전송되었습니다.',
        'messageId': result.data['messageId'],
      };
    } catch (e, stackTrace) {
      AppLogger.error('알림 유형별 테스트 전송 실패: $e', e, stackTrace);

      String errorMessage = '$notificationType 테스트 알림 전송에 실패했습니다.';

      if (e is FirebaseFunctionsException) {
        AppLogger.debug('FirebaseFunctionsException: code=${e.code}');
        switch (e.code) {
          case 'invalid-argument':
            errorMessage = e.message ?? '잘못된 알림 유형입니다.';
            break;
          case 'failed-precondition':
            errorMessage = e.message ?? 'FCM 토큰이 없습니다.';
            break;
          case 'unauthenticated':
            errorMessage = '로그인이 필요합니다.';
            break;
          case 'not-found':
            errorMessage = '사용자 정보를 찾을 수 없습니다.';
            break;
          default:
            errorMessage = e.message ?? '알 수 없는 오류가 발생했습니다.';
        }
      }

      return {
        'success': false,
        'type': notificationType,
        'message': errorMessage,
        'error': e.toString(),
      };
    }
  }

  /// 알림 유형 이름 가져오기 (UI 표시용)
  static String getNotificationTypeName(String type) {
    switch (type) {
      case 'test':
        return '기본 테스트';
      case 'official_notice':
        return '공지글 알림';
      case 'comment':
        return '댓글 알림';
      default:
        return type;
    }
  }

  /// 알림 유형 아이콘 가져오기 (UI 표시용)
  static String getNotificationTypeIcon(String type) {
    switch (type) {
      case 'test':
        return '🔔';
      case 'official_notice':
        return '📢';
      case 'comment':
        return '💬';
      default:
        return '📱';
    }
  }

  /// 지원되는 알림 유형 목록
  static List<String> get supportedNotificationTypes => [
    'test',
    'official_notice',
    'comment',
  ];

  /// 앱 뱃지 초기화 (앱 열었을 때 호출)
  static Future<void> clearBadge() async {
    try {
      final isSupported = await FlutterAppBadger.isAppBadgeSupported();
      if (isSupported) {
        await FlutterAppBadger.removeBadge();
        AppLogger.debug('[PushNotificationService] 앱 뱃지 삭제 완료');
      }
    } catch (e) {
      AppLogger.debug('[PushNotificationService] 앱 뱃지 삭제 실패: $e');
    }
  }
}
