// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationImpl(
  notificationId: json['notificationId'] as String,
  userId: json['userId'] as String,
  type: json['type'] as String? ?? 'mention',
  title: json['title'] as String,
  body: json['body'] as String,
  postId: json['postId'] as String?,
  commentId: json['commentId'] as String?,
  authorId: json['authorId'] as String?,
  authorName: json['authorName'] as String?,
  isRead: json['isRead'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'notificationId': instance.notificationId,
  'userId': instance.userId,
  'type': instance.type,
  'title': instance.title,
  'body': instance.body,
  'postId': instance.postId,
  'commentId': instance.commentId,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'isRead': instance.isRead,
  'createdAt': instance.createdAt.toIso8601String(),
};
