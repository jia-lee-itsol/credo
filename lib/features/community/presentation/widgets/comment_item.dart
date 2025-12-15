import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../core/utils/mention_parser.dart';
import '../providers/community_presentation_providers.dart';
import 'report_dialog.dart';

/// 댓글 아이템 위젯
class CommentItem extends ConsumerWidget {
  final String commentId;
  final String author;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final Color primaryColor;
  final void Function(String authorName, String authorId)? onAuthorTap;

  const CommentItem({
    super.key,
    required this.commentId,
    required this.author,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.primaryColor,
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final parts = MentionParser.parseText(content);
    final currentUser = ref.watch(currentUserProvider);
    final isAuthor = currentUser != null && currentUser.userId == authorId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              author[0],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onAuthorTap != null
                          ? () => onAuthorTap!(author, authorId)
                          : null,
                      child: Text(
                        author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppDateUtils.formatRelativeTime(createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    // 신고 버튼 (작성자가 아닌 경우에만 표시)
                    if (!isAuthor && currentUser != null) ...[
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.flag_outlined, size: 16),
                        color: theme.colorScheme.onSurfaceVariant,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          ReportDialog.showForComment(context, commentId);
                        },
                        tooltip: l10n.community.reportPost,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // 멘션 포함 텍스트 렌더링
                _buildContentWithMentions(context, ref, theme, parts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWithMentions(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    List<({String text, bool isMention, String? mentionName})> parts,
  ) {
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: parts.map((part) {
          if (part.isMention && part.mentionName != null) {
            // 멘션된 유저 정보 조회 (displayName으로 검색)
            final userAsync = ref.watch(
              userByDisplayNameProvider(part.mentionName!),
            );

            return userAsync.when(
              data: (user) {
                final displayName = user?.displayName ?? part.mentionName!;
                return TextSpan(
                  text: '@$displayName',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
              loading: () => TextSpan(
                text: part.text,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              error: (_, _) => TextSpan(
                text: part.text,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          } else {
            return TextSpan(text: part.text);
          }
        }).toList(),
      ),
    );
  }
}
