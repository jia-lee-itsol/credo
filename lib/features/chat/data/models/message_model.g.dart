// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageModelImpl _$$MessageModelImplFromJson(
  Map<String, dynamic> json,
) => _$MessageModelImpl(
  messageId: json['messageId'] as String,
  conversationId: json['conversationId'] as String,
  senderId: json['senderId'] as String,
  content: json['content'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  readBy: json['readBy'] == null ? const {} : _readByFromJson(json['readBy']),
  createdAt: _timestampFromJson(json['createdAt']),
  updatedAt: _timestampFromJsonNullable(json['updatedAt']),
  deletedAt: _timestampFromJsonNullable(json['deletedAt']),
  deletedBy: json['deletedBy'] as String?,
  type: json['type'] == null
      ? MessageType.text
      : _messageTypeFromJson(json['type']),
);

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'content': instance.content,
      'imageUrls': instance.imageUrls,
      'readBy': _readByToJson(instance.readBy),
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': _timestampToJsonNullable(instance.updatedAt),
      'deletedAt': _timestampToJsonNullable(instance.deletedAt),
      'deletedBy': instance.deletedBy,
      'type': _messageTypeToJson(instance.type),
    };
