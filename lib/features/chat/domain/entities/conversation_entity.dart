import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_entity.freezed.dart';

/// 대화방 엔티티
@freezed
class ConversationEntity with _$ConversationEntity {
  const factory ConversationEntity({
    required String conversationId,
    required List<String> participants,
    required ConversationType type,
    LastMessageInfo? lastMessage,
    DateTime? lastMessageAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    // 그룹 채팅용
    String? name,
    String? imageUrl,
    String? createdBy,
  }) = _ConversationEntity;
}

/// 대화 타입
enum ConversationType {
  direct, // 1:1 채팅
  group, // 그룹 채팅
}

/// 마지막 메시지 정보
@freezed
class LastMessageInfo with _$LastMessageInfo {
  const factory LastMessageInfo({
    required String content,
    required String senderId,
    required DateTime createdAt,
  }) = _LastMessageInfo;
}

