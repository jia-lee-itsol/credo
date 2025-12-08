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
      'created_at': (data['created_at'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
      'updated_at': (data['updated_at'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    });
  }

  /// Entity로 변환
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      nickname: nickname,
      email: email,
      mainParishId: mainParishId,
      preferredLanguages: preferredLanguages,
      favoriteParishIds: favoriteParishIds,
      profileImageUrl: profileImageUrl,
      isVerified: isVerified,
      verifiedParishId: verifiedParishId,
      verifiedRole: verifiedRole,
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
      mainParishId: entity.mainParishId,
      preferredLanguages: entity.preferredLanguages,
      favoriteParishIds: entity.favoriteParishIds,
      profileImageUrl: entity.profileImageUrl,
      isVerified: entity.isVerified,
      verifiedParishId: entity.verifiedParishId,
      verifiedRole: entity.verifiedRole,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'nickname': nickname,
      'email': email,
      'main_parish_id': mainParishId,
      'preferred_languages': preferredLanguages,
      'favorite_parish_ids': favoriteParishIds,
      'profile_image_url': profileImageUrl,
      'is_verified': isVerified,
      'verified_parish_id': verifiedParishId,
      'verified_role': verifiedRole,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}
