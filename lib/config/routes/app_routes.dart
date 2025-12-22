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

  // 메인 탭
  static const String home = '/home';
  static const String prayer = '/prayer';
  static const String dailyMass = '/daily-mass';
  static const String todaySaints = '/today-saints';
  static const String parishList = '/parish';
  static const String community = '/community';
  static const String myPage = '/my-page';

  // 마이페이지
  static const String editProfile = '/my-page/edit-profile';
  static const String favoriteParishes = '/my-page/favorite-parishes';
  static const String qrScanner = '/my-page/qr-scanner';
  static const String languageSettings = '/my-page/language-settings';
  static const String notificationSettings = '/my-page/notification-settings';

  // 채팅
  static const String chatList = '/chat';
  static const String newChat = '/chat/new';
  static String chatPath(String conversationId) => '/chat/$conversationId';
  static String chatInfoPath(String conversationId) => '/chat/$conversationId/info';

  // 친구
  static const String friendList = '/friends';
  static String userProfilePath(String userId) => '/user/$userId';

  /// 파라미터가 포함된 경로 생성
  static String parishDetailPath(String parishId) => '/parish/$parishId';
  static String parishMapPath(String parishId) => '/parish/$parishId/map';
  static String communityParishPath(String parishId) => '/community/$parishId';
  static String postDetailPath(String parishId, String postId) =>
      '/community/$parishId/post/$postId';
  static String postCreatePath(String parishId) =>
      '/community/$parishId/post/create';
  static String saintDetailPath(String saintId) => '/today-saints/$saintId';
}
