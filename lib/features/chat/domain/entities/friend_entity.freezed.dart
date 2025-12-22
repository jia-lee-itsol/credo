// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FriendEntity {
  String get odId => throw _privateConstructorUsedError; // 관계 문서 ID
  String get userId => throw _privateConstructorUsedError; // 현재 사용자
  String get friendId => throw _privateConstructorUsedError; // 상대방 사용자
  FriendStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get nickname => throw _privateConstructorUsedError;

  /// Create a copy of FriendEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendEntityCopyWith<FriendEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendEntityCopyWith<$Res> {
  factory $FriendEntityCopyWith(
    FriendEntity value,
    $Res Function(FriendEntity) then,
  ) = _$FriendEntityCopyWithImpl<$Res, FriendEntity>;
  @useResult
  $Res call({
    String odId,
    String userId,
    String friendId,
    FriendStatus status,
    DateTime createdAt,
    DateTime? updatedAt,
    String? nickname,
  });
}

/// @nodoc
class _$FriendEntityCopyWithImpl<$Res, $Val extends FriendEntity>
    implements $FriendEntityCopyWith<$Res> {
  _$FriendEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? odId = null,
    Object? userId = null,
    Object? friendId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? nickname = freezed,
  }) {
    return _then(
      _value.copyWith(
            odId: null == odId
                ? _value.odId
                : odId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            friendId: null == friendId
                ? _value.friendId
                : friendId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as FriendStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            nickname: freezed == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FriendEntityImplCopyWith<$Res>
    implements $FriendEntityCopyWith<$Res> {
  factory _$$FriendEntityImplCopyWith(
    _$FriendEntityImpl value,
    $Res Function(_$FriendEntityImpl) then,
  ) = __$$FriendEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String odId,
    String userId,
    String friendId,
    FriendStatus status,
    DateTime createdAt,
    DateTime? updatedAt,
    String? nickname,
  });
}

/// @nodoc
class __$$FriendEntityImplCopyWithImpl<$Res>
    extends _$FriendEntityCopyWithImpl<$Res, _$FriendEntityImpl>
    implements _$$FriendEntityImplCopyWith<$Res> {
  __$$FriendEntityImplCopyWithImpl(
    _$FriendEntityImpl _value,
    $Res Function(_$FriendEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? odId = null,
    Object? userId = null,
    Object? friendId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? nickname = freezed,
  }) {
    return _then(
      _$FriendEntityImpl(
        odId: null == odId
            ? _value.odId
            : odId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        friendId: null == friendId
            ? _value.friendId
            : friendId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as FriendStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        nickname: freezed == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$FriendEntityImpl extends _FriendEntity {
  const _$FriendEntityImpl({
    required this.odId,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.nickname,
  }) : super._();

  @override
  final String odId;
  // 관계 문서 ID
  @override
  final String userId;
  // 현재 사용자
  @override
  final String friendId;
  // 상대방 사용자
  @override
  final FriendStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? nickname;

  @override
  String toString() {
    return 'FriendEntity(odId: $odId, userId: $userId, friendId: $friendId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendEntityImpl &&
            (identical(other.odId, odId) || other.odId == odId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.friendId, friendId) ||
                other.friendId == friendId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    odId,
    userId,
    friendId,
    status,
    createdAt,
    updatedAt,
    nickname,
  );

  /// Create a copy of FriendEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendEntityImplCopyWith<_$FriendEntityImpl> get copyWith =>
      __$$FriendEntityImplCopyWithImpl<_$FriendEntityImpl>(this, _$identity);
}

abstract class _FriendEntity extends FriendEntity {
  const factory _FriendEntity({
    required final String odId,
    required final String userId,
    required final String friendId,
    required final FriendStatus status,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final String? nickname,
  }) = _$FriendEntityImpl;
  const _FriendEntity._() : super._();

  @override
  String get odId; // 관계 문서 ID
  @override
  String get userId; // 현재 사용자
  @override
  String get friendId; // 상대방 사용자
  @override
  FriendStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get nickname;

  /// Create a copy of FriendEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendEntityImplCopyWith<_$FriendEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FriendWithUserInfo {
  FriendEntity get friend => throw _privateConstructorUsedError;
  String get friendUserId => throw _privateConstructorUsedError;
  String get friendNickname => throw _privateConstructorUsedError;
  String? get friendProfileImageUrl => throw _privateConstructorUsedError;
  DateTime? get lastOnlineAt => throw _privateConstructorUsedError;
  String? get communityName => throw _privateConstructorUsedError;

  /// Create a copy of FriendWithUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendWithUserInfoCopyWith<FriendWithUserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendWithUserInfoCopyWith<$Res> {
  factory $FriendWithUserInfoCopyWith(
    FriendWithUserInfo value,
    $Res Function(FriendWithUserInfo) then,
  ) = _$FriendWithUserInfoCopyWithImpl<$Res, FriendWithUserInfo>;
  @useResult
  $Res call({
    FriendEntity friend,
    String friendUserId,
    String friendNickname,
    String? friendProfileImageUrl,
    DateTime? lastOnlineAt,
    String? communityName,
  });

  $FriendEntityCopyWith<$Res> get friend;
}

/// @nodoc
class _$FriendWithUserInfoCopyWithImpl<$Res, $Val extends FriendWithUserInfo>
    implements $FriendWithUserInfoCopyWith<$Res> {
  _$FriendWithUserInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendWithUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friend = null,
    Object? friendUserId = null,
    Object? friendNickname = null,
    Object? friendProfileImageUrl = freezed,
    Object? lastOnlineAt = freezed,
    Object? communityName = freezed,
  }) {
    return _then(
      _value.copyWith(
            friend: null == friend
                ? _value.friend
                : friend // ignore: cast_nullable_to_non_nullable
                      as FriendEntity,
            friendUserId: null == friendUserId
                ? _value.friendUserId
                : friendUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            friendNickname: null == friendNickname
                ? _value.friendNickname
                : friendNickname // ignore: cast_nullable_to_non_nullable
                      as String,
            friendProfileImageUrl: freezed == friendProfileImageUrl
                ? _value.friendProfileImageUrl
                : friendProfileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastOnlineAt: freezed == lastOnlineAt
                ? _value.lastOnlineAt
                : lastOnlineAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            communityName: freezed == communityName
                ? _value.communityName
                : communityName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of FriendWithUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FriendEntityCopyWith<$Res> get friend {
    return $FriendEntityCopyWith<$Res>(_value.friend, (value) {
      return _then(_value.copyWith(friend: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FriendWithUserInfoImplCopyWith<$Res>
    implements $FriendWithUserInfoCopyWith<$Res> {
  factory _$$FriendWithUserInfoImplCopyWith(
    _$FriendWithUserInfoImpl value,
    $Res Function(_$FriendWithUserInfoImpl) then,
  ) = __$$FriendWithUserInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    FriendEntity friend,
    String friendUserId,
    String friendNickname,
    String? friendProfileImageUrl,
    DateTime? lastOnlineAt,
    String? communityName,
  });

  @override
  $FriendEntityCopyWith<$Res> get friend;
}

/// @nodoc
class __$$FriendWithUserInfoImplCopyWithImpl<$Res>
    extends _$FriendWithUserInfoCopyWithImpl<$Res, _$FriendWithUserInfoImpl>
    implements _$$FriendWithUserInfoImplCopyWith<$Res> {
  __$$FriendWithUserInfoImplCopyWithImpl(
    _$FriendWithUserInfoImpl _value,
    $Res Function(_$FriendWithUserInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendWithUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friend = null,
    Object? friendUserId = null,
    Object? friendNickname = null,
    Object? friendProfileImageUrl = freezed,
    Object? lastOnlineAt = freezed,
    Object? communityName = freezed,
  }) {
    return _then(
      _$FriendWithUserInfoImpl(
        friend: null == friend
            ? _value.friend
            : friend // ignore: cast_nullable_to_non_nullable
                  as FriendEntity,
        friendUserId: null == friendUserId
            ? _value.friendUserId
            : friendUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        friendNickname: null == friendNickname
            ? _value.friendNickname
            : friendNickname // ignore: cast_nullable_to_non_nullable
                  as String,
        friendProfileImageUrl: freezed == friendProfileImageUrl
            ? _value.friendProfileImageUrl
            : friendProfileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastOnlineAt: freezed == lastOnlineAt
            ? _value.lastOnlineAt
            : lastOnlineAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        communityName: freezed == communityName
            ? _value.communityName
            : communityName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$FriendWithUserInfoImpl implements _FriendWithUserInfo {
  const _$FriendWithUserInfoImpl({
    required this.friend,
    required this.friendUserId,
    required this.friendNickname,
    this.friendProfileImageUrl,
    this.lastOnlineAt,
    this.communityName,
  });

  @override
  final FriendEntity friend;
  @override
  final String friendUserId;
  @override
  final String friendNickname;
  @override
  final String? friendProfileImageUrl;
  @override
  final DateTime? lastOnlineAt;
  @override
  final String? communityName;

  @override
  String toString() {
    return 'FriendWithUserInfo(friend: $friend, friendUserId: $friendUserId, friendNickname: $friendNickname, friendProfileImageUrl: $friendProfileImageUrl, lastOnlineAt: $lastOnlineAt, communityName: $communityName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendWithUserInfoImpl &&
            (identical(other.friend, friend) || other.friend == friend) &&
            (identical(other.friendUserId, friendUserId) ||
                other.friendUserId == friendUserId) &&
            (identical(other.friendNickname, friendNickname) ||
                other.friendNickname == friendNickname) &&
            (identical(other.friendProfileImageUrl, friendProfileImageUrl) ||
                other.friendProfileImageUrl == friendProfileImageUrl) &&
            (identical(other.lastOnlineAt, lastOnlineAt) ||
                other.lastOnlineAt == lastOnlineAt) &&
            (identical(other.communityName, communityName) ||
                other.communityName == communityName));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    friend,
    friendUserId,
    friendNickname,
    friendProfileImageUrl,
    lastOnlineAt,
    communityName,
  );

  /// Create a copy of FriendWithUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendWithUserInfoImplCopyWith<_$FriendWithUserInfoImpl> get copyWith =>
      __$$FriendWithUserInfoImplCopyWithImpl<_$FriendWithUserInfoImpl>(
        this,
        _$identity,
      );
}

abstract class _FriendWithUserInfo implements FriendWithUserInfo {
  const factory _FriendWithUserInfo({
    required final FriendEntity friend,
    required final String friendUserId,
    required final String friendNickname,
    final String? friendProfileImageUrl,
    final DateTime? lastOnlineAt,
    final String? communityName,
  }) = _$FriendWithUserInfoImpl;

  @override
  FriendEntity get friend;
  @override
  String get friendUserId;
  @override
  String get friendNickname;
  @override
  String? get friendProfileImageUrl;
  @override
  DateTime? get lastOnlineAt;
  @override
  String? get communityName;

  /// Create a copy of FriendWithUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendWithUserInfoImplCopyWith<_$FriendWithUserInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
