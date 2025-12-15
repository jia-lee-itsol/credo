import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_localizations.dart';

import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../../features/onboarding/presentation/screens/location_permission_screen.dart';
import '../../features/prayer/presentation/screens/prayer_screen.dart';
import '../../features/mass/presentation/screens/daily_mass_screen.dart';
import '../../features/parish/presentation/screens/parish_list_screen.dart';
import '../../features/parish/presentation/screens/parish_detail_screen.dart';
import '../../features/community/presentation/screens/community_home_screen.dart';
import '../../features/community/presentation/screens/post_list_screen.dart';
import '../../features/community/presentation/screens/post_detail_screen.dart';
import '../../features/community/presentation/screens/post_create_screen.dart';
import '../../features/profile/presentation/screens/my_page_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/favorite_parishes_screen.dart';
import '../../features/profile/presentation/screens/qr_scanner_screen.dart';
import '../../features/profile/presentation/screens/language_settings_screen.dart';
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
      // Splash Route
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Routes
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

      // Auth Routes
      GoRoute(
        path: AppRoutes.signIn,
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main Shell Route with Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Prayer Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.prayer,
                name: 'prayer',
                builder: (context, state) => const PrayerScreen(),
              ),
            ],
          ),

          // Daily Mass Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dailyMass,
                name: 'dailyMass',
                builder: (context, state) => const DailyMassScreen(),
              ),
            ],
          ),

          // Parish Branch
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
                    builder: (context, state) {
                      final parishId = state.pathParameters['parishId']!;
                      // 전체 경로를 포함하여 더 고유한 key 생성
                      final uniqueKey = ValueKey('parishDetail_${state.uri}');
                      return ParishDetailScreen(
                        key: uniqueKey,
                        parishId: parishId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Community Branch
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
                    builder: (context, state) {
                      final parishId = state.pathParameters['parishId']!;
                      return PostListScreen(parishId: parishId);
                    },
                    routes: [
                      GoRoute(
                        path: 'post/create',
                        name: 'postCreate',
                        builder: (context, state) {
                          final parishId = state.pathParameters['parishId']!;
                          return PostCreateScreen(parishId: parishId);
                        },
                      ),
                      GoRoute(
                        path: 'post/:postId',
                        name: 'postDetail',
                        builder: (context, state) {
                          final parishId = state.pathParameters['parishId']!;
                          final postId = state.pathParameters['postId']!;
                          return PostDetailScreen(
                            parishId: parishId,
                            postId: postId,
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

      // My Page Route (outside shell - with bottom navigation)
      GoRoute(
        path: AppRoutes.myPage,
        name: 'myPage',
        builder: (context, state) => const MyPageScreen(),
        routes: [
          GoRoute(
            path: 'edit-profile',
            name: 'editProfile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'favorite-parishes',
            name: 'favoriteParishes',
            builder: (context, state) => const FavoriteParishesScreen(
              key: ValueKey('favoriteParishesScreen'),
            ),
            routes: [
              // 자주 가는 교회에서 교회 상세로 이동할 수 있도록 중첩 라우트 추가
              GoRoute(
                path: 'parish/:parishId',
                name: 'favoriteParishDetail',
                builder: (context, state) {
                  final parishId = state.pathParameters['parishId']!;
                  final uniqueKey = ValueKey(
                    'favoriteParishDetail_${state.uri}',
                  );
                  return ParishDetailScreen(key: uniqueKey, parishId: parishId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'qr-scanner',
            name: 'qrScanner',
            builder: (context, state) => const QrScannerScreen(),
          ),
          GoRoute(
            path: 'language-settings',
            name: 'languageSettings',
            builder: (context, state) => const LanguageSettingsScreen(),
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
