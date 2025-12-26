import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_localizations.dart';
import '../../shared/utils/page_transitions.dart';

import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../../features/onboarding/presentation/screens/location_permission_screen.dart';
import '../../features/prayer/presentation/screens/prayer_screen.dart';
import '../../features/mass/presentation/screens/daily_mass_screen.dart';
import '../../features/saints/presentation/screens/today_saints_screen.dart';
import '../../features/saints/presentation/screens/saint_detail_screen.dart';
import '../../features/parish/presentation/screens/parish_list_screen.dart';
import '../../features/parish/presentation/screens/parish_detail_screen.dart';
import '../../features/community/presentation/screens/community_home_screen.dart';
import '../../features/community/presentation/screens/post_list_screen.dart';
import '../../features/community/presentation/screens/post_detail_screen.dart';
import '../../features/community/presentation/screens/post_create_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/chat_info_screen.dart';
import '../../features/chat/presentation/screens/new_chat_screen.dart';
import '../../features/chat/presentation/screens/friend_list_screen.dart';
import '../../features/chat/presentation/screens/user_profile_screen.dart';
import '../../features/profile/presentation/screens/my_page_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/favorite_parishes_screen.dart';
import '../../features/profile/presentation/screens/qr_scanner_screen.dart';
import '../../features/profile/presentation/screens/language_settings_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/church_faq_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import 'app_routes.dart';

