import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/app_localizations.dart';
import 'pdf_viewer_screen.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../core/utils/mention_parser.dart';
import '../providers/community_presentation_providers.dart';
import 'report_dialog.dart';

/// 댓글 아이템 위젯
class CommentItem extends ConsumerWidget {
  final String commentId;
  final String author;
  final String authorId;
  final String content;
  final List<String> imageUrls;
  final List<String> pdfUrls;
  final DateTime createdAt;
  final Color primaryColor;
  final void Function(String authorName, String authorId)? onAuthorTap;

  const CommentItem({
    super.key,
    required this.commentId,
    required this.author,
    required this.authorId,
    required this.content,
    this.imageUrls = const [],
    this.pdfUrls = const [],
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
                    const Spacer(),
                    // 수정/삭제 버튼 (작성자인 경우)
                    if (isAuthor) ...[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        color: theme.colorScheme.onSurfaceVariant,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showEditDialog(context, ref),
                        tooltip: l10n.common.edit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16),
                        color: Colors.red,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showDeleteConfirmDialog(context, ref),
                        tooltip: l10n.common.delete,
                      ),
                    ]
                    // 신고 버튼 (작성자가 아닌 경우에만 표시)
                    else if (currentUser != null) ...[
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

                // 이미지 표시
                if (imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildImages(context, theme),
                ],

                // PDF 표시
                if (pdfUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildPdfs(context, ref, theme),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImages(BuildContext context, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: imageUrls.map((imageUrl) {
        return GestureDetector(
          onTap: () {
            // 이미지 전체 화면 보기 (간단한 버전)
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPdfs(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pdfUrls.map((pdfUrl) {
        final fileName = pdfUrl.split('/').last.split('?').first;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PdfViewerScreen(pdfUrl: pdfUrl, fileName: fileName),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade50,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    fileName,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final l10n = ref.read(appLocalizationsSyncProvider);
    final primaryColor = ref.read(liturgyPrimaryColorProvider);
    final textController = TextEditingController(text: content);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.common.edit),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: l10n.common.commentHint,
            border: const OutlineInputBorder(),
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common.cancel),
          ),
          TextButton(
            onPressed: () async {
              final newContent = textController.text.trim();
              if (newContent.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.validation.commentRequired)),
                );
                return;
              }

              Navigator.pop(dialogContext);
              await _updateComment(context, ref, newContent);
            },
            style: TextButton.styleFrom(foregroundColor: primaryColor),
            child: Text(l10n.common.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) {
    final l10n = ref.read(appLocalizationsSyncProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.common.delete),
        content: Text(l10n.common.confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteComment(context, ref);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.common.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _updateComment(
    BuildContext context,
    WidgetRef ref,
    String newContent,
  ) async {
    final repository = ref.read(postRepositoryProvider);
    final l10n = ref.read(appLocalizationsSyncProvider);

    final result = await repository.updateComment(
      commentId: commentId,
      content: newContent,
      imageUrls: imageUrls,
      pdfUrls: pdfUrls,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.message.isNotEmpty ? failure.message : l10n.common.error,
            ),
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.common.success)));
      },
    );
  }

  Future<void> _deleteComment(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(postRepositoryProvider);
    final l10n = ref.read(appLocalizationsSyncProvider);

    final result = await repository.deleteComment(commentId);

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.message.isNotEmpty ? failure.message : l10n.common.error,
            ),
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.common.success)));
      },
    );
  }
}
