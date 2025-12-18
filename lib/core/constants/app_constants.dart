/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  // 앱 정보
  static const String appName = 'Credo';
  static const String appVersion = '1.0.0';

  // 페이지네이션
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // 유효성 검사
  static const int nicknameMinLength = 1;
  static const int nicknameMaxLength = 20;
  static const int postTitleMaxLength = 50;
  static const int postContentMaxLength = 2000;
  static const int commentMaxLength = 500;

  // 캐시 지속 시간
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration parishCacheDuration = Duration(days: 1);

  // 위치
  static const double defaultLatitude = 35.6762; // 도쿄
  static const double defaultLongitude = 139.6503;
  static const double nearbyRadiusKm = 10.0;

  // 타임아웃
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
}

/// 미사 언어 코드
class MassLanguage {
  MassLanguage._();

  static const String japanese = 'JP';
  static const String english = 'EN';
  static const String filipino = 'PH';
  static const String portuguese = 'PT';
  static const String vietnamese = 'VI';
  static const String korean = 'KR';

  static const List<String> all = [
    japanese,
    english,
    filipino,
    portuguese,
    vietnamese,
    korean,
  ];

  static String getDisplayName(String code) {
    switch (code) {
      case japanese:
        return '日本語';
      case english:
        return 'English';
      case filipino:
        return 'Filipino';
      case portuguese:
        return 'Português';
      case vietnamese:
        return 'Tiếng Việt';
      case korean:
        return '한국어';
      default:
        return code;
    }
  }
}

/// 요일 상수
class Weekday {
  Weekday._();

  static const int sunday = 0;
  static const int monday = 1;
  static const int tuesday = 2;
  static const int wednesday = 3;
  static const int thursday = 4;
  static const int friday = 5;
  static const int saturday = 6;

  static String getDisplayName(int weekday, {String locale = 'ja'}) {
    if (locale == 'ja') {
      const names = ['日', '月', '火', '水', '木', '金', '土'];
      return names[weekday % 7];
    } else {
      const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return names[weekday % 7];
    }
  }
}
