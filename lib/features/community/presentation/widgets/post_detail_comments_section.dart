import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../data/models/post.dart';
import '../providers/community_presentation_providers.dart';
import 'comment_item.dart';

/// 게시글 댓글 섹션
class PostDetailCommentsSection extends ConsumerWidget {
  final Post post;
  final Function(String authorName, String authorId) onAuthorTap;

  const PostDetailCommentsSection({
    super.key,
    required this.post,
    required this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final commentsAsync = ref.watch(commentsProvider(post.postId));

    return commentsAsync.when(
      data: (comments) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.community.commentsCount(comments.length),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 댓글 목록
            if (comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.community.noComments,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...comments.map(
                (comment) => CommentItem(
                  commentId: comment.commentId,
                  author: comment.authorName,
                  authorId: comment.authorId,
                  content: comment.content,
                  imageUrls: comment.imageUrls,
                  pdfUrls: comment.pdfUrls,
                  createdAt: comment.createdAt,
                  primaryColor: primaryColor,
                  onAuthorTap: onAuthorTap,
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        // 에러 발생 시에도 빈 댓글 목록으로 표시
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.community.commentsCount(0),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  l10n.community.noComments,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
