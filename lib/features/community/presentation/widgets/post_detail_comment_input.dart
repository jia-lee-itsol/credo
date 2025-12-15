import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/widgets/login_required_dialog.dart';
import '../../data/models/post.dart';
import '../providers/community_presentation_providers.dart';
import 'post_comment_submitter.dart';

/// 게시글 댓글 입력 위젯
class PostDetailCommentInput extends ConsumerStatefulWidget {
  final Post post;
  final Function(String authorName, String authorId)? onMention;

  const PostDetailCommentInput({super.key, required this.post, this.onMention});

  @override
  ConsumerState<PostDetailCommentInput> createState() =>
      PostDetailCommentInputState();
}

class PostDetailCommentInputState
    extends ConsumerState<PostDetailCommentInput> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// 댓글 작성자 이름을 탭하면 @멘션 추가
  void _addMentionToComment(String authorName, String authorId) {
    final currentText = _commentController.text;
    final mentionText = '@$authorName ';

    // 이미 같은 멘션이 있는지 확인
    if (currentText.contains('@$authorName')) {
      return;
    }

    // 커서 위치에 멘션 추가
    final selection = _commentController.selection;
    if (selection.isValid) {
      final newText =
          currentText.substring(0, selection.baseOffset) +
          mentionText +
          currentText.substring(selection.extentOffset);
      _commentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.baseOffset + mentionText.length,
        ),
      );
    } else {
      // 커서가 없으면 맨 앞에 추가
      _commentController.value = TextEditingValue(
        text: mentionText + currentText,
        selection: TextSelection.collapsed(offset: mentionText.length),
      );
    }
  }

  Future<void> _handleSubmit() async {
    AppLogger.community('===== _handleSubmit() 시작 =====');

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final primaryColor = ref.read(liturgyPrimaryColorProvider);

    AppLogger.community('isAuthenticated: $isAuthenticated');

    if (!isAuthenticated) {
      AppLogger.community('로그인 필요 다이얼로그 표시');
      LoginRequiredDialog.show(context, primaryColor: primaryColor);
      return;
    }

    // FutureProvider이므로 await로 값을 기다림
    final currentUser = await ref.read(currentAppUserProvider.future);
    AppLogger.community('currentUser: ${currentUser?.uid}');

    if (currentUser == null) {
      AppLogger.community('currentUser가 null이므로 종료');
      return;
    }

    final content = _commentController.text.trim();
    AppLogger.community('content: "$content"');

    if (content.isEmpty) {
      AppLogger.community('content가 비어있으므로 종료');
      return;
    }

    try {
      AppLogger.community('PostCommentSubmitter 생성 및 submitComment 호출');
      final submitter = PostCommentSubmitter(ref: ref);
      final success = await submitter.submitComment(
        post: widget.post,
        currentUser: currentUser,
        content: content,
      );
      AppLogger.community('submitComment 결과: $success');

      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.community.commentPosted)));
          _commentController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.community.commentPostFailed)),
          );
        }
      }
    } catch (e) {
      AppLogger.error('댓글 작성 중 에러 발생: $e', e);
      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.community.commentPostFailed}: ${e.toString()}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: l10n.common.commentHint,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            onPressed: _handleSubmit,
            icon: Icon(Icons.send, color: primaryColor),
          ),
        ],
      ),
    );
  }

  /// 외부에서 멘션 추가를 위한 메서드
  void addMention(String authorName, String authorId) {
    _addMentionToComment(authorName, authorId);
  }

  /// 위젯이 생성될 때 onMention 콜백을 설정
  static PostDetailCommentInputState? of(BuildContext context) {
    return context.findAncestorStateOfType<PostDetailCommentInputState>();
  }
}
