import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_list_item.dart';

/// 채팅 목록 화면
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final conversationsAsync = ref.watch(conversationsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('메시지'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.newChat),
            icon: const Icon(Icons.edit_square),
            tooltip: '새 채팅',
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 채팅이 없습니다',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '새로운 대화를 시작해보세요',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.newChat),
                    icon: const Icon(Icons.add),
                    label: const Text('새 채팅 시작'),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 72,
            ),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ChatListItem(
                conversation: conversation,
                onTap: () {
                  context.push(
                    AppRoutes.chatPath(conversation.conversationId),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '채팅 목록을 불러올 수 없습니다',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(conversationsStreamProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

