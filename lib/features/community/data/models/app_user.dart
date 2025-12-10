import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 모델 (Firestore /users/{uid} 컬렉션)
class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String role; // "user" | "priest" | "staff" | "admin"
  final bool isVerified;
  final String? verifiedRole; // e.g. "priest", "parish_staff", "diocese_office"
  final String? parishId; // parish or community this user belongs to
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    required this.isVerified,
    this.verifiedRole,
    this.parishId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 공식 게시글 작성 권한이 있는지 확인
  /// priest, staff, admin 역할이고 verified된 경우에만 true
  bool get canPostOfficial {
    return isVerified &&
        (role == 'priest' || role == 'staff' || role == 'admin');
  }

  /// Firestore Document에서 생성
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser.fromJson({'uid': doc.id, ...data});
  }

  /// JSON에서 생성
  /// Firestore 필드명(snake_case)과 camelCase 모두 지원
  factory AppUser.fromJson(Map<String, dynamic> json) {
    // uid 또는 user_id 지원
    final uid = json['uid'] as String? ?? json['user_id'] as String?;
    if (uid == null) {
      throw Exception('uid 또는 user_id 필드가 필요합니다');
    }

    // displayName 또는 nickname 지원
    final displayName =
        json['displayName'] as String? ?? json['nickname'] as String? ?? 'ユーザー';

    // isVerified 또는 is_verified 지원
    final isVerified =
        json['isVerified'] as bool? ?? json['is_verified'] as bool? ?? false;

    // verifiedRole 또는 verified_role 지원
    final verifiedRole =
        json['verifiedRole'] as String? ?? json['verified_role'] as String?;

    // parishId 또는 main_parish_id 지원
    final parishId =
        json['parishId'] as String? ?? json['main_parish_id'] as String?;

    // createdAt 또는 created_at 지원
    final createdAt = _parseTimestamp(json['createdAt'] ?? json['created_at']);

    // updatedAt 또는 updated_at 지원
    final updatedAt = _parseTimestamp(json['updatedAt'] ?? json['updated_at']);

    return AppUser(
      uid: uid,
      displayName: displayName,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      isVerified: isVerified,
      verifiedRole: verifiedRole,
      parishId: parishId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Firestore Timestamp를 DateTime으로 변환
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'role': role,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };

    if (verifiedRole != null) {
      map['verifiedRole'] = verifiedRole;
    }
    if (parishId != null) {
      map['parishId'] = parishId;
    }

    return map;
  }

  /// 복사본 생성 (일부 필드만 업데이트)
  AppUser copyWith({
    String? displayName,
    String? email,
    String? role,
    bool? isVerified,
    String? verifiedRole,
    String? parishId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      verifiedRole: verifiedRole ?? this.verifiedRole,
      parishId: parishId ?? this.parishId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, displayName: $displayName, role: $role, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
