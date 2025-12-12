import 'package:flutter/material.dart';

/// 게시글 작성자 정보 위젯
class PostDetailAuthorInfo extends StatelessWidget {
  final String authorName;
  final DateTime createdAt;
  final Color primaryColor;

  const PostDetailAuthorInfo({
    super.key,
    required this.authorName,
    required this.createdAt,
    required this.primaryColor,
  });

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimeAgo(createdAt);

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: primaryColor.withValues(alpha: 0.2),
          child: Icon(Icons.church, size: 16, color: primaryColor),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authorName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(timeAgo, style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
