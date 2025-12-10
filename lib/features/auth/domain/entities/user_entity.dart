import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// 사용자 엔티티
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String userId,
    required String nickname,
    required String email,
    String? mainParishId,
    @Default([]) List<String> preferredLanguages,
    @Default([]) List<String> favoriteParishIds,
    String? profileImageUrl,
    @Default(false) bool isVerified,
    String? verifiedParishId,
    String? verifiedRole,
    String? baptismalName,
    String? feastDayId, // "month-day" 형식 (예: "1-1")
    DateTime? baptismDate, // 세례 날짜
    DateTime? confirmationDate, // 견진 날짜
    @Default([]) List<String> godchildren, // 대자녀 목록 (userId 리스트)
    String? godparentId, // 대부모 userId (1名のみ)
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserEntity;

  const UserEntity._();

  /// 공식 계정인지 확인
  bool get isOfficialAccount => isVerified && verifiedParishId != null;

  /// 기본 표시 이름
  String get displayName => nickname;
}
