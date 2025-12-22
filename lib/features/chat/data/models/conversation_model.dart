import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/conversation_entity.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

/// 대화방 모델 (Firestore 직렬화용)
@freezed
class ConversationModel with _$ConversationModel {
  const factory ConversationModel({
    required String conversationId,
    required List<String> participants,
    required String type,
    LastMessageModel? lastMessage,
    @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
    DateTime? lastMessageAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime updatedAt,
    String? name,
    String? imageUrl,
    String? createdBy,
  }) = _ConversationModel;

  const ConversationModel._();

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel.fromJson({
      'conversationId': doc.id,
      ...data,
    });
  }

  /// Entity로 변환
  ConversationEntity toEntity() {
    return ConversationEntity(
      conversationId: conversationId,
      participants: participants,
      type: type == 'group' ? ConversationType.group : ConversationType.direct,
      lastMessage: lastMessage?.toEntity(),
      lastMessageAt: lastMessageAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      name: name,
      imageUrl: imageUrl,
      createdBy: createdBy,
    );
  }

  /// Entity에서 생성
  factory ConversationModel.fromEntity(ConversationEntity entity) {
    return ConversationModel(
      conversationId: entity.conversationId,
      participants: entity.participants,
      type: entity.type == ConversationType.group ? 'group' : 'direct',
      lastMessage: entity.lastMessage != null
          ? LastMessageModel.fromEntity(entity.lastMessage!)
          : null,
      lastMessageAt: entity.lastMessageAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      name: entity.name,
      imageUrl: entity.imageUrl,
      createdBy: entity.createdBy,
    );
  }
}

/// 마지막 메시지 모델
@freezed
class LastMessageModel with _$LastMessageModel {
  const factory LastMessageModel({
    required String content,
    required String senderId,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
  }) = _LastMessageModel;

  const LastMessageModel._();

  factory LastMessageModel.fromJson(Map<String, dynamic> json) =>
      _$LastMessageModelFromJson(json);

  LastMessageInfo toEntity() {
    return LastMessageInfo(
      content: content,
      senderId: senderId,
      createdAt: createdAt,
    );
  }

  factory LastMessageModel.fromEntity(LastMessageInfo entity) {
    return LastMessageModel(
      content: entity.content,
      senderId: entity.senderId,
      createdAt: entity.createdAt,
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

