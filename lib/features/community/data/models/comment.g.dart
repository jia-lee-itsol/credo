// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(
  Map<String, dynamic> json,
) => _$CommentImpl(
  commentId: json['commentId'] as String,
  postId: json['postId'] as String,
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  content: json['content'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  pdfUrls:
      (json['pdfUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'commentId': instance.commentId,
      'postId': instance.postId,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'content': instance.content,
      'imageUrls': instance.imageUrls,
      'pdfUrls': instance.pdfUrls,
      'createdAt': instance.createdAt.toIso8601String(),
    };
