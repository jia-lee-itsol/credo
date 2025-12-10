// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostModelImpl _$$PostModelImplFromJson(Map<String, dynamic> json) =>
    _$PostModelImpl(
      postId: json['post_id'] as String,
      parishId: json['parish_id'] as String?,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isOfficial: json['is_official'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      authorNickname: json['author_nickname'] as String?,
      authorProfileImage: json['author_profile_image'] as String?,
      authorRole: json['author_role'] as String?,
      authorIsVerified: json['author_is_verified'] as bool? ?? false,
      category: json['category'] as String? ?? 'community',
      type: json['type'] as String? ?? 'normal',
      status: json['status'] as String? ?? 'published',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PostModelImplToJson(_$PostModelImpl instance) =>
    <String, dynamic>{
      'post_id': instance.postId,
      'parish_id': instance.parishId,
      'user_id': instance.userId,
      'title': instance.title,
      'content': instance.content,
      'is_official': instance.isOfficial,
      'is_pinned': instance.isPinned,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
      'author_nickname': instance.authorNickname,
      'author_profile_image': instance.authorProfileImage,
      'author_role': instance.authorRole,
      'author_is_verified': instance.authorIsVerified,
      'category': instance.category,
      'type': instance.type,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$CommentModelImpl _$$CommentModelImplFromJson(Map<String, dynamic> json) =>
    _$CommentModelImpl(
      commentId: json['comment_id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      authorNickname: json['author_nickname'] as String?,
      authorProfileImage: json['author_profile_image'] as String?,
      isOfficial: json['is_official'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$CommentModelImplToJson(_$CommentModelImpl instance) =>
    <String, dynamic>{
      'comment_id': instance.commentId,
      'post_id': instance.postId,
      'user_id': instance.userId,
      'content': instance.content,
      'author_nickname': instance.authorNickname,
      'author_profile_image': instance.authorProfileImage,
      'is_official': instance.isOfficial,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$LikeModelImpl _$$LikeModelImplFromJson(Map<String, dynamic> json) =>
    _$LikeModelImpl(
      likeId: json['like_id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$LikeModelImplToJson(_$LikeModelImpl instance) =>
    <String, dynamic>{
      'like_id': instance.likeId,
      'post_id': instance.postId,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
    };
