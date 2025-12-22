// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatUserModelImpl _$$ChatUserModelImplFromJson(Map<String, dynamic> json) =>
    _$ChatUserModelImpl(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      lastOnlineAt: _timestampFromJsonNullable(json['lastOnlineAt']),
    );

Map<String, dynamic> _$$ChatUserModelImplToJson(_$ChatUserModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'profileImageUrl': instance.profileImageUrl,
      'lastOnlineAt': _timestampToJsonNullable(instance.lastOnlineAt),
    };
