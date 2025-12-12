import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../data/models/post.dart';
import '../../data/providers/community_repository_providers.dart';
import 'post_edit_screen.dart';
import '../widgets/post_detail_comment_input.dart'
    show PostDetailCommentInput, PostDetailCommentInputState;
import '../widgets/post_detail_comments_section.dart';
import '../widgets/post_detail_header.dart';
import '../widgets/post_detail_images.dart';
import '../widgets/post_detail_like_button.dart';

/// 게시글 상세 화면
class PostDetailScreen extends ConsumerStatefulWidget {
  final String parishId;
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.parishId,
    required this.postId,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final GlobalKey<PostDetailCommentInputState> _commentInputKey =
      GlobalKey<PostDetailCommentInputState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentUserProvider);
    final postAsync = ref.watch(postByIdProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          postAsync.when(
            data: (post) {
              if (post == null) {
                return const SizedBox.shrink();
              }

              // 작성자 본인인지 확인
              final isAuthor =
                  currentUser != null && currentUser.userId == post.authorId;

              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEdit(context, post);
                  } else if (value == 'delete') {
                    _showDeleteConfirmDialog(context, post);
                  } else if (value == 'report') {
                    _showReportDialog(context);
                  }
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[];

                  // 작성자 본인인 경우 수정/삭제 옵션 추가
                  if (isAuthor) {
                    items.addAll([
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('編集する'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('削除する', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                    ]);
                  }

                  // 신고 옵션 (작성자가 아닌 경우에만 표시)
                  if (!isAuthor) {
                    items.add(
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('通報する'),
                          ],
                        ),
                      ),
                    );
                  }

                  return items;
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: postAsync.when(
        data: (post) {
          if (post == null) {
            return const Center(child: Text('게시글을 찾을 수 없습니다.'));
          }

          return Column(
            children: [
              // 게시글 내용
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더 (배지, 제목, 작성자 정보)
                      PostDetailHeader(post: post),
                      const SizedBox(height: 24),

                      // 본문
                      Text(
                        post.body,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
                      ),
                      const SizedBox(height: 16),

                      // 이미지 썸네일
                      if (post.imageUrls.isNotEmpty)
                        PostDetailImages(imageUrls: post.imageUrls),
                      if (post.imageUrls.isNotEmpty) const SizedBox(height: 24),

                      // 좋아요 버튼
                      PostDetailLikeButton(
                        post: post,
                        isAuthenticated: isAuthenticated,
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // 댓글 섹션
                      PostDetailCommentsSection(
                        post: post,
                        onAuthorTap: (authorName, authorId) {
                          _commentInputKey.currentState?.addMention(
                            authorName,
                            authorId,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 댓글 입력
              PostDetailCommentInput(key: _commentInputKey, post: post),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('에러가 발생했습니다: $error')),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Post post) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) =>
                PostEditScreen(initialPost: post, parishId: post.parishId),
          ),
        )
        .then((_) {
          // 수정 후 돌아왔을 때 게시글 새로고침
          ref.invalidate(postByIdProvider(widget.postId));
        });
  }

  void _showDeleteConfirmDialog(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この投稿を削除してもよろしいですか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(post);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(Post post) async {
    try {
      final repository = ref.read(postRepositoryProvider);
      final result = await repository.deletePost(post.postId);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('投稿の削除に失敗しました: ${failure.message}')),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('投稿を削除しました')));
            Navigator.of(context).pop(); // 상세 화면 닫기
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
      }
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通報する'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('スパム'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('通報しました')));
              },
            ),
            ListTile(
              title: const Text('不適切なコンテンツ'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('通報しました')));
              },
            ),
            ListTile(
              title: const Text('誹謗中傷'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('通報しました')));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}
