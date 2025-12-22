// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendModelImpl _$$FriendModelImplFromJson(Map<String, dynamic> json) =>
    _$FriendModelImpl(
      odId: json['odId'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      status: json['status'] as String,
      createdAt: _timestampFromJson(json['createdAt']),
      updatedAt: _timestampFromJsonNullable(json['updatedAt']),
      nickname: json['nickname'] as String?,
    );

Map<String, dynamic> _$$FriendModelImplToJson(_$FriendModelImpl instance) =>
    <String, dynamic>{
      'odId': instance.odId,
      'userId': instance.userId,
      'friendId': instance.friendId,
      'status': instance.status,
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': _timestampToJsonNullable(instance.updatedAt),
      'nickname': instance.nickname,
    };
