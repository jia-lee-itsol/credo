import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';

/// 마이페이지 화면
class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () {
              _showSettingsBottomSheet(context, theme, primaryColor);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // 프로필 섹션
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 프로필 이미지
                CircleAvatar(
                  radius: 36,
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 16),

                // 프로필 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ゲスト',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ログインしてください',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // 편집 버튼
                IconButton(
                  onPressed: () {
                    context.push(AppRoutes.editProfile);
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),

          const Divider(),

          // 소속 교회
          _SettingsItem(
            icon: Icons.church,
            title: '所属教会',
            subtitle: '東京カテドラル聖マリア大聖堂',
            primaryColor: primaryColor,
            onTap: () {
              // TODO: 소속 교회 설정
            },
          ),

          // よく行く教회
          _SettingsItem(
            icon: Icons.favorite,
            title: 'よく行く教会',
            subtitle: '2件登録済み',
            primaryColor: primaryColor,
            onTap: () {
              // TODO: よく行く教会 설정
            },
          ),

          const SizedBox(height: 24),

          // 로그인/로그아웃 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () {
                context.push(AppRoutes.signIn);
              },
              child: const Text('ログイン'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),

              // 타이틀
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '設定',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 알림 설정
              _SettingsItem(
                icon: Icons.notifications,
                title: '通知設定',
                primaryColor: primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 알림 설정
                },
              ),

              // 언어 설정
              _SettingsItem(
                icon: Icons.language,
                title: '言語設定',
                subtitle: '日本語',
                primaryColor: primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 언어 설정
                },
              ),

              const Divider(),

              // 이용 규약
              _SettingsItem(
                icon: Icons.description,
                title: '利用規約',
                primaryColor: primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 이용 규약
                },
              ),

              // 개인정보 처리방침
              _SettingsItem(
                icon: Icons.privacy_tip,
                title: 'プライバシーポリシー',
                primaryColor: primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 개인정보 처리방침
                },
              ),

              // 앱 정보
              _SettingsItem(
                icon: Icons.info,
                title: 'アプリについて',
                subtitle: 'Credo v1.0.0',
                primaryColor: primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'Credo',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 Credo',
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        '日本全国のカトリック教会と信者をつなぐコミュニティアプリです。',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color primaryColor;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
