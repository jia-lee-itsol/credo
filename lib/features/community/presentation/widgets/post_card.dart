import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../chat/presentation/providers/friend_providers.dart';

/// 게시글 카드 위젯
class PostCard extends ConsumerWidget {
  final String title;
  final String content;
  final String author;
  final String authorId;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isOfficial;
  final bool isPinned;
  final Color primaryColor;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.authorId,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isOfficial,
    required this.isPinned,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // 실시간 업데이트를 위해 StreamProvider 사용
    final userAsync = ref.watch(userByIdStreamProvider(authorId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 배지들
              if (isPinned || isOfficial)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      if (isPinned) ...[
                        BadgeChip.pinned(),
                        if (isOfficial) const SizedBox(width: 8),
                      ],
                      if (isOfficial) BadgeChip.official(),
                    ],
                  ),
                ),

              // 제목
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 하단 정보
              Row(
                children: [
                  // 작성자 프로필 이미지
                  userAsync.when(
                    data: (user) {
                      return CircleAvatar(
                        key: ValueKey('${user?.userId}-${user?.profileImageUrl ?? 'no-image'}'),
                        radius: 12,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        backgroundImage: user?.profileImageUrl != null
                            ? CachedNetworkImageProvider(user!.profileImageUrl!)
                            : null,
                        child: user?.profileImageUrl == null
                            ? Text(
                                author[0].toUpperCase(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      );
                    },
                    loading: () => CircleAvatar(
                      radius: 12,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        author[0].toUpperCase(),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    error: (_, __) => CircleAvatar(
                      radius: 12,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        author[0].toUpperCase(),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 작성자
                  Text(
                    author,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '・',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  // 시간
                  Text(
                    AppDateUtils.formatRelativeTime(createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  // 좋아요
                  Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text('$likeCount', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 12),
                  // 댓글
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text('$commentCount', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
