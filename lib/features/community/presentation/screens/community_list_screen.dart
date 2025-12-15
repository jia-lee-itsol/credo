import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../providers/community_presentation_providers.dart';
import 'post_edit_screen.dart';

/// 커뮤니티 게시판 리스트 화면
class CommunityListScreen extends ConsumerWidget {
  final String? parishId;

  const CommunityListScreen({super.key, this.parishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider(parishId));
    final currentAppUserAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('커뮤니티')),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('게시글이 없습니다.'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(post.title),
                  trailing: post.authorIsVerified
                      ? const Chip(
                          label: Text('公認'),
                          labelStyle: TextStyle(fontSize: 12),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        )
                      : null,
                  onTap: () {
                    if (post.parishId != null) {
                      context.push(
                        AppRoutes.postDetailPath(post.parishId!, post.postId),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('에러: $error')),
      ),
      floatingActionButton: currentAppUserAsync.when(
        data: (currentUser) {
          if (currentUser != null) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PostEditScreen(initialPost: null, parishId: parishId),
                  ),
                );
              },
              tooltip: '글쓰기',
              child: const Icon(Icons.edit),
            );
          }
          return const SizedBox.shrink();
        },
        loading: () => const SizedBox.shrink(),
        error: (error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}
