import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

/// 댓글 모델 (Firestore /comments/{commentId} 컬렉션)
@freezed
class Comment with _$Comment {
  const factory Comment({
    required String commentId,
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    required DateTime createdAt,
  }) = _Comment;

  const Comment._();

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  /// Firestore Document에서 생성
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final json = <String, dynamic>{
      'commentId': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
    return Comment.fromJson(json);
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json['createdAt'] = Timestamp.fromDate(createdAt);
    return json;
  }

  /// JSON 직렬화를 위한 DateTime 변환기
  static DateTime _dateTimeFromJson(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }

  /// JSON 직렬화를 위한 DateTime 변환기
  static String _dateTimeToJson(DateTime dateTime) =>
      dateTime.toIso8601String();
}
