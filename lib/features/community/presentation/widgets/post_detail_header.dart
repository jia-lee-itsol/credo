import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../data/models/post.dart';
import 'post_detail_author_info.dart';

/// 게시글 상세 화면 헤더 (배지, 제목, 작성자 정보)
class PostDetailHeader extends ConsumerWidget {
  final Post post;

  const PostDetailHeader({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 배지 (핀, 공식)
        if (post.isPinned || post.isOfficial)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                if (post.isPinned) ...[
                  BadgeChip.pinned(),
                  if (post.isOfficial) const SizedBox(width: 8),
                ],
                if (post.isOfficial) BadgeChip.official(),
              ],
            ),
          ),

        // 제목
        Text(
          post.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // 작성자 & 시간
        PostDetailAuthorInfo(
          authorName: post.authorName,
          authorId: post.authorId,
          createdAt: post.createdAt,
          primaryColor: primaryColor,
        ),
      ],
    );
  }
}
