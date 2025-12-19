// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserEntity {
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // "user", "priest", "staff", "admin"
  String? get mainParishId => throw _privateConstructorUsedError;
  List<String> get preferredLanguages => throw _privateConstructorUsedError;
  List<String> get favoriteParishIds => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  String? get verifiedParishId => throw _privateConstructorUsedError;
  String? get verifiedRole => throw _privateConstructorUsedError;
  String? get baptismalName => throw _privateConstructorUsedError;
  String? get feastDayId =>
      throw _privateConstructorUsedError; // "month-day" 형식 (예: "1-1")
  DateTime? get baptismDate => throw _privateConstructorUsedError; // 세례 날짜
  DateTime? get confirmationDate => throw _privateConstructorUsedError; // 견진 날짜
  List<String> get godchildren =>
      throw _privateConstructorUsedError; // 대자녀 목록 (userId 리스트)
  String? get godparentId =>
      throw _privateConstructorUsedError; // 대부모 userId (1名のみ)
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserEntityCopyWith<UserEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserEntityCopyWith<$Res> {
  factory $UserEntityCopyWith(
    UserEntity value,
    $Res Function(UserEntity) then,
  ) = _$UserEntityCopyWithImpl<$Res, UserEntity>;
  @useResult
  $Res call({
    String userId,
    String nickname,
    String email,
    String role,
    String? mainParishId,
    List<String> preferredLanguages,
    List<String> favoriteParishIds,
    String? profileImageUrl,
    bool isVerified,
    String? verifiedParishId,
    String? verifiedRole,
    String? baptismalName,
    String? feastDayId,
    DateTime? baptismDate,
    DateTime? confirmationDate,
    List<String> godchildren,
    String? godparentId,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$UserEntityCopyWithImpl<$Res, $Val extends UserEntity>
    implements $UserEntityCopyWith<$Res> {
  _$UserEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserEntity
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
abstract class _$$UserEntityImplCopyWith<$Res>
    implements $UserEntityCopyWith<$Res> {
  factory _$$UserEntityImplCopyWith(
    _$UserEntityImpl value,
    $Res Function(_$UserEntityImpl) then,
  ) = __$$UserEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String nickname,
    String email,
    String role,
    String? mainParishId,
    List<String> preferredLanguages,
    List<String> favoriteParishIds,
    String? profileImageUrl,
    bool isVerified,
    String? verifiedParishId,
    String? verifiedRole,
    String? baptismalName,
    String? feastDayId,
    DateTime? baptismDate,
    DateTime? confirmationDate,
    List<String> godchildren,
    String? godparentId,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$UserEntityImplCopyWithImpl<$Res>
    extends _$UserEntityCopyWithImpl<$Res, _$UserEntityImpl>
    implements _$$UserEntityImplCopyWith<$Res> {
  __$$UserEntityImplCopyWithImpl(
    _$UserEntityImpl _value,
    $Res Function(_$UserEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserEntity
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
    Object? baptismDate = freezed,
    Object? confirmationDate = freezed,
    Object? godchildren = null,
    Object? godparentId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$UserEntityImpl(
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

class _$UserEntityImpl extends _UserEntity {
  const _$UserEntityImpl({
    required this.userId,
    required this.nickname,
    required this.email,
    this.role = 'user',
    this.mainParishId,
    final List<String> preferredLanguages = const [],
    final List<String> favoriteParishIds = const [],
    this.profileImageUrl,
    this.isVerified = false,
    this.verifiedParishId,
    this.verifiedRole,
    this.baptismalName,
    this.feastDayId,
    this.baptismDate,
    this.confirmationDate,
    final List<String> godchildren = const [],
    this.godparentId,
    required this.createdAt,
    required this.updatedAt,
  }) : _preferredLanguages = preferredLanguages,
       _favoriteParishIds = favoriteParishIds,
       _godchildren = godchildren,
       super._();

  @override
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
  final String? mainParishId;
  final List<String> _preferredLanguages;
  @override
  @JsonKey()
  List<String> get preferredLanguages {
    if (_preferredLanguages is EqualUnmodifiableListView)
      return _preferredLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredLanguages);
  }

  final List<String> _favoriteParishIds;
  @override
  @JsonKey()
  List<String> get favoriteParishIds {
    if (_favoriteParishIds is EqualUnmodifiableListView)
      return _favoriteParishIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteParishIds);
  }

  @override
  final String? profileImageUrl;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  final String? verifiedParishId;
  @override
  final String? verifiedRole;
  @override
  final String? baptismalName;
  @override
  final String? feastDayId;
  // "month-day" 형식 (예: "1-1")
  @override
  final DateTime? baptismDate;
  // 세례 날짜
  @override
  final DateTime? confirmationDate;
  // 견진 날짜
  final List<String> _godchildren;
  // 견진 날짜
  @override
  @JsonKey()
  List<String> get godchildren {
    if (_godchildren is EqualUnmodifiableListView) return _godchildren;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_godchildren);
  }

  // 대자녀 목록 (userId 리스트)
  @override
  final String? godparentId;
  // 대부모 userId (1名のみ)
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserEntity(userId: $userId, nickname: $nickname, email: $email, role: $role, mainParishId: $mainParishId, preferredLanguages: $preferredLanguages, favoriteParishIds: $favoriteParishIds, profileImageUrl: $profileImageUrl, isVerified: $isVerified, verifiedParishId: $verifiedParishId, verifiedRole: $verifiedRole, baptismalName: $baptismalName, feastDayId: $feastDayId, baptismDate: $baptismDate, confirmationDate: $confirmationDate, godchildren: $godchildren, godparentId: $godparentId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserEntityImpl &&
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
    baptismDate,
    confirmationDate,
    const DeepCollectionEquality().hash(_godchildren),
    godparentId,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserEntityImplCopyWith<_$UserEntityImpl> get copyWith =>
      __$$UserEntityImplCopyWithImpl<_$UserEntityImpl>(this, _$identity);
}

abstract class _UserEntity extends UserEntity {
  const factory _UserEntity({
    required final String userId,
    required final String nickname,
    required final String email,
    final String role,
    final String? mainParishId,
    final List<String> preferredLanguages,
    final List<String> favoriteParishIds,
    final String? profileImageUrl,
    final bool isVerified,
    final String? verifiedParishId,
    final String? verifiedRole,
    final String? baptismalName,
    final String? feastDayId,
    final DateTime? baptismDate,
    final DateTime? confirmationDate,
    final List<String> godchildren,
    final String? godparentId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$UserEntityImpl;
  const _UserEntity._() : super._();

  @override
  String get userId;
  @override
  String get nickname;
  @override
  String get email;
  @override
  String get role; // "user", "priest", "staff", "admin"
  @override
  String? get mainParishId;
  @override
  List<String> get preferredLanguages;
  @override
  List<String> get favoriteParishIds;
  @override
  String? get profileImageUrl;
  @override
  bool get isVerified;
  @override
  String? get verifiedParishId;
  @override
  String? get verifiedRole;
  @override
  String? get baptismalName;
  @override
  String? get feastDayId; // "month-day" 형식 (예: "1-1")
  @override
  DateTime? get baptismDate; // 세례 날짜
  @override
  DateTime? get confirmationDate; // 견진 날짜
  @override
  List<String> get godchildren; // 대자녀 목록 (userId 리스트)
  @override
  String? get godparentId; // 대부모 userId (1名のみ)
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserEntityImplCopyWith<_$UserEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