/// GoRouter Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      // 스플래시 화면은 redirect에서 제외
      if (state.matchedLocation == AppRoutes.splash) {
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;

      final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');

      if (onboardingCompleted && isOnboardingRoute) {
        return AppRoutes.home;
      }

      if (!onboardingCompleted && !isOnboardingRoute) {
        return AppRoutes.onboardingLanguage;
      }

      return null;
    },
    routes: [
      // 스플래시 화면
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 온보딩 화면
      GoRoute(
        path: AppRoutes.onboardingLanguage,
        name: 'onboardingLanguage',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingLocation,
        name: 'onboardingLocation',
        builder: (context, state) => const LocationPermissionScreen(),
      ),

      // 인증 화면
      GoRoute(
        path: AppRoutes.signIn,
        name: 'signIn',
        pageBuilder: (context, state) => BottomSlideTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        pageBuilder: (context, state) => SlideTransitionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
        ),
      ),

      // 메인 셸 라우트 (하단 네비게이션 포함)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 홈 브랜치
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: AppRoutes.todaySaints,
                name: 'todaySaints',
                pageBuilder: (context, state) => SlideTransitionPage(
                  key: state.pageKey,
                  child: const TodaySaintsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: ':saintId',
                    name: 'saintDetail',
                    pageBuilder: (context, state) {
                      final saintId = state.pathParameters['saintId']!;
                      return SlideTransitionPage(
                        key: state.pageKey,
                        child: SaintDetailScreen(saintId: saintId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // 묵상 브랜치
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.prayer,
                name: 'prayer',
                builder: (context, state) => const PrayerScreen(),
              ),
            ],
          ),

          // 일일 미사 브랜치
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dailyMass,
                name: 'dailyMass',
                builder: (context, state) => const DailyMassScreen(),
              ),
            ],
          ),

          // 성당 브랜치
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.parishList,
                name: 'parishList',
                builder: (context, state) => const ParishListScreen(),
                routes: [
                  GoRoute(
                    path: ':parishId',
                    name: 'parishDetail',
                    pageBuilder: (context, state) {
                      final parishId = state.pathParameters['parishId']!;
                      final uniqueKey = ValueKey('parishDetail_${state.uri}');
                      return SlideTransitionPage(
                        key: state.pageKey,
                        child: ParishDetailScreen(
                          key: uniqueKey,
                          parishId: parishId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // 커뮤니티 브랜치
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.community,
                name: 'community',
                builder: (context, state) => const CommunityHomeScreen(),
                routes: [
                  GoRoute(
                    path: ':parishId',
                    name: 'communityParish',
                    pageBuilder: (context, state) {
                      final parishId = state.pathParameters['parishId']!;
                      return SlideTransitionPage(
                        key: state.pageKey,
                        child: PostListScreen(parishId: parishId),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'post/create',
                        name: 'postCreate',
                        pageBuilder: (context, state) {
                          final parishId = state.pathParameters['parishId']!;
                          return BottomSlideTransitionPage(
                            key: state.pageKey,
                            child: PostCreateScreen(parishId: parishId),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'post/:postId',
                        name: 'postDetail',
                        pageBuilder: (context, state) {
                          final parishId = state.pathParameters['parishId']!;
                          final postId = state.pathParameters['postId']!;
                          return SlideTransitionPage(
                            key: state.pageKey,
                            child: PostDetailScreen(
                              parishId: parishId,
                              postId: postId,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // 채팅 라우트
      GoRoute(
        path: AppRoutes.chatList,
        name: 'chatList',
        pageBuilder: (context, state) => SlideTransitionPage(
          key: state.pageKey,
          child: const ChatListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            name: 'newChat',
            pageBuilder: (context, state) => BottomSlideTransitionPage(
              key: state.pageKey,
              child: const NewChatScreen(),
            ),
          ),
          GoRoute(
            path: ':conversationId',
            name: 'chat',
            pageBuilder: (context, state) {
              final conversationId = state.pathParameters['conversationId']!;
              return SlideTransitionPage(
                key: state.pageKey,
                child: ChatScreen(conversationId: conversationId),
              );
            },
            routes: [
              GoRoute(
                path: 'info',
                name: 'chatInfo',
                pageBuilder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  return SlideTransitionPage(
                    key: state.pageKey,
                    child: ChatInfoScreen(conversationId: conversationId),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // 친구 라우트
      GoRoute(
        path: AppRoutes.friendList,
        name: 'friendList',
        pageBuilder: (context, state) => SlideTransitionPage(
          key: state.pageKey,
          child: const FriendListScreen(),
        ),
      ),

      // 유저 프로필 라우트
      GoRoute(
        path: '/user/:userId',
        name: 'userProfile',
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return SlideTransitionPage(
            key: state.pageKey,
            child: UserProfileScreen(userId: userId),
          );
        },
      ),

      // 마이페이지 라우트 (셸 외부 - 하단 네비게이션 포함)
      GoRoute(
        path: AppRoutes.myPage,
        name: 'myPage',
        pageBuilder: (context, state) => SlideTransitionPage(
          key: state.pageKey,
          child: const MyPageScreen(),
        ),
        routes: [
          GoRoute(
            path: 'edit-profile',
            name: 'editProfile',
            pageBuilder: (context, state) => SlideTransitionPage(
              key: state.pageKey,
              child: const EditProfileScreen(),
            ),
          ),
          GoRoute(
            path: 'favorite-parishes',
            name: 'favoriteParishes',
            pageBuilder: (context, state) => SlideTransitionPage(
              key: state.pageKey,
              child: const FavoriteParishesScreen(
                key: ValueKey('favoriteParishesScreen'),
              ),
            ),
            routes: [
              GoRoute(
                path: 'parish/:parishId',
                name: 'favoriteParishDetail',
                pageBuilder: (context, state) {
                  final parishId = state.pathParameters['parishId']!;
                  final uniqueKey = ValueKey(
                    'favoriteParishDetail_${state.uri}',
                  );
                  return SlideTransitionPage(
                    key: state.pageKey,
                    child: ParishDetailScreen(key: uniqueKey, parishId: parishId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'church-faq',
            name: 'churchFaq',
            pageBuilder: (context, state) => SlideTransitionPage(
              key: state.pageKey,
              child: const ChurchFaqScreen(),
            ),
          ),
          GoRoute(
            path: 'qr-scanner',
            name: 'qrScanner',
            pageBuilder: (context, state) => BottomSlideTransitionPage(
              key: state.pageKey,
              child: const QrScannerScreen(),
            ),
          ),
          GoRoute(
            path: 'language-settings',
            name: 'languageSettings',
            pageBuilder: (context, state) => SlideTransitionPage(
              key: state.pageKey,
              child: const LanguageSettingsScreen(),
            ),
          ),
          GoRoute(
            path: 'notification-settings',
            name: 'notificationSettings',
            pageBuilder: (context, state) => SlideTransitionPage(
              key: state.pageKey,
              child: const NotificationSettingsScreen(),
            ),
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final l10n = ref.read(appLocalizationsSyncProvider);
                return Column(
                  children: [
                    Text(
                      l10n.common.pageNotFound,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.uri.toString(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: Text(l10n.common.backToHome),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
});
