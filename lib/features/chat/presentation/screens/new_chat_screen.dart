import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../providers/chat_providers.dart';
import '../providers/friend_providers.dart';

/// 새 채팅 시작 화면 (친구 목록에서 선택)
class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);
    final friendsAsync = ref.watch(friendsStreamProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('새 채팅')),
        body: const Center(
          child: Text('로그인이 필요합니다'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('새 채팅'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.friendList),
            icon: const Icon(Icons.person_add),
            label: const Text('친구 추가'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(16),
                color: primaryColor.withValues(alpha: 0.05),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '친구로 추가된 사용자에게만 메시지를 보낼 수 있습니다',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 친구 목록
              Expanded(
                child: friendsAsync.when(
                  data: (friends) {
                    if (friends.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '아직 친구가 없습니다',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '친구를 추가하면 메시지를 보낼 수 있습니다',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => context.push(AppRoutes.friendList),
                              icon: const Icon(Icons.person_add),
                              label: const Text('친구 추가하기'),
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: friends.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return ListTile(
                          leading: CircleAvatar(
                            key: ValueKey(friend.friendProfileImageUrl ?? 'no-image'),
                            backgroundImage: friend.friendProfileImageUrl != null
                                ? NetworkImage(friend.friendProfileImageUrl!)
                                : null,
                            backgroundColor:
                                primaryColor.withValues(alpha: 0.1),
                            child: friend.friendProfileImageUrl == null
                                ? Text(
                                    friend.friendNickname[0].toUpperCase(),
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(friend.friendNickname),
                          trailing:
                              const Icon(Icons.chat_bubble_outline, size: 20),
                          onTap: _isLoading
                              ? null
                              : () =>
                                  _startChatWith(friend.friendUserId),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('오류: $error'),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () =>
                              ref.invalidate(friendsStreamProvider),
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 로딩 오버레이
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _startChatWith(String friendUserId) async {
    setState(() => _isLoading = true);

    try {
      final conversation = await startDirectChat(
        ref,
        otherUserId: friendUserId,
      );

      if (mounted) {
        // 채팅 화면으로 이동 (새 채팅 화면은 스택에서 제거)
        context.pushReplacement(
          AppRoutes.chatPath(conversation.conversationId),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅 시작 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
