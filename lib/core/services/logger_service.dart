import 'package:flutter/foundation.dart';

/// 중앙화된 로깅 서비스
///
/// 앱 전체에서 일관된 로깅을 제공하며, debug 모드에서만 로그를 출력합니다.
/// 각 기능별로 태그를 구분하여 로그를 관리합니다.
class AppLogger {
  static const bool _enableLogging = kDebugMode;

  /// 인증 관련 로그
  static void auth(String message) {
    _log('🔐 [Auth]', message);
  }

  /// 커뮤니티 관련 로그
  static void community(String message) {
    _log('📝 [Community]', message);
  }

  /// 알림 관련 로그
  static void notification(String message) {
    _log('🔔 [Notification]', message);
  }

  /// 성당 관련 로그
  static void parish(String message) {
    _log('⛪ [Parish]', message);
  }

  /// 프로필 관련 로그
  static void profile(String message) {
    _log('👤 [Profile]', message);
  }

  /// 이미지 업로드 관련 로그
  static void image(String message) {
    _log('🖼️ [Image]', message);
  }

  /// 에러 로그
  ///
  /// [message]: 에러 메시지
  /// [error]: 에러 객체 (선택사항)
  /// [stackTrace]: 스택 트레이스 (선택사항)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('❌ [Error]', message);
    if (error != null && _enableLogging) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// 경고 로그
  static void warning(String message) {
    _log('⚠️ [Warning]', message);
  }

  /// 정보 로그
  static void info(String message) {
    _log('ℹ️ [Info]', message);
  }

  /// 디버그 로그 (상세한 디버깅 정보)
  static void debug(String message) {
    _log('🐛 [Debug]', message);
  }

  /// 내부 로그 출력 메서드
  static void _log(String tag, String message) {
    if (_enableLogging) {
      debugPrint('$tag $message');
    }
  }
}
