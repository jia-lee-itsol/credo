/// 앱 라우트 경로 상수
class AppRoutes {
  AppRoutes._();

  // Root
  static const String splash = '/';
  static const String onboardingLanguage = '/onboarding/language';
  static const String onboardingLocation = '/onboarding/location';

  // Auth
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  // Main Tabs
  static const String home = '/home';
  static const String prayer = '/prayer';
  static const String dailyMass = '/daily-mass';
  static const String parishList = '/parish';
  static const String community = '/community';
  static const String myPage = '/my-page';

  // My Page
  static const String editProfile = '/my-page/edit-profile';
  static const String favoriteParishes = '/my-page/favorite-parishes';
  static const String qrScanner = '/my-page/qr-scanner';
  static const String languageSettings = '/my-page/language-settings';

  /// 파라미터가 포함된 경로 생성
  static String parishDetailPath(String parishId) => '/parish/$parishId';
  static String parishMapPath(String parishId) => '/parish/$parishId/map';
  static String communityParishPath(String parishId) => '/community/$parishId';
  static String postDetailPath(String parishId, String postId) =>
      '/community/$parishId/post/$postId';
  static String postCreatePath(String parishId) =>
      '/community/$parishId/post/create';
}
