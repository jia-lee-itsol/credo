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

  // Settings
  static const String settings = '/settings';

  // Parish
  static const String parishDetail = '/parish/:parishId';
  static const String parishMap = '/parish/:parishId/map';

  // Community
  static const String communityParish = '/community/:parishId';
  static const String postDetail = '/community/:parishId/post/:postId';
  static const String postCreate = '/community/:parishId/post/create';

  // My Page
  static const String editProfile = '/my-page/edit-profile';
  static const String parishSettings = '/my-page/parish-settings';
  static const String notificationSettings = '/my-page/notification-settings';
  static const String languageSettings = '/my-page/language-settings';
  static const String termsOfService = '/my-page/terms';
  static const String privacyPolicy = '/my-page/privacy';

  /// 파라미터가 포함된 경로 생성
  static String parishDetailPath(String parishId) => '/parish/$parishId';
  static String parishMapPath(String parishId) => '/parish/$parishId/map';
  static String communityParishPath(String parishId) => '/community/$parishId';
  static String postDetailPath(String parishId, String postId) =>
      '/community/$parishId/post/$postId';
  static String postCreatePath(String parishId) =>
      '/community/$parishId/post/create';
}
