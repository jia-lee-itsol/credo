import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/parish_service.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/widgets/settings_list_tile.dart';
import '../widgets/qr_code_dialog.dart';

/// 마이페이지 화면
class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentUserProvider);
    final mainParishId = currentUser?.mainParishId;

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
      appBar: AppBar(title: const Text('マイページ')),
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
                    title: 'QRコードで共有',
                    subtitle: 'プロフィールをQRコードで共有',
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
              title: 'よく行く教会',
              subtitle: isAuthenticated
                  ? '${currentUser?.favoriteParishIds.length ?? 0}件登録済み'
                  : 'ログインが必要です',
              primaryColor: primaryColor,
              onTap: () {
                if (isAuthenticated) {
                  context.push(AppRoutes.favoriteParishes);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ログインが必要です'),
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
              title: '通知設定',
              primaryColor: primaryColor,
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('通知設定は準備中です')));
              },
            ),
          ),

          // 언어 설정
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsListTile(
              icon: Icons.language,
              title: '言語設定',
              subtitle: _getLanguageDisplayName(
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

          // 이용 규약
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsListTile(
              icon: Icons.description,
              title: '利用規約',
              primaryColor: primaryColor,
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('利用規約は準備中です')));
              },
            ),
          ),

          // 개인정보 처리방침
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsListTile(
              icon: Icons.privacy_tip,
              title: 'プライバシーポリシー',
              primaryColor: primaryColor,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('プライバシーポリシーは準備中です')),
                );
              },
            ),
          ),

          // 앱 정보
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SettingsListTile(
              icon: Icons.info,
              title: 'アプリについて',
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
                    const Text('日本全国のカトリック教会と信者をつなぐコミュニティアプリです。'),
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
                isAuthenticated ? 'ログアウト' : 'ログイン',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '祈り',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'ミサ',
          ),
          NavigationDestination(
            icon: Icon(Icons.church_outlined),
            selectedIcon: Icon(Icons.church),
            label: '教会',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'コミュニティ',
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
                      Text(
                        isAuthenticated
                            ? (currentUser?.nickname ?? 'ユーザー')
                            : 'ゲスト',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAuthenticated
                            ? (currentUser?.email ?? '')
                            : 'ログインしてください',
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
                              const SnackBar(
                                content: Text('ユーザーIDをコピーしました'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            'ユーザーID: ${currentUser.userId}',
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

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ログアウトしました'),
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
    if (mainParishId == null) {
      return Row(
        children: [
          Icon(Icons.church, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '未設定',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    final parishAsync = ref.watch(parishByIdProvider(mainParishId));

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
      error: (_, __) => Row(
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
  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '日本語';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      case 'vi':
        return 'Tiếng Việt';
      case 'ko':
        return '한국어';
      case 'es':
        return 'Español';
      case 'pt':
        return 'Português';
      default:
        return '日本語';
    }
  }
}
