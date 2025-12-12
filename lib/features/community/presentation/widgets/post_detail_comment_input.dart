import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/widgets/login_required_dialog.dart';
import '../../data/models/post.dart';
import '../../data/providers/community_repository_providers.dart';
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
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final primaryColor = ref.read(liturgyPrimaryColorProvider);

    if (!isAuthenticated) {
      LoginRequiredDialog.show(context, primaryColor: primaryColor);
      return;
    }

    final currentAppUserAsync = ref.read(currentAppUserProvider);
    final currentUser = currentAppUserAsync.valueOrNull;
    if (currentUser == null) {
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    final submitter = PostCommentSubmitter(ref: ref as Ref);
    final success = await submitter.submitComment(
      post: widget.post,
      currentUser: currentUser,
      content: content,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('コメントを投稿しました')));
        _commentController.clear();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('コメント投稿に失敗しました')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: const InputDecoration(
                hintText: 'コメントを入力...',
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
