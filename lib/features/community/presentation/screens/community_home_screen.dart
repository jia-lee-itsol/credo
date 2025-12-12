import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../parish/presentation/providers/parish_presentation_providers.dart';
import '../../data/providers/community_repository_providers.dart';

/// 커뮤니티 홈 화면 (교회 선택)
class CommunityHomeScreen extends ConsumerWidget {
  const CommunityHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);
    final mainParishId = currentUser?.mainParishId;

    // 소속 교회 정보 가져오기
    final mainParishAsync = mainParishId != null
        ? ref.watch(parishByIdEntityProvider(mainParishId))
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('コミュニティ'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.myPage);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                backgroundImage: currentUser?.profileImageUrl != null
                    ? NetworkImage(currentUser!.profileImageUrl!)
                    : null,
                child: currentUser?.profileImageUrl == null
                    ? Icon(Icons.person, size: 20, color: primaryColor)
                    : null,
              ),
            ),
          ),
        ],
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
          if (mainParishId != null && mainParishAsync != null)
            mainParishAsync.when(
              data: (parish) {
                if (parish == null) {
                  return _buildEmptyParishCard('所属教会が設定されていません', primaryColor);
                }
                // 게시글 수와 새 게시글 여부 가져오기
                final postCountAsync = ref.watch(
                  postCountProvider(mainParishId),
                );
                final hasNewPostsAsync = ref.watch(
                  hasNewPostsProvider(mainParishId),
                );

                return postCountAsync.when(
                  data: (postCount) {
                    return hasNewPostsAsync.when(
                      data: (hasNewPosts) => _CommunityParishCard(
                        name: parish.name,
                        postCount: postCount,
                        hasNewPosts: hasNewPosts,
                        primaryColor: primaryColor,
                        parishId: mainParishId,
                        onTap: () {
                          // 마지막 읽은 타임스탬프 업데이트
                          updateLastReadTimestamp(mainParishId);
                          context.push(
                            AppRoutes.communityParishPath(mainParishId),
                          );
                        },
                      ),
                      loading: () => _CommunityParishCard(
                        name: parish.name,
                        postCount: postCount,
                        hasNewPosts: false,
                        primaryColor: primaryColor,
                        parishId: mainParishId,
                        onTap: () {
                          updateLastReadTimestamp(mainParishId);
                          context.push(
                            AppRoutes.communityParishPath(mainParishId),
                          );
                        },
                      ),
                      error: (error, stackTrace) => _CommunityParishCard(
                        name: parish.name,
                        postCount: postCount,
                        hasNewPosts: false,
                        primaryColor: primaryColor,
                        parishId: mainParishId,
                        onTap: () {
                          updateLastReadTimestamp(mainParishId);
                          context.push(
                            AppRoutes.communityParishPath(mainParishId),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) => _CommunityParishCard(
                    name: parish.name,
                    postCount: 0,
                    hasNewPosts: false,
                    primaryColor: primaryColor,
                    parishId: mainParishId,
                    onTap: () {
                      updateLastReadTimestamp(mainParishId);
                      context.push(AppRoutes.communityParishPath(mainParishId));
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) =>
                  _buildEmptyParishCard('所属教会の情報を読み込めませんでした', primaryColor),
            )
          else
            _buildEmptyParishCard('所属教会が設定されていません', primaryColor),

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

/// 소속 교회가 없을 때 표시할 카드
Widget _buildEmptyParishCard(String message, Color primaryColor) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    ),
  );
}

class _CommunityParishCard extends StatelessWidget {
  final String name;
  final int postCount;
  final bool hasNewPosts;
  final Color primaryColor;
  final String parishId;
  final VoidCallback onTap;

  const _CommunityParishCard({
    required this.name,
    required this.postCount,
    required this.hasNewPosts,
    required this.primaryColor,
    required this.parishId,
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
                    child: Icon(Icons.forum, color: primaryColor),
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
                    Text('$postCount件の投稿', style: theme.textTheme.bodySmall),
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
