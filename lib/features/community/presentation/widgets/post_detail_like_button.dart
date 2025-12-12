import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/widgets/login_required_dialog.dart';
import '../../data/models/post.dart';
import '../../data/providers/community_repository_providers.dart';

/// 게시글 좋아요 버튼
class PostDetailLikeButton extends ConsumerWidget {
  final Post post;
  final bool isAuthenticated;

  const PostDetailLikeButton({
    super.key,
    required this.post,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);
    final postRepo = ref.watch(postRepositoryProvider);

    // 좋아요 상태 실시간 감시
    final isLikedAsync = currentUser != null
        ? ref.watch(
            StreamProvider<bool>((ref) {
              return postRepo.watchIsLiked(
                postId: post.postId,
                userId: currentUser.userId,
              );
            }),
          )
        : const AsyncValue<bool>.data(false);

    final isLiked = isLikedAsync.valueOrNull ?? false;

    return Row(
      children: [
        InkWell(
          onTap: () async {
            if (isAuthenticated && currentUser != null) {
              final result = await postRepo.toggleLike(
                postId: post.postId,
                userId: currentUser.userId,
              );
              result.fold(
                (failure) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('いいね処理に失敗しました: ${failure.message}'),
                      ),
                    );
                  }
                },
                (_) {
                  // Provider를 무효화하여 게시글 새로고침
                  ref.invalidate(postByIdProvider(post.postId));
                },
              );
            } else {
              LoginRequiredDialog.show(context, primaryColor: primaryColor);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isLiked
                  ? primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isLiked ? primaryColor : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(
                    color: isLiked ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
