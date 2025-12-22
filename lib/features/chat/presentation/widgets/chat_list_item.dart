import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../providers/chat_providers.dart';

/// 채팅 목록 아이템 위젯
class ChatListItem extends ConsumerWidget {
  final ConversationEntity conversation;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final isDirect = conversation.type == ConversationType.direct;

    // 1:1 채팅인 경우 상대방 정보 가져오기
    final partnerAsync = isDirect
        ? ref.watch(chatPartnerProvider(conversation.conversationId))
        : null;

    // 읽지 않은 메시지 수
    final unreadCountAsync = ref.watch(
      conversationUnreadCountProvider(conversation.conversationId),
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 프로필 이미지
            _buildAvatar(context, isDirect, partnerAsync),
            const SizedBox(width: 12),

            // 대화 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름 및 시간
                  Row(
                    children: [
                      Expanded(
                        child: _buildName(
                          context,
                          isDirect,
                          partnerAsync,
                          currentUser?.userId,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 마지막 메시지 및 읽지 않은 메시지 수
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // 내가 보낸 메시지인지 표시
                            if (conversation.lastMessage != null &&
                                conversation.lastMessage!.senderId ==
                                    currentUser?.userId)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            Expanded(
                              child: Text(
                                conversation.lastMessage != null &&
                                        conversation.lastMessage!.senderId ==
                                            currentUser?.userId
                                    ? '나: ${conversation.lastMessage!.content}'
                                    : conversation.lastMessage?.content ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      unreadCountAsync.when(
                        data: (count) {
                          if (count == 0) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count > 99 ? '99+' : count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    bool isDirect,
    AsyncValue<ChatUserEntity?>? partnerAsync,
  ) {
    final theme = Theme.of(context);

    if (isDirect && partnerAsync != null) {
      return partnerAsync.when(
        data: (partner) {
          if (partner?.profileImageUrl != null) {
            return CircleAvatar(
              key: ValueKey(partner!.profileImageUrl),
              radius: 24,
              backgroundImage: NetworkImage(partner.profileImageUrl!),
            );
          }
          return CircleAvatar(
            key: ValueKey('no-image-${partner?.userId ?? 'unknown'}'),
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              (partner?.nickname ?? '?')[0].toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        loading: () => CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[200],
        ),
        error: (_, __) => CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person),
        ),
      );
    }

    // 그룹 채팅
    if (conversation.imageUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(conversation.imageUrl!),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
      child: Icon(
        Icons.group,
        color: theme.colorScheme.secondary,
      ),
    );
  }

  Widget _buildName(
    BuildContext context,
    bool isDirect,
    AsyncValue<ChatUserEntity?>? partnerAsync,
    String? currentUserId,
  ) {
    final theme = Theme.of(context);

    if (isDirect && partnerAsync != null) {
      return partnerAsync.when(
        data: (partner) => Text(
          partner?.nickname ?? '알 수 없음',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        loading: () => Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        error: (_, __) => Text(
          '알 수 없음',
          style: theme.textTheme.titleSmall,
        ),
      );
    }

    return Text(
      conversation.name ?? '그룹 채팅',
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (diff.inDays == 1) {
      return '어제';
    } else if (diff.inDays < 7) {
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return '${weekdays[time.weekday - 1]}요일';
    } else {
      return DateFormat('MM/dd').format(time);
    }
  }
}

