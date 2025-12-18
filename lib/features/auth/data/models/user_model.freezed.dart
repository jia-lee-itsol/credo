// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // "user", "priest", "staff", "admin"
  @JsonKey(name: 'main_parish_id')
  String? get mainParishId => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_languages')
  List<String> get preferredLanguages => throw _privateConstructorUsedError;
  @JsonKey(name: 'favorite_parish_ids')
  List<String> get favoriteParishIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_image_url')
  String? get profileImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_verified')
  bool get isVerified => throw _privateConstructorUsedError;
  @JsonKey(name: 'verified_parish_id')
  String? get verifiedParishId => throw _privateConstructorUsedError;
  @JsonKey(name: 'verified_role')
  String? get verifiedRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'baptismal_name')
  String? get baptismalName => throw _privateConstructorUsedError;
  @JsonKey(name: 'feast_day_id')
  String? get feastDayId => throw _privateConstructorUsedError;
  @JsonKey(name: 'feast_day_name')
  String? get feastDayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'baptism_date')
  DateTime? get baptismDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'confirmation_date')
  DateTime? get confirmationDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'godchildren')
  List<String> get godchildren => throw _privateConstructorUsedError;
  @JsonKey(name: 'godparent_id')
  String? get godparentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    String nickname,
    String email,
    String role,
    @JsonKey(name: 'main_parish_id') String? mainParishId,
    @JsonKey(name: 'preferred_languages') List<String> preferredLanguages,
    @JsonKey(name: 'favorite_parish_ids') List<String> favoriteParishIds,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    @JsonKey(name: 'is_verified') bool isVerified,
    @JsonKey(name: 'verified_parish_id') String? verifiedParishId,
    @JsonKey(name: 'verified_role') String? verifiedRole,
    @JsonKey(name: 'baptismal_name') String? baptismalName,
    @JsonKey(name: 'feast_day_id') String? feastDayId,
    @JsonKey(name: 'feast_day_name') String? feastDayName,
    @JsonKey(name: 'baptism_date') DateTime? baptismDate,
    @JsonKey(name: 'confirmation_date') DateTime? confirmationDate,
    @JsonKey(name: 'godchildren') List<String> godchildren,
    @JsonKey(name: 'godparent_id') String? godparentId,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? email = null,
    Object? role = null,
    Object? mainParishId = freezed,
    Object? preferredLanguages = null,
    Object? favoriteParishIds = null,
    Object? profileImageUrl = freezed,
    Object? isVerified = null,
    Object? verifiedParishId = freezed,
    Object? verifiedRole = freezed,
    Object? baptismalName = freezed,
    Object? feastDayId = freezed,
    Object? feastDayName = freezed,
    Object? baptismDate = freezed,
    Object? confirmationDate = freezed,
    Object? godchildren = null,
    Object? godparentId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            mainParishId: freezed == mainParishId
                ? _value.mainParishId
                : mainParishId // ignore: cast_nullable_to_non_nullable
                      as String?,
            preferredLanguages: null == preferredLanguages
                ? _value.preferredLanguages
                : preferredLanguages // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            favoriteParishIds: null == favoriteParishIds
                ? _value.favoriteParishIds
                : favoriteParishIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            verifiedParishId: freezed == verifiedParishId
                ? _value.verifiedParishId
                : verifiedParishId // ignore: cast_nullable_to_non_nullable
                      as String?,
            verifiedRole: freezed == verifiedRole
                ? _value.verifiedRole
                : verifiedRole // ignore: cast_nullable_to_non_nullable
                      as String?,
            baptismalName: freezed == baptismalName
                ? _value.baptismalName
                : baptismalName // ignore: cast_nullable_to_non_nullable
                      as String?,
            feastDayId: freezed == feastDayId
                ? _value.feastDayId
                : feastDayId // ignore: cast_nullable_to_non_nullable
                      as String?,
            feastDayName: freezed == feastDayName
                ? _value.feastDayName
                : feastDayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            baptismDate: freezed == baptismDate
                ? _value.baptismDate
                : baptismDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            confirmationDate: freezed == confirmationDate
                ? _value.confirmationDate
                : confirmationDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            godchildren: null == godchildren
                ? _value.godchildren
                : godchildren // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            godparentId: freezed == godparentId
                ? _value.godparentId
                : godparentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    String nickname,
    String email,
    String role,
    @JsonKey(name: 'main_parish_id') String? mainParishId,
    @JsonKey(name: 'preferred_languages') List<String> preferredLanguages,
    @JsonKey(name: 'favorite_parish_ids') List<String> favoriteParishIds,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    @JsonKey(name: 'is_verified') bool isVerified,
    @JsonKey(name: 'verified_parish_id') String? verifiedParishId,
    @JsonKey(name: 'verified_role') String? verifiedRole,
    @JsonKey(name: 'baptismal_name') String? baptismalName,
    @JsonKey(name: 'feast_day_id') String? feastDayId,
    @JsonKey(name: 'feast_day_name') String? feastDayName,
    @JsonKey(name: 'baptism_date') DateTime? baptismDate,
    @JsonKey(name: 'confirmation_date') DateTime? confirmationDate,
    @JsonKey(name: 'godchildren') List<String> godchildren,
    @JsonKey(name: 'godparent_id') String? godparentId,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? email = null,
    Object? role = null,
    Object? mainParishId = freezed,
    Object? preferredLanguages = null,
    Object? favoriteParishIds = null,
    Object? profileImageUrl = freezed,
    Object? isVerified = null,
    Object? verifiedParishId = freezed,
    Object? verifiedRole = freezed,
    Object? baptismalName = freezed,
    Object? feastDayId = freezed,
    Object? feastDayName = freezed,
    Object? baptismDate = freezed,
    Object? confirmationDate = freezed,
    Object? godchildren = null,
    Object? godparentId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$UserModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        mainParishId: freezed == mainParishId
            ? _value.mainParishId
            : mainParishId // ignore: cast_nullable_to_non_nullable
                  as String?,
        preferredLanguages: null == preferredLanguages
            ? _value._preferredLanguages
            : preferredLanguages // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        favoriteParishIds: null == favoriteParishIds
            ? _value._favoriteParishIds
            : favoriteParishIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        verifiedParishId: freezed == verifiedParishId
            ? _value.verifiedParishId
            : verifiedParishId // ignore: cast_nullable_to_non_nullable
                  as String?,
        verifiedRole: freezed == verifiedRole
            ? _value.verifiedRole
            : verifiedRole // ignore: cast_nullable_to_non_nullable
                  as String?,
        baptismalName: freezed == baptismalName
            ? _value.baptismalName
            : baptismalName // ignore: cast_nullable_to_non_nullable
                  as String?,
        feastDayId: freezed == feastDayId
            ? _value.feastDayId
            : feastDayId // ignore: cast_nullable_to_non_nullable
                  as String?,
        feastDayName: freezed == feastDayName
            ? _value.feastDayName
            : feastDayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        baptismDate: freezed == baptismDate
            ? _value.baptismDate
            : baptismDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        confirmationDate: freezed == confirmationDate
            ? _value.confirmationDate
            : confirmationDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        godchildren: null == godchildren
            ? _value._godchildren
            : godchildren // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        godparentId: freezed == godparentId
            ? _value.godparentId
            : godparentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl({
    @JsonKey(name: 'user_id') required this.userId,
    required this.nickname,
    required this.email,
    this.role = 'user',
    @JsonKey(name: 'main_parish_id') this.mainParishId,
    @JsonKey(name: 'preferred_languages')
    final List<String> preferredLanguages = const [],
    @JsonKey(name: 'favorite_parish_ids')
    final List<String> favoriteParishIds = const [],
    @JsonKey(name: 'profile_image_url') this.profileImageUrl,
    @JsonKey(name: 'is_verified') this.isVerified = false,
    @JsonKey(name: 'verified_parish_id') this.verifiedParishId,
    @JsonKey(name: 'verified_role') this.verifiedRole,
    @JsonKey(name: 'baptismal_name') this.baptismalName,
    @JsonKey(name: 'feast_day_id') this.feastDayId,
    @JsonKey(name: 'feast_day_name') this.feastDayName,
    @JsonKey(name: 'baptism_date') this.baptismDate,
    @JsonKey(name: 'confirmation_date') this.confirmationDate,
    @JsonKey(name: 'godchildren') final List<String> godchildren = const [],
    @JsonKey(name: 'godparent_id') this.godparentId,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _preferredLanguages = preferredLanguages,
       _favoriteParishIds = favoriteParishIds,
       _godchildren = godchildren,
       super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String nickname;
  @override
  final String email;
  @override
  @JsonKey()
  final String role;
  // "user", "priest", "staff", "admin"
  @override
  @JsonKey(name: 'main_parish_id')
  final String? mainParishId;
  final List<String> _preferredLanguages;
  @override
  @JsonKey(name: 'preferred_languages')
  List<String> get preferredLanguages {
    if (_preferredLanguages is EqualUnmodifiableListView)
      return _preferredLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredLanguages);
  }

  final List<String> _favoriteParishIds;
  @override
  @JsonKey(name: 'favorite_parish_ids')
  List<String> get favoriteParishIds {
    if (_favoriteParishIds is EqualUnmodifiableListView)
      return _favoriteParishIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteParishIds);
  }

  @override
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  @override
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @override
  @JsonKey(name: 'verified_parish_id')
  final String? verifiedParishId;
  @override
  @JsonKey(name: 'verified_role')
  final String? verifiedRole;
  @override
  @JsonKey(name: 'baptismal_name')
  final String? baptismalName;
  @override
  @JsonKey(name: 'feast_day_id')
  final String? feastDayId;
  @override
  @JsonKey(name: 'feast_day_name')
  final String? feastDayName;
  @override
  @JsonKey(name: 'baptism_date')
  final DateTime? baptismDate;
  @override
  @JsonKey(name: 'confirmation_date')
  final DateTime? confirmationDate;
  final List<String> _godchildren;
  @override
  @JsonKey(name: 'godchildren')
  List<String> get godchildren {
    if (_godchildren is EqualUnmodifiableListView) return _godchildren;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_godchildren);
  }

  @override
  @JsonKey(name: 'godparent_id')
  final String? godparentId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserModel(userId: $userId, nickname: $nickname, email: $email, role: $role, mainParishId: $mainParishId, preferredLanguages: $preferredLanguages, favoriteParishIds: $favoriteParishIds, profileImageUrl: $profileImageUrl, isVerified: $isVerified, verifiedParishId: $verifiedParishId, verifiedRole: $verifiedRole, baptismalName: $baptismalName, feastDayId: $feastDayId, feastDayName: $feastDayName, baptismDate: $baptismDate, confirmationDate: $confirmationDate, godchildren: $godchildren, godparentId: $godparentId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.mainParishId, mainParishId) ||
                other.mainParishId == mainParishId) &&
            const DeepCollectionEquality().equals(
              other._preferredLanguages,
              _preferredLanguages,
            ) &&
            const DeepCollectionEquality().equals(
              other._favoriteParishIds,
              _favoriteParishIds,
            ) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.verifiedParishId, verifiedParishId) ||
                other.verifiedParishId == verifiedParishId) &&
            (identical(other.verifiedRole, verifiedRole) ||
                other.verifiedRole == verifiedRole) &&
            (identical(other.baptismalName, baptismalName) ||
                other.baptismalName == baptismalName) &&
            (identical(other.feastDayId, feastDayId) ||
                other.feastDayId == feastDayId) &&
            (identical(other.feastDayName, feastDayName) ||
                other.feastDayName == feastDayName) &&
            (identical(other.baptismDate, baptismDate) ||
                other.baptismDate == baptismDate) &&
            (identical(other.confirmationDate, confirmationDate) ||
                other.confirmationDate == confirmationDate) &&
            const DeepCollectionEquality().equals(
              other._godchildren,
              _godchildren,
            ) &&
            (identical(other.godparentId, godparentId) ||
                other.godparentId == godparentId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    userId,
    nickname,
    email,
    role,
    mainParishId,
    const DeepCollectionEquality().hash(_preferredLanguages),
    const DeepCollectionEquality().hash(_favoriteParishIds),
    profileImageUrl,
    isVerified,
    verifiedParishId,
    verifiedRole,
    baptismalName,
    feastDayId,
    feastDayName,
    baptismDate,
    confirmationDate,
    const DeepCollectionEquality().hash(_godchildren),
    godparentId,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel({
    @JsonKey(name: 'user_id') required final String userId,
    required final String nickname,
    required final String email,
    final String role,
    @JsonKey(name: 'main_parish_id') final String? mainParishId,
    @JsonKey(name: 'preferred_languages') final List<String> preferredLanguages,
    @JsonKey(name: 'favorite_parish_ids') final List<String> favoriteParishIds,
    @JsonKey(name: 'profile_image_url') final String? profileImageUrl,
    @JsonKey(name: 'is_verified') final bool isVerified,
    @JsonKey(name: 'verified_parish_id') final String? verifiedParishId,
    @JsonKey(name: 'verified_role') final String? verifiedRole,
    @JsonKey(name: 'baptismal_name') final String? baptismalName,
    @JsonKey(name: 'feast_day_id') final String? feastDayId,
    @JsonKey(name: 'feast_day_name') final String? feastDayName,
    @JsonKey(name: 'baptism_date') final DateTime? baptismDate,
    @JsonKey(name: 'confirmation_date') final DateTime? confirmationDate,
    @JsonKey(name: 'godchildren') final List<String> godchildren,
    @JsonKey(name: 'godparent_id') final String? godparentId,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get nickname;
  @override
  String get email;
  @override
  String get role; // "user", "priest", "staff", "admin"
  @override
  @JsonKey(name: 'main_parish_id')
  String? get mainParishId;
  @override
  @JsonKey(name: 'preferred_languages')
  List<String> get preferredLanguages;
  @override
  @JsonKey(name: 'favorite_parish_ids')
  List<String> get favoriteParishIds;
  @override
  @JsonKey(name: 'profile_image_url')
  String? get profileImageUrl;
  @override
  @JsonKey(name: 'is_verified')
  bool get isVerified;
  @override
  @JsonKey(name: 'verified_parish_id')
  String? get verifiedParishId;
  @override
  @JsonKey(name: 'verified_role')
  String? get verifiedRole;
  @override
  @JsonKey(name: 'baptismal_name')
  String? get baptismalName;
  @override
  @JsonKey(name: 'feast_day_id')
  String? get feastDayId;
  @override
  @JsonKey(name: 'feast_day_name')
  String? get feastDayName;
  @override
  @JsonKey(name: 'baptism_date')
  DateTime? get baptismDate;
  @override
  @JsonKey(name: 'confirmation_date')
  DateTime? get confirmationDate;
  @override
  @JsonKey(name: 'godchildren')
  List<String> get godchildren;
  @override
  @JsonKey(name: 'godparent_id')
  String? get godparentId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
