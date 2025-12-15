import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/parish_service.dart' as core;
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/font_scale_provider.dart';
import '../../../../shared/widgets/settings_list_tile.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../widgets/qr_code_dialog.dart';

/// 마이페이지 화면
class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentUserProvider);
    final mainParishId = currentUser?.mainParishId;

    // 인증 상태 디버깅
    AppLogger.profile('빌드됨');
    AppLogger.profile('isAuthenticated: $isAuthenticated');
    AppLogger.profile('currentUser: ${currentUser?.userId ?? 'null'}');
    if (currentUser != null) {
      AppLogger.profile(
        '사용자 정보: userId=${currentUser.userId}, email=${currentUser.email}, nickname=${currentUser.nickname}',
      );
    }

    // 현재 경로를 기반으로 선택된 탭 인덱스 결정
    final currentLocation = GoRouterState.of(context).matchedLocation;
    int selectedIndex = 0;
    if (currentLocation.startsWith(AppRoutes.home)) {
      selectedIndex = 0;
    } else if (currentLocation.startsWith(AppRoutes.prayer)) {
      selectedIndex = 1;
    } else if (currentLocation.startsWith(AppRoutes.dailyMass)) {
      selectedIndex = 2;
    } else if (currentLocation.startsWith(AppRoutes.parishList)) {
      selectedIndex = 3;
    } else if (currentLocation.startsWith(AppRoutes.community)) {
      selectedIndex = 4;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(l10n.profile.myPage)),
      body: ListView(
        children: [
          // 프로필 섹션
          _buildProfileSection(
            context,
            theme,
            primaryColor,
            isAuthenticated,
            currentUser,
            ref,
            mainParishId,
          ),

          // QR 코드 관련 카드
          if (isAuthenticated) ...[
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SettingsListTile(
                    icon: Icons.qr_code,
                    title: l10n.profile.shareProfileQR,
                    subtitle: l10n.profile.shareProfileQR,
                    primaryColor: primaryColor,
                    onTap: () {
                      if (currentUser != null) {
                        QrCodeBottomSheet.show(
                          context,
                          userId: currentUser.userId,
                          nickname: currentUser.nickname,
                          primaryColor: primaryColor,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],

          // よく行く教회
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsListTile(
              icon: Icons.favorite,
              title: l10n.profile.favoriteParishes,
              subtitle: isAuthenticated
                  ? l10n.profile.favoriteParishesSection.registeredCount(
                      currentUser?.favoriteParishIds.length ?? 0,
                    )
                  : l10n.profile.loginRequired,
              primaryColor: primaryColor,
              onTap: () {
                if (isAuthenticated) {
                  context.push(AppRoutes.favoriteParishes);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.profile.loginRequired),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ),

          // 알림 설정
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsListTile(
              icon: Icons.notifications,
              title: l10n.profile.notificationSettings,
              primaryColor: primaryColor,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.profile.notificationSettingsComingSoon),
                  ),
                );
              },
            ),
          ),

          // 언어 설정
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsListTile(
              icon: Icons.language,
              title: l10n.profile.languageSettings,
              subtitle: _getLanguageDisplayName(
                ref,
                currentUser?.preferredLanguages.isNotEmpty == true
                    ? currentUser!.preferredLanguages.first
                    : 'ja',
              ),
              primaryColor: primaryColor,
              onTap: () {
                context.push(AppRoutes.languageSettings);
              },
            ),
          ),

          // 글씨 크기 설정
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _FontScaleSettingsTile(primaryColor: primaryColor),
          ),

          // 이용 규약
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsListTile(
              icon: Icons.description,
              title: l10n.profile.termsOfService,
              primaryColor: primaryColor,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.profile.termsOfServiceComingSoon),
                  ),
                );
              },
            ),
          ),

          // 개인정보 처리방침
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsListTile(
              icon: Icons.privacy_tip,
              title: l10n.profile.privacyPolicy,
              primaryColor: primaryColor,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.profile.privacyPolicyComingSoon)),
                );
              },
            ),
          ),

          // 앱 정보
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsListTile(
              icon: Icons.info,
              title: l10n.profile.aboutApp,
              subtitle: 'Credo v1.0.0',
              primaryColor: primaryColor,
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Credo',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 Credo',
                  children: [
                    const SizedBox(height: 16),
                    Text(l10n.app.description),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 로그인/로그아웃 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () async {
                if (isAuthenticated) {
                  // 로그아웃
                  await _handleSignOut(context, ref);
                } else {
                  // 로그인 페이지로 이동
                  context.push(AppRoutes.signIn);
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor),
              ),
              child: Text(
                isAuthenticated ? l10n.auth.signOut : l10n.auth.signIn,
                style: TextStyle(color: primaryColor),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        height: 72, // 네비게이션 바 높이 증가 (라벨 포함)
        indicatorShape: const CircleBorder(), // 정원형 배경
        indicatorColor: primaryColor.withValues(alpha: 0.2), // 배경 색상
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          // 선택된 항목의 라벨 색상
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: primaryColor);
          }
          // 선택되지 않은 항목의 라벨 색상
          return TextStyle(color: theme.colorScheme.onSurfaceVariant);
        }),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              context.go(AppRoutes.prayer);
              break;
            case 2:
              context.go(AppRoutes.dailyMass);
              break;
            case 3:
              context.go(AppRoutes.parishList);
              break;
            case 4:
              context.go(AppRoutes.community);
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navigation.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.navigation.meditation,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add),
            selectedIcon: const Icon(Icons.add),
            label: l10n.navigation.share,
          ),
          NavigationDestination(
            icon: const Icon(Icons.church_outlined),
            selectedIcon: const Icon(Icons.church),
            label: l10n.navigation.church,
          ),
          NavigationDestination(
            icon: const Icon(Icons.forum_outlined),
            selectedIcon: const Icon(Icons.forum),
            label: l10n.navigation.community,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    bool isAuthenticated,
    currentUser,
    WidgetRef ref,
    String? mainParishId,
  ) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // 프로필 이미지
                CircleAvatar(
                  radius: 36,
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                  child: Icon(Icons.person, size: 36, color: primaryColor),
                ),
                const SizedBox(width: 16),

                // 프로필 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isAuthenticated
                                  ? (currentUser?.nickname ?? 'ユーザー')
                                  : 'ゲスト',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isAuthenticated &&
                              currentUser != null &&
                              currentUser.isVerified) ...[
                            const SizedBox(width: 8),
                            BadgeChip.official(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAuthenticated
                            ? (currentUser?.email ?? '')
                            : l10n.profile.pleaseLogin,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isAuthenticated && currentUser != null) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(
                              ClipboardData(text: currentUser.userId),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.profile.userIdCopied),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            '${l10n.profile.userId}: ${currentUser.userId}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 편집 버튼 (로그인 상태일 때만 표시)
                if (isAuthenticated)
                  IconButton(
                    onPressed: () {
                      context.push(AppRoutes.editProfile);
                    },
                    icon: const Icon(Icons.edit),
                  ),
              ],
            ),

            // 소속 본당 (프로필 하단)
            if (isAuthenticated) ...[
              const SizedBox(height: 16),
              _buildMainParishRow(
                context,
                ref,
                theme,
                primaryColor,
                mainParishId,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signOut();

    if (!context.mounted) return;

    final l10n = ref.read(appLocalizationsSyncProvider);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.auth.signOutSuccess),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Widget _buildMainParishRow(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Color primaryColor,
    String? mainParishId,
  ) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    if (mainParishId == null) {
      return Row(
        children: [
          Icon(Icons.church, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.common.notSet,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    final parishAsync = ref.watch(core.parishByIdProvider(mainParishId));

    return parishAsync.when(
      data: (parish) {
        final parishName = parish?['name'] as String? ?? '未設定';
        return Row(
          children: [
            Icon(Icons.church, size: 20, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                parishName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Icon(Icons.church, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          const Expanded(child: Text('読み込み中...')),
        ],
      ),
      error: (_, _) => Row(
        children: [
          Icon(Icons.church, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'エラー',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 언어 코드를 표시 이름으로 변환
  String _getLanguageDisplayName(WidgetRef ref, String languageCode) {
    final l10n = ref.read(appLocalizationsSyncProvider);
    final names = l10n.language.names;

    switch (languageCode) {
      case 'ja':
        return names.japanese;
      case 'en':
        return names.english;
      case 'zh':
        return names.chinese;
      case 'vi':
        return names.vietnamese;
      case 'ko':
        return names.korean;
      case 'es':
        return names.spanish;
      case 'pt':
        return names.portuguese;
      default:
        return names.japanese;
    }
  }
}

/// 글씨 크기 설정 타일
class _FontScaleSettingsTile extends ConsumerWidget {
  final Color primaryColor;

  const _FontScaleSettingsTile({required this.primaryColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = ref.watch(fontScaleProvider);
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, color: primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.profile.fontSize,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.common.small),
              Expanded(
                child: Slider(
                  value: fontScale,
                  min: 0.85,
                  max: 1.4,
                  divisions: 11,
                  activeColor: primaryColor,
                  label: _getFontScaleLabel(fontScale, l10n),
                  onChanged: (value) {
                    ref.read(fontScaleProvider.notifier).setFontScale(value);
                  },
                ),
              ),
              Text(l10n.common.large),
            ],
          ),
          Center(
            child: Text(
              l10n.common.sampleText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16 * fontScale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFontScaleLabel(double scale, AppLocalizations l10n) {
    if (scale <= 0.9) return l10n.common.small;
    if (scale <= 1.05) return l10n.common.medium;
    if (scale <= 1.2) return l10n.common.large;
    return l10n.common.extraLarge;
  }
}
