import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_entity.freezed.dart';

/// 메시지 타입
enum MessageType {
  text, // 일반 텍스트 메시지
  image, // 이미지 메시지
  system, // 시스템 메시지 (입장, 퇴장 등)
}

/// 메시지 엔티티
@freezed
class MessageEntity with _$MessageEntity {
  const factory MessageEntity({
    required String messageId,
    required String conversationId,
    required String senderId,
    required String content,
    @Default([]) List<String> imageUrls,
    @Default({}) Map<String, DateTime> readBy,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deletedBy,
    @Default(MessageType.text) MessageType type,
  }) = _MessageEntity;

  const MessageEntity._();

  /// 특정 사용자가 읽었는지 확인
  bool isReadBy(String userId) => readBy.containsKey(userId);

  /// 삭제된 메시지인지 확인
  bool get isDeleted => deletedAt != null;

  /// 이미지가 있는 메시지인지 확인
  bool get hasImages => imageUrls.isNotEmpty;

  /// 시스템 메시지인지 확인
  bool get isSystemMessage => type == MessageType.system;
}
