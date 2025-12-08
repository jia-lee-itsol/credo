// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      mainParishId: json['main_parish_id'] as String?,
      preferredLanguages:
          (json['preferred_languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favoriteParishIds:
          (json['favorite_parish_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      profileImageUrl: json['profile_image_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedParishId: json['verified_parish_id'] as String?,
      verifiedRole: json['verified_role'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'nickname': instance.nickname,
      'email': instance.email,
      'main_parish_id': instance.mainParishId,
      'preferred_languages': instance.preferredLanguages,
      'favorite_parish_ids': instance.favoriteParishIds,
      'profile_image_url': instance.profileImageUrl,
      'is_verified': instance.isVerified,
      'verified_parish_id': instance.verifiedParishId,
      'verified_role': instance.verifiedRole,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
