import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/badge_chip.dart';

/// 게시글 카드 위젯
class PostCard extends StatelessWidget {
  final String title;
  final String content;
  final String author;
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
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isOfficial,
    required this.isPinned,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                        const BadgeChip.pinned(),
                        if (isOfficial) const SizedBox(width: 8),
                      ],
                      if (isOfficial) const BadgeChip.official(),
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
              const SizedBox(height: 8),

              // 본문 미리보기
              Text(
                content,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 하단 정보
              Row(
                children: [
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
