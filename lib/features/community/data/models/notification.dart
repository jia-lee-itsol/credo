import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// 알림 모델 (Firestore /notifications/{notificationId} 컬렉션)
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String notificationId,
    required String userId, // 알림을 받을 사용자 ID
    @Default('mention') String type, // "mention" | "comment" | "like" | "reply"
    required String title,
    required String body,
    String? postId, // 관련 게시글 ID
    String? commentId, // 관련 댓글 ID
    String? authorId, // 알림을 발생시킨 사용자 ID
    String? authorName, // 알림을 발생시킨 사용자 이름
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _AppNotification;

  const AppNotification._();

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  /// Firestore Document에서 생성
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final json = <String, dynamic>{
      'notificationId': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
    return AppNotification.fromJson(json);
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
