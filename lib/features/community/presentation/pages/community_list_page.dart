import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/community_repository_providers.dart';
import '../../data/models/post.dart';
import 'post_edit_page.dart';

/// 커뮤니티 게시판 리스트 페이지
class CommunityListPage extends ConsumerWidget {
  final String? parishId;

  const CommunityListPage({super.key, this.parishId});

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
                  subtitle: Text(
                    post.body.split('\n').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                    // TODO: navigate to detail
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
                    builder: (_) => PostEditPage(
                      initialPost: null,
                      isOfficial: false,
                      parishId: parishId,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.edit),
              tooltip: '글쓰기',
            );
          }
          return const SizedBox.shrink();
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
