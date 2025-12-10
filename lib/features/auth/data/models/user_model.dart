import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// 사용자 데이터 모델
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @JsonKey(name: 'user_id') required String userId,
    required String nickname,
    required String email,
    @Default('user') String role, // "user", "priest", "staff", "admin"
    @JsonKey(name: 'main_parish_id') String? mainParishId,
    @JsonKey(name: 'preferred_languages')
    @Default([])
    List<String> preferredLanguages,
    @JsonKey(name: 'favorite_parish_ids')
    @Default([])
    List<String> favoriteParishIds,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'verified_parish_id') String? verifiedParishId,
    @JsonKey(name: 'verified_role') String? verifiedRole,
    @JsonKey(name: 'baptismal_name') String? baptismalName,
    @JsonKey(name: 'feast_day_id') String? feastDayId,
    @JsonKey(name: 'baptism_date') DateTime? baptismDate,
    @JsonKey(name: 'confirmation_date') DateTime? confirmationDate,
    @JsonKey(name: 'godchildren') @Default([]) List<String> godchildren,
    @JsonKey(name: 'godparent_id') String? godparentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Firestore Document에서 생성
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'user_id': doc.id,
      ...data,
      'baptism_date': (data['baptism_date'] as Timestamp?)
          ?.toDate()
          .toIso8601String(),
      'confirmation_date': (data['confirmation_date'] as Timestamp?)
          ?.toDate()
          .toIso8601String(),
      'created_at':
          (data['created_at'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
      'updated_at':
          (data['updated_at'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    });
  }

  /// Entity로 변환
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      nickname: nickname,
      email: email,
      role: role,
      mainParishId: mainParishId,
      preferredLanguages: preferredLanguages,
      favoriteParishIds: favoriteParishIds,
      profileImageUrl: profileImageUrl,
      isVerified: isVerified,
      verifiedParishId: verifiedParishId,
      verifiedRole: verifiedRole,
      baptismalName: baptismalName,
      feastDayId: feastDayId,
      baptismDate: baptismDate,
      confirmationDate: confirmationDate,
      godchildren: godchildren,
      godparentId: godparentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Entity에서 생성
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      nickname: entity.nickname,
      email: entity.email,
      role: entity.role,
      mainParishId: entity.mainParishId,
      preferredLanguages: entity.preferredLanguages,
      favoriteParishIds: entity.favoriteParishIds,
      profileImageUrl: entity.profileImageUrl,
      isVerified: entity.isVerified,
      verifiedParishId: entity.verifiedParishId,
      verifiedRole: entity.verifiedRole,
      baptismalName: entity.baptismalName,
      feastDayId: entity.feastDayId,
      baptismDate: entity.baptismDate,
      confirmationDate: entity.confirmationDate,
      godchildren: entity.godchildren,
      godparentId: entity.godparentId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'nickname': nickname,
      'email': email,
      'role': role,
      'main_parish_id': mainParishId,
      'preferred_languages': preferredLanguages,
      'favorite_parish_ids': favoriteParishIds,
      'profile_image_url': profileImageUrl,
      'is_verified': isVerified,
      'verified_parish_id': verifiedParishId,
      'verified_role': verifiedRole,
      'baptismal_name': baptismalName,
      'feast_day_id': feastDayId,
      'godchildren': godchildren,
      'godparent_id': godparentId,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };

    if (baptismDate != null) {
      map['baptism_date'] = Timestamp.fromDate(baptismDate!);
    }
    if (confirmationDate != null) {
      map['confirmation_date'] = Timestamp.fromDate(confirmationDate!);
    }

    return map;
  }
}
