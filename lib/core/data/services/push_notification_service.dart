import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  String? _fcmToken;
  GoRouter? _router;
  String? _currentUserId;

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
          // iOS 시뮬레이터에서는 토큰을 가져올 수 없을 수 있음
          if (Platform.isIOS) {
            AppLogger.warning(
              'iOS 시뮬레이터에서는 FCM 토큰을 가져올 수 없을 수 있습니다. 실제 기기에서 테스트해주세요.',
            );
          }
          // 토큰이 없어도 리스너는 설정 (나중에 토큰이 생성될 수 있음)
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
      }
      AppLogger.notification('토큰이 아직 준비되지 않았습니다. 토큰이 준비되면 자동으로 저장됩니다.');
      // 토큰이 나중에 준비되면 자동으로 저장되도록 _currentUserId는 설정해둠
      // onTokenRefresh 리스너에서 자동으로 저장됨
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
}
