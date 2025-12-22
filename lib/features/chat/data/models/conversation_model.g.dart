// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationModelImpl _$$ConversationModelImplFromJson(
  Map<String, dynamic> json,
) => _$ConversationModelImpl(
  conversationId: json['conversationId'] as String,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  type: json['type'] as String,
  lastMessage: json['lastMessage'] == null
      ? null
      : LastMessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>),
  lastMessageAt: _timestampFromJsonNullable(json['lastMessageAt']),
  createdAt: _timestampFromJson(json['createdAt']),
  updatedAt: _timestampFromJson(json['updatedAt']),
  name: json['name'] as String?,
  imageUrl: json['imageUrl'] as String?,
  createdBy: json['createdBy'] as String?,
);

Map<String, dynamic> _$$ConversationModelImplToJson(
  _$ConversationModelImpl instance,
) => <String, dynamic>{
  'conversationId': instance.conversationId,
  'participants': instance.participants,
  'type': instance.type,
  'lastMessage': instance.lastMessage,
  'lastMessageAt': _timestampToJsonNullable(instance.lastMessageAt),
  'createdAt': _timestampToJson(instance.createdAt),
  'updatedAt': _timestampToJson(instance.updatedAt),
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'createdBy': instance.createdBy,
};

_$LastMessageModelImpl _$$LastMessageModelImplFromJson(
  Map<String, dynamic> json,
) => _$LastMessageModelImpl(
  content: json['content'] as String,
  senderId: json['senderId'] as String,
  createdAt: _timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$$LastMessageModelImplToJson(
  _$LastMessageModelImpl instance,
) => <String, dynamic>{
  'content': instance.content,
  'senderId': instance.senderId,
  'createdAt': _timestampToJson(instance.createdAt),
};
