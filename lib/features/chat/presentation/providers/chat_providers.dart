import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../data/providers/chat_repository_providers.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_user_entity.dart';

/// 현재 사용자의 대화방 목록 스트림
final conversationsStreamProvider =
    StreamProvider.autoDispose<List<ConversationEntity>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return const Stream.empty();
  }

  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchConversations(currentUser.userId);
});

/// 특정 대화방 스트림
final conversationStreamProvider = StreamProvider.autoDispose
    .family<ConversationEntity?, String>((ref, conversationId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchConversation(conversationId);
});

/// 특정 대화방의 메시지 스트림
final messagesStreamProvider = StreamProvider.autoDispose
    .family<List<MessageEntity>, String>((ref, conversationId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(conversationId);
});

/// 대화 상대방 정보 Provider (1:1 채팅용)
final chatPartnerProvider =
    FutureProvider.autoDispose.family<ChatUserEntity?, String>((
  ref,
  conversationId,
) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;

  final conversation = await ref.watch(
    conversationStreamProvider(conversationId).future,
  );
  if (conversation == null) return null;

  // 상대방 ID 찾기
  final partnerId = conversation.participants.firstWhere(
    (id) => id != currentUser.userId,
    orElse: () => '',
  );

  if (partnerId.isEmpty) return null;

  final repository = ref.watch(chatRepositoryProvider);
  return repository.getUser(partnerId);
});

/// 대화방 참여자 정보 Provider
final conversationParticipantsProvider =
    FutureProvider.autoDispose.family<List<ChatUserEntity>, String>((
  ref,
  conversationId,
) async {
  final conversation = await ref.watch(
    conversationStreamProvider(conversationId).future,
  );
  if (conversation == null) return [];

  final repository = ref.watch(chatRepositoryProvider);
  return repository.getUsers(conversation.participants);
});

/// 읽지 않은 메시지 총 개수 스트림
final totalUnreadCountProvider = StreamProvider.autoDispose<int>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return const Stream.empty();
  }

  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchUnreadCount(currentUser.userId);
});

/// 특정 대화방의 읽지 않은 메시지 수 스트림
final conversationUnreadCountProvider =
    StreamProvider.autoDispose.family<int, String>((ref, conversationId) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return const Stream.empty();
  }

  final repository = ref.watch(chatRepositoryProvider);
  final conversationAsync = ref.watch(conversationStreamProvider(conversationId));

  // 대화방 정보와 메시지 스트림을 결합하여 마지막 메시지 확인
  return conversationAsync.when(
    data: (conversation) {
      if (conversation == null) {
        return Stream.value(0);
      }

      // 마지막 메시지가 내가 보낸 메시지인 경우, 읽지 않은 메시지가 없음
      if (conversation.lastMessage?.senderId == currentUser.userId) {
        return Stream.value(0);
      }

      // 그 외의 경우 메시지 스트림에서 읽지 않은 메시지 카운트
      return repository.watchConversationUnreadCount(
        conversationId: conversationId,
        userId: currentUser.userId,
      );
    },
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

/// 사용자 검색 Provider
final userSearchProvider =
    FutureProvider.autoDispose.family<List<ChatUserEntity>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(chatRepositoryProvider);
  return repository.searchUsers(query);
});

/// 메시지 검색 Provider
final messageSearchProvider =
    FutureProvider.autoDispose.family<List<MessageEntity>, MessageSearchParams>((
  ref,
  params,
) async {
  if (params.query.isEmpty) return [];

  final repository = ref.watch(chatRepositoryProvider);
  return repository.searchMessages(
    conversationId: params.conversationId,
    query: params.query,
    limit: params.limit,
  );
});

/// 메시지 검색 파라미터
class MessageSearchParams {
  final String conversationId;
  final String query;
  final int limit;

  MessageSearchParams({
    required this.conversationId,
    required this.query,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageSearchParams &&
          runtimeType == other.runtimeType &&
          conversationId == other.conversationId &&
          query == other.query &&
          limit == other.limit;

  @override
  int get hashCode => conversationId.hashCode ^ query.hashCode ^ limit.hashCode;
}

/// 새 채팅 시작 (1:1)
Future<ConversationEntity> startDirectChat(
  WidgetRef ref, {
  required String otherUserId,
}) async {
  final currentUser = ref.read(currentUserProvider);
  if (currentUser == null) {
    throw Exception('로그인이 필요합니다');
  }

  final repository = ref.read(chatRepositoryProvider);
  return repository.getOrCreateDirectConversation(
    currentUserId: currentUser.userId,
    otherUserId: otherUserId,
  );
}

/// 메시지 전송
Future<MessageEntity> sendMessage(
  WidgetRef ref, {
  required String conversationId,
  required String content,
  List<String> imageUrls = const [],
}) async {
  final currentUser = ref.read(currentUserProvider);
  if (currentUser == null) {
    throw Exception('로그인이 필요합니다');
  }

  final repository = ref.read(chatRepositoryProvider);
  return repository.sendMessage(
    conversationId: conversationId,
    senderId: currentUser.userId,
    content: content,
    imageUrls: imageUrls,
  );
}

/// 메시지 읽음 처리
Future<void> markMessagesAsRead(
  WidgetRef ref, {
  required String conversationId,
}) async {
  final currentUser = ref.read(currentUserProvider);
  if (currentUser == null) return;

  final repository = ref.read(chatRepositoryProvider);
  await repository.markAllMessagesAsRead(
    conversationId: conversationId,
    userId: currentUser.userId,
  );
}

/// 타이핑 사용자 스트림
final typingUsersProvider =
    StreamProvider.autoDispose.family<List<String>, String>((ref, conversationId) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return const Stream.empty();
  }

  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchTypingUsers(
    conversationId: conversationId,
    currentUserId: currentUser.userId,
  );
});

/// 타이핑 상태 업데이트
Future<void> updateTypingStatus(
  WidgetRef ref, {
  required String conversationId,
  required bool isTyping,
}) async {
  final currentUser = ref.read(currentUserProvider);
  if (currentUser == null) return;

  final repository = ref.read(chatRepositoryProvider);
  await repository.updateTypingStatus(
    conversationId: conversationId,
    userId: currentUser.userId,
    isTyping: isTyping,
  );
}

