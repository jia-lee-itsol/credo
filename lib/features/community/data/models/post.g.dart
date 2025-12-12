// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
  postId: json['postId'] as String,
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  authorRole: json['authorRole'] as String? ?? 'user',
  authorIsVerified: json['authorIsVerified'] as bool? ?? false,
  category: json['category'] as String? ?? 'community',
  type: json['type'] as String? ?? 'normal',
  parishId: json['parishId'] as String?,
  title: json['title'] as String,
  body: json['body'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  isPinned: json['isPinned'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  status: json['status'] as String? ?? 'published',
);

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'authorRole': instance.authorRole,
      'authorIsVerified': instance.authorIsVerified,
      'category': instance.category,
      'type': instance.type,
      'parishId': instance.parishId,
      'title': instance.title,
      'body': instance.body,
      'imageUrls': instance.imageUrls,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'isPinned': instance.isPinned,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'status': instance.status,
    };
