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
        // FCM 토큰 가져오기
        _fcmToken = await _messaging.getToken();
        AppLogger.notification('토큰: $_fcmToken');

        // 토큰 갱신 리스너
        _messaging.onTokenRefresh.listen((newToken) {
          AppLogger.notification('토큰 갱신: $newToken');
          _fcmToken = newToken;
        });

        // 포그라운드 메시지 리스너
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // 백그라운드에서 알림 탭 리스너
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        // 앱이 종료된 상태에서 알림 탭으로 열린 경우
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageOpenedApp(initialMessage);
        }

        // iOS 포그라운드 알림 표시 설정
        if (Platform.isIOS) {
          await _messaging.setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('FCM 초기화 에러', e, stackTrace);
    }
  }

  /// 사용자 FCM 토큰 저장
  Future<void> saveTokenForUser(String userId) async {
    if (_fcmToken == null) {
      AppLogger.notification('토큰이 없어서 저장 불가');
      return;
    }

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
