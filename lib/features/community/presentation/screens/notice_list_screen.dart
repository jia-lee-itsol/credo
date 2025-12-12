import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../data/providers/community_repository_providers.dart';
import 'post_edit_screen.dart';

/// 공지사항 리스트 화면
class NoticeListScreen extends ConsumerWidget {
  final String? parishId;

  const NoticeListScreen({super.key, this.parishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(officialNoticesProvider(parishId));
    final currentAppUserAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('공지사항')),
      body: noticesAsync.when(
        data: (notices) {
          if (notices.isEmpty) {
            return const Center(child: Text('공식 공지사항이 없습니다.'));
          }

          return ListView.builder(
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final post = notices[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(post.title),
                  subtitle: Text(
                    post.body.split('\n').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Chip(
                    label: Text('公式'),
                    labelStyle: TextStyle(fontSize: 12),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
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
          if (currentUser != null && currentUser.canPostOfficial) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PostEditScreen(initialPost: null, parishId: parishId),
                  ),
                );
              },
              tooltip: '공지 작성',
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
