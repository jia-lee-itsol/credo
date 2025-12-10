import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/community_repository_providers.dart';
import '../../data/models/post.dart';
import 'post_edit_page.dart';

/// 공지사항 리스트 페이지
class NoticeListPage extends ConsumerWidget {
  final String? parishId;

  const NoticeListPage({super.key, this.parishId});

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
          if (currentUser != null && currentUser.canPostOfficial) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostEditPage(
                      initialPost: null,
                      isOfficial: true,
                      parishId: parishId,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.edit),
              tooltip: '공지 작성',
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
