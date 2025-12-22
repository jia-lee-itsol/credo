import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';
import '../entities/chat_user_entity.dart';

/// 채팅 Repository 인터페이스
abstract class ChatRepository {
  // ============ 대화방 관련 ============

  /// 사용자의 모든 대화방 스트림
  Stream<List<ConversationEntity>> watchConversations(String userId);

  /// 특정 대화방 스트림
  Stream<ConversationEntity?> watchConversation(String conversationId);

  /// 1:1 대화방 ID 생성 (두 사용자 ID를 정렬하여 고유 ID 생성)
  String generateDirectConversationId(String userId1, String userId2);

  /// 1:1 대화방 가져오기 또는 생성
  Future<ConversationEntity> getOrCreateDirectConversation({
    required String currentUserId,
    required String otherUserId,
  });

  /// 그룹 대화방 생성
  Future<ConversationEntity> createGroupConversation({
    required String creatorId,
    required List<String> participantIds,
    required String name,
    String? imageUrl,
  });

  /// 대화방 나가기
  /// 상대방에게 시스템 메시지를 보내고, 자신은 참여자 목록에서 제거됨
  Future<void> leaveConversation({
    required String conversationId,
    required String userId,
    required String userNickname,
  });

  /// 대화방 이름 변경 (그룹 채팅용)
  Future<void> updateConversationName({
    required String conversationId,
    required String name,
  });

  /// 대화방에 멤버 추가
  Future<void> addMembersToConversation({
    required String conversationId,
    required List<String> memberIds,
    required String addedByNickname,
  });

  // ============ 메시지 관련 ============

  /// 대화방의 메시지 스트림 (실시간)
  Stream<List<MessageEntity>> watchMessages(String conversationId);

  /// 메시지 페이지네이션 로드
  Future<List<MessageEntity>> loadMessages({
    required String conversationId,
    int limit = 50,
    DateTime? before,
  });

  /// 메시지 검색
  Future<List<MessageEntity>> searchMessages({
    required String conversationId,
    required String query,
    int limit = 50,
  });

  /// 메시지 전송
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    List<String> imageUrls = const [],
  });

  /// 메시지 읽음 표시
  Future<void> markMessageAsRead({
    required String messageId,
    required String conversationId,
    required String userId,
  });

  /// 대화방의 모든 메시지 읽음 표시
  Future<void> markAllMessagesAsRead({
    required String conversationId,
    required String userId,
  });

  /// 메시지 삭제
  Future<void> deleteMessage({
    required String messageId,
    required String conversationId,
    required String userId,
  });

  // ============ 사용자 관련 ============

  /// 사용자 정보 가져오기
  Future<ChatUserEntity?> getUser(String userId);

  /// 여러 사용자 정보 가져오기
  Future<List<ChatUserEntity>> getUsers(List<String> userIds);

  /// 사용자 검색 (닉네임으로)
  Future<List<ChatUserEntity>> searchUsers(String query);

  // ============ 읽지 않은 메시지 ============

  /// 읽지 않은 메시지 수 스트림
  Stream<int> watchUnreadCount(String userId);

  /// 특정 대화방의 읽지 않은 메시지 수 스트림
  Stream<int> watchConversationUnreadCount({
    required String conversationId,
    required String userId,
  });

  // ============ 타이핑 인디케이터 ============

  /// 타이핑 상태 업데이트
  Future<void> updateTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  });

  /// 대화방의 타이핑 사용자 스트림 (자신 제외)
  Stream<List<String>> watchTypingUsers({
    required String conversationId,
    required String currentUserId,
  });
}

