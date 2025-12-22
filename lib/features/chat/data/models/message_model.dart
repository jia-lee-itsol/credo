import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/message_entity.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// 메시지 모델 (Firestore 직렬화용)
@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String messageId,
    required String conversationId,
    required String senderId,
    required String content,
    @Default([]) List<String> imageUrls,
    @JsonKey(fromJson: _readByFromJson, toJson: _readByToJson)
    @Default({})
    Map<String, DateTime> readBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
    DateTime? updatedAt,
    @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
    DateTime? deletedAt,
    String? deletedBy,
    @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
    @Default(MessageType.text)
    MessageType type,
  }) = _MessageModel;

  const MessageModel._();

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromJson({
      'messageId': doc.id,
      ...data,
    });
  }

  /// Entity로 변환
  MessageEntity toEntity() {
    return MessageEntity(
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      imageUrls: imageUrls,
      readBy: readBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      deletedBy: deletedBy,
      type: type,
    );
  }

  /// Entity에서 생성
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      messageId: entity.messageId,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      content: entity.content,
      imageUrls: entity.imageUrls,
      readBy: entity.readBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      deletedBy: entity.deletedBy,
      type: entity.type,
    );
  }
}

// Timestamp 변환 헬퍼 (nullable)
DateTime? _timestampFromJsonNullable(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return null;
}

dynamic _timestampToJsonNullable(DateTime? dateTime) {
  if (dateTime == null) return null;
  return Timestamp.fromDate(dateTime);
}

// Timestamp 변환 헬퍼 (non-nullable)
DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

dynamic _timestampToJson(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}

// readBy 맵 변환 헬퍼
Map<String, DateTime> _readByFromJson(dynamic value) {
  if (value == null) return {};
  final map = value as Map<String, dynamic>;
  return map.map((key, val) {
    if (val is Timestamp) {
      return MapEntry(key, val.toDate());
    } else if (val is String) {
      return MapEntry(key, DateTime.parse(val));
    }
    return MapEntry(key, DateTime.now());
  });
}

Map<String, dynamic> _readByToJson(Map<String, DateTime> readBy) {
  return readBy.map((key, val) => MapEntry(key, Timestamp.fromDate(val)));
}

// MessageType 변환 헬퍼
MessageType _messageTypeFromJson(dynamic value) {
  if (value == null) return MessageType.text;
  if (value is String) {
    switch (value) {
      case 'system':
        return MessageType.system;
      case 'image':
        return MessageType.image;
      default:
        return MessageType.text;
    }
  }
  return MessageType.text;
}

String _messageTypeToJson(MessageType type) {
  switch (type) {
    case MessageType.system:
      return 'system';
    case MessageType.image:
      return 'image';
    case MessageType.text:
      return 'text';
  }
}

