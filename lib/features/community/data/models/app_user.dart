import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// 사용자 모델 (Firestore /users/{uid} 컬렉션)
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String displayName,
    @Default('') String email,
    @Default('user') String role, // "user" | "priest" | "staff" | "admin"
    @Default(false) bool isVerified,
    String? verifiedRole, // e.g. "priest", "parish_staff", "diocese_office"
    String? parishId, // parish or community this user belongs to
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppUser;

  const AppUser._();

  /// 공식 게시글 작성 권한이 있는지 확인
  /// priest, staff, admin 역할이고 verified된 경우에만 true
  bool get canPostOfficial {
    return isVerified &&
        (role == 'priest' || role == 'staff' || role == 'admin');
  }

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  /// Firestore Document에서 생성
  /// Firestore 필드명(snake_case)과 camelCase 모두 지원
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // JSON을 정규화 (snake_case를 camelCase로 변환)
    final normalizedJson = <String, dynamic>{
      'uid': doc.id, // doc.id를 우선 사용
      'displayName':
          data['displayName'] as String? ??
          data['nickname'] as String? ??
          'ユーザー',
      'email': data['email'] as String? ?? '',
      'role': data['role'] as String? ?? 'user',
      'isVerified':
          data['isVerified'] as bool? ?? data['is_verified'] as bool? ?? false,
      'verifiedRole':
          data['verifiedRole'] as String? ?? data['verified_role'] as String?,
      'parishId':
          data['parishId'] as String? ?? data['main_parish_id'] as String?,
      // DateTime을 ISO8601 문자열로 변환
      'createdAt': _dateTimeFromJson(
        data['createdAt'] ?? data['created_at'],
      ).toIso8601String(),
      'updatedAt': _dateTimeFromJson(
        data['updatedAt'] ?? data['updated_at'],
      ).toIso8601String(),
    };

    return AppUser.fromJson(normalizedJson);
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);
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
