import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';

/// 커뮤니티 홈 화면 (교회 선택)
class CommunityHomeScreen extends ConsumerWidget {
  const CommunityHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('コミュニティ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 소속 교회 섹션
          Text(
            '所属教会',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _CommunityParishCard(
            name: '東京カテドラル聖マリア大聖堂',
            postCount: 15,
            hasNewPosts: true,
            primaryColor: primaryColor,
            onTap: () {
              context.push(AppRoutes.communityParishPath('main-parish'));
            },
          ),

          const SizedBox(height: 24),

          // よく行く教会 섹션
          Text(
            'よく行く教会',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _CommunityParishCard(
            name: '聖イグナチオ教会',
            postCount: 8,
            hasNewPosts: false,
            primaryColor: primaryColor,
            onTap: () {
              context.push(AppRoutes.communityParishPath('favorite-1'));
            },
          ),
          const SizedBox(height: 8),
          _CommunityParishCard(
            name: '築地教会',
            postCount: 3,
            hasNewPosts: true,
            primaryColor: primaryColor,
            onTap: () {
              context.push(AppRoutes.communityParishPath('favorite-2'));
            },
          ),

          const SizedBox(height: 24),

          // 다른 교회 커뮤니티 검색
          OutlinedButton.icon(
            onPressed: () {
              context.push(AppRoutes.parishList);
            },
            icon: const Icon(Icons.search),
            label: const Text('他の教会のコミュニティを探す'),
          ),
        ],
      ),
    );
  }
}

class _CommunityParishCard extends StatelessWidget {
  final String name;
  final int postCount;
  final bool hasNewPosts;
  final Color primaryColor;
  final VoidCallback onTap;

  const _CommunityParishCard({
    required this.name,
    required this.postCount,
    required this.hasNewPosts,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.forum,
                      color: primaryColor,
                    ),
                  ),
                  if (hasNewPosts)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$postCount件の投稿',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
