import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/utils/share_utils.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../data/models/post.dart';
import '../providers/community_presentation_providers.dart';
import 'post_edit_screen.dart';
import '../widgets/post_detail_comment_input.dart'
    show PostDetailCommentInput, PostDetailCommentInputState;
import '../widgets/post_detail_comments_section.dart';
import '../widgets/post_detail_header.dart';
import '../widgets/post_detail_images.dart';
import '../widgets/post_detail_pdfs.dart';
import '../widgets/post_detail_like_button.dart';
import '../widgets/report_dialog.dart';

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
    debugPrint('🔍 [PostDetail] build() 호출됨, postId: ${widget.postId}');
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentUserProvider);
    final postAsync = ref.watch(postByIdProvider(widget.postId));

    debugPrint('🔍 [PostDetail] postAsync 상태: ${postAsync.runtimeType}');
    debugPrint(
      '🔍 [PostDetail] currentUser: ${currentUser?.userId}, role: ${currentUser?.role}',
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          postAsync.when(
            data: (post) {
              debugPrint(
                '🔍 [PostDetail] postAsync.when(data) 호출됨, post: ${post?.postId}',
              );
              if (post == null) {
                debugPrint('🔍 [PostDetail] post가 null입니다!');
                return const SizedBox.shrink();
              }

              // 작성자 본인인지 확인
              final isAuthor =
                  currentUser != null && currentUser.userId == post.authorId;

              // 관리자 권한 확인
              final isAdmin = currentUser?.isAdmin ?? false;

              // 관리자가 자신의 교회 게시글인지 확인
              final adminParishId = currentUser?.mainParishId;
              final postParishId = post.parishId;
              final isAdminOfPostParish =
                  isAdmin &&
                  adminParishId != null &&
                  postParishId != null &&
                  adminParishId == postParishId;

              // 디버그 로그 (항상 출력)
              debugPrint('🔍 [PostDetail] kDebugMode: $kDebugMode');
              debugPrint('🔍 [PostDetail] 현재 사용자: ${currentUser?.userId}');
              debugPrint('🔍 [PostDetail] 사용자 role: ${currentUser?.role}');
              debugPrint(
                '🔍 [PostDetail] role == "admin": ${currentUser?.role == "admin"}',
              );
              debugPrint('🔍 [PostDetail] isAdmin: $isAdmin');
              debugPrint('🔍 [PostDetail] isAuthor: $isAuthor');
              debugPrint('🔍 [PostDetail] 게시글 상태: ${post.status}');
              debugPrint('🔍 [PostDetail] adminParishId: $adminParishId');
              debugPrint('🔍 [PostDetail] postParishId: $postParishId');
              debugPrint(
                '🔍 [PostDetail] isAdminOfPostParish: $isAdminOfPostParish',
              );
              AppLogger.community(
                '현재 사용자: ${currentUser?.userId}, role: "${currentUser?.role}", isAdmin: $isAdmin, adminParishId: $adminParishId, postParishId: $postParishId, isAdminOfPostParish: $isAdminOfPostParish',
              );

              return PopupMenuButton<String>(
                onSelected: (value) {
                  debugPrint('🔍 [PostDetail] 메뉴 선택: $value');
                  AppLogger.community('메뉴 선택: $value');
                  if (value == 'edit') {
                    _navigateToEdit(context, post);
                  } else if (value == 'delete') {
                    _showDeleteConfirmDialog(context, post);
                  } else if (value == 'share') {
                    _sharePost(context, post);
                  } else if (value == 'report') {
                    ReportDialog.showForPost(context, post.postId);
                  } else if (value == 'hide') {
                    AppLogger.community('비표시 다이얼로그 표시 시작');
                    _showHideConfirmDialog(context, post);
                  } else if (value == 'unhide') {
                    AppLogger.community('표시 다이얼로그 표시 시작');
                    _showUnhideConfirmDialog(context, post);
                  }
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[];

                  // 작성자 본인인 경우 수정/삭제 옵션 추가
                  if (isAuthor) {
                    items.addAll([
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.community.editPost),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              l10n.community.deletePost,
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                    ]);
                  }

                  // 관리자 옵션 (숨기기/표시하기) - 자신의 교회 게시글인 경우에만 표시
                  if (isAdminOfPostParish) {
                    items.addAll([
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: post.status == 'hidden' ? 'unhide' : 'hide',
                        child: Row(
                          children: [
                            Icon(
                              post.status == 'hidden'
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                              color: post.status == 'hidden'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              post.status == 'hidden'
                                  ? l10n.community.showPost
                                  : l10n.community.hidePost,
                              style: TextStyle(
                                color: post.status == 'hidden'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }

                  // 공유 옵션 (모든 사용자)
                  items.add(
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          const Icon(Icons.share_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.community.sharePost ?? 'シェア'),
                        ],
                      ),
                    ),
                  );

                  // 신고 옵션 (작성자가 아닌 경우에만 표시)
                  if (!isAuthor && !isAdmin) {
                    items.add(
                      PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 20),
                            SizedBox(width: 8),
                            Text(l10n.community.reportPost),
                          ],
                        ),
                      ),
                    );
                  }

                  return items;
                },
              );
            },
            loading: () {
              debugPrint('🔍 [PostDetail] postAsync.when(loading)');
              return const SizedBox.shrink();
            },
            error: (error, stackTrace) {
              debugPrint('🔍 [PostDetail] postAsync.when(error): $error');
              return const SizedBox.shrink();
            },
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

                      // PDF 파일
                      if (post.pdfUrls.isNotEmpty)
                        PostDetailPdfs(pdfUrls: post.pdfUrls),
                      if (post.pdfUrls.isNotEmpty) const SizedBox(height: 24),

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
    final l10n = ref.read(appLocalizationsSyncProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.community.postDeleteConfirmTitle),
        content: Text(l10n.community.postDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(post);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.community.deletePost),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePost(BuildContext context, Post post) async {
    try {
      final l10n = ref.read(appLocalizationsSyncProvider);
      await ShareUtils.sharePost(
        postTitle: post.title,
        parishId: post.parishId ?? '',
        postId: post.postId,
        l10n: l10n,
      );
    } catch (e) {
      if (context.mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.common.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePost(Post post) async {
    try {
      final repository = ref.read(postRepositoryProvider);
      final result = await repository.deletePost(post.postId);
      result.fold(
        (failure) {
          if (mounted) {
            final l10n = ref.read(appLocalizationsSyncProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${l10n.community.postDeleteFailed}: ${failure.message}',
                ),
              ),
            );
          }
        },
        (_) {
          if (mounted) {
            final l10n = ref.read(appLocalizationsSyncProvider);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.community.postDeleted)));
            Navigator.of(context).pop(); // 상세 화면 닫기
          }
        },
      );
    } catch (e) {
      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.community.postDeleteFailed}: $e')),
        );
      }
    }
  }

  void _showHideConfirmDialog(BuildContext context, Post post) {
    AppLogger.community('_showHideConfirmDialog() 호출됨, 게시글 ID: ${post.postId}');
    final l10n = ref.read(appLocalizationsSyncProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.community.postHideConfirmTitle),
        content: Text(l10n.community.postHideConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common.cancel),
          ),
          TextButton(
            onPressed: () {
              AppLogger.community('비표시 확인 다이얼로그에서 확인 버튼 클릭');
              Navigator.pop(context);
              AppLogger.community('_hidePost() 호출 전');
              _hidePost(post).catchError((error, stackTrace) {
                AppLogger.error(
                  '_hidePost() 예외 발생 (catchError): $error',
                  error,
                  stackTrace,
                );
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(l10n.community.hidePost),
          ),
        ],
      ),
    );
  }

  void _showUnhideConfirmDialog(BuildContext context, Post post) {
    AppLogger.community(
      '_showUnhideConfirmDialog() 호출됨, 게시글 ID: ${post.postId}',
    );
    final l10n = ref.read(appLocalizationsSyncProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.community.postShowConfirmTitle),
        content: Text(l10n.community.postShowConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common.cancel),
          ),
          TextButton(
            onPressed: () {
              AppLogger.community('표시 확인 다이얼로그에서 확인 버튼 클릭');
              Navigator.pop(context);
              AppLogger.community('_unhidePost() 호출 전');
              _unhidePost(post).catchError((error, stackTrace) {
                AppLogger.error(
                  '_unhidePost() 예외 발생 (catchError): $error',
                  error,
                  stackTrace,
                );
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: Text(l10n.community.showPost),
          ),
        ],
      ),
    );
  }

  Future<void> _hidePost(Post post) async {
    try {
      AppLogger.community('===== _hidePost() 시작 =====');
      AppLogger.community('게시글 ID: ${post.postId}');
      AppLogger.community('현재 상태: ${post.status}');
    } catch (e, stackTrace) {
      AppLogger.error('_hidePost() 시작 부분 예외: $e', e, stackTrace);
      rethrow;
    }

    final currentUser = ref.read(currentUserProvider);
    AppLogger.community('현재 사용자: ${currentUser?.userId}');
    AppLogger.community('관리자 여부: ${currentUser?.isAdmin ?? false}');
    AppLogger.community('사용자 mainParishId: ${currentUser?.mainParishId}');
    AppLogger.community('게시글 parishId: ${post.parishId}');
    AppLogger.community(
      '소속 교회 일치 여부: ${currentUser?.mainParishId == post.parishId}',
    );

    try {
      final repository = ref.read(postRepositoryProvider);
      final updatedPost = post.copyWith(
        status: 'hidden',
        updatedAt: DateTime.now(),
      );

      AppLogger.community('업데이트할 게시글 데이터:');
      AppLogger.community('  - postId: ${updatedPost.postId}');
      AppLogger.community('  - status: ${updatedPost.status}');
      AppLogger.community('  - updatedAt: ${updatedPost.updatedAt}');

      final postData = updatedPost.toFirestore();
      AppLogger.community('Firestore 데이터: $postData');

      AppLogger.community('updatePost() 호출 시작...');
      final result = await repository.updatePost(updatedPost);

      result.fold(
        (failure) {
          AppLogger.error('게시글 숨기기 실패: ${failure.message}', failure);
          AppLogger.community('에러 타입: ${failure.runtimeType}');
          if (failure is FirebaseFailure) {
            AppLogger.community('Firebase 에러 코드: ${failure.code}');
          }
          if (mounted) {
            final l10n = ref.read(appLocalizationsSyncProvider);
            String errorMessage =
                '${l10n.community.postHideFailed}: ${failure.message}';
            if (failure is FirebaseFailure &&
                failure.code == 'permission-denied') {
              errorMessage = l10n.community.postHideNoPermission;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
          }
        },
        (_) {
          AppLogger.community('✅ 게시글 숨기기 성공!');
          if (mounted) {
            final l10n = ref.read(appLocalizationsSyncProvider);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.community.postHidden)));
            // 게시글 목록 새로고침
            ref.invalidate(postByIdProvider(widget.postId));
            ref.invalidate(allPostsProvider(widget.parishId));
            // 커뮤니티 화면으로 돌아가기
            Navigator.of(context).pop();
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('게시글 숨기기 예외 발생: $e', e, stackTrace);
      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.community.postHideFailed}: $e')),
        );
      }
    }
    AppLogger.community('===== _hidePost() 종료 =====');
  }

  Future<void> _unhidePost(Post post) async {
    AppLogger.community('===== _unhidePost() 시작 =====');
    AppLogger.community('게시글 ID: ${post.postId}');
    AppLogger.community('현재 상태: ${post.status}');

    final currentUser = ref.read(currentUserProvider);
    AppLogger.community('현재 사용자: ${currentUser?.userId}');
    AppLogger.community('관리자 여부: ${currentUser?.isAdmin ?? false}');

    try {
      final repository = ref.read(postRepositoryProvider);
      final updatedPost = post.copyWith(
        status: 'published',
        updatedAt: DateTime.now(),
      );

      AppLogger.community('업데이트할 게시글 데이터:');
      AppLogger.community('  - postId: ${updatedPost.postId}');
      AppLogger.community('  - status: ${updatedPost.status}');
      AppLogger.community('  - updatedAt: ${updatedPost.updatedAt}');

      final postData = updatedPost.toFirestore();
      AppLogger.community('Firestore 데이터: $postData');

      AppLogger.community('updatePost() 호출 시작...');
      final result = await repository.updatePost(updatedPost);

      result.fold(
        (failure) {
          AppLogger.error('게시글 표시하기 실패: ${failure.message}', failure);
          AppLogger.community('에러 타입: ${failure.runtimeType}');
          if (failure is FirebaseFailure) {
            AppLogger.community('Firebase 에러 코드: ${failure.code}');
          }
          if (mounted) {
            final l10n = ref.read(appLocalizationsSyncProvider);
            String errorMessage =
                '${l10n.community.postShowFailed}: ${failure.message}';
            if (failure is FirebaseFailure &&
                failure.code == 'permission-denied') {
              errorMessage = l10n.community.postShowNoPermission;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
          }
        },
        (_) {
          AppLogger.community('✅ 게시글 표시하기 성공!');
          if (mounted) {
            final l10n = ref.read(appLocalizationsSyncProvider);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.community.postShow)));
            // 게시글 새로고침
            ref.invalidate(postByIdProvider(widget.postId));
            ref.invalidate(allPostsProvider(widget.parishId));
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('게시글 표시하기 예외 발생: $e', e, stackTrace);
      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.community.postShowFailed}: $e')),
        );
      }
    }
    AppLogger.community('===== _unhidePost() 종료 =====');
  }
}
