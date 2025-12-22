// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_user_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChatUserEntity {
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  DateTime? get lastOnlineAt => throw _privateConstructorUsedError;

  /// Create a copy of ChatUserEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatUserEntityCopyWith<ChatUserEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatUserEntityCopyWith<$Res> {
  factory $ChatUserEntityCopyWith(
    ChatUserEntity value,
    $Res Function(ChatUserEntity) then,
  ) = _$ChatUserEntityCopyWithImpl<$Res, ChatUserEntity>;
  @useResult
  $Res call({
    String userId,
    String nickname,
    String? profileImageUrl,
    DateTime? lastOnlineAt,
  });
}

/// @nodoc
class _$ChatUserEntityCopyWithImpl<$Res, $Val extends ChatUserEntity>
    implements $ChatUserEntityCopyWith<$Res> {
  _$ChatUserEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatUserEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? profileImageUrl = freezed,
    Object? lastOnlineAt = freezed,
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
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastOnlineAt: freezed == lastOnlineAt
                ? _value.lastOnlineAt
                : lastOnlineAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatUserEntityImplCopyWith<$Res>
    implements $ChatUserEntityCopyWith<$Res> {
  factory _$$ChatUserEntityImplCopyWith(
    _$ChatUserEntityImpl value,
    $Res Function(_$ChatUserEntityImpl) then,
  ) = __$$ChatUserEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String nickname,
    String? profileImageUrl,
    DateTime? lastOnlineAt,
  });
}

/// @nodoc
class __$$ChatUserEntityImplCopyWithImpl<$Res>
    extends _$ChatUserEntityCopyWithImpl<$Res, _$ChatUserEntityImpl>
    implements _$$ChatUserEntityImplCopyWith<$Res> {
  __$$ChatUserEntityImplCopyWithImpl(
    _$ChatUserEntityImpl _value,
    $Res Function(_$ChatUserEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatUserEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? profileImageUrl = freezed,
    Object? lastOnlineAt = freezed,
  }) {
    return _then(
      _$ChatUserEntityImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastOnlineAt: freezed == lastOnlineAt
            ? _value.lastOnlineAt
            : lastOnlineAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$ChatUserEntityImpl implements _ChatUserEntity {
  const _$ChatUserEntityImpl({
    required this.userId,
    required this.nickname,
    this.profileImageUrl,
    this.lastOnlineAt,
  });

  @override
  final String userId;
  @override
  final String nickname;
  @override
  final String? profileImageUrl;
  @override
  final DateTime? lastOnlineAt;

  @override
  String toString() {
    return 'ChatUserEntity(userId: $userId, nickname: $nickname, profileImageUrl: $profileImageUrl, lastOnlineAt: $lastOnlineAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatUserEntityImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.lastOnlineAt, lastOnlineAt) ||
                other.lastOnlineAt == lastOnlineAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, nickname, profileImageUrl, lastOnlineAt);

  /// Create a copy of ChatUserEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatUserEntityImplCopyWith<_$ChatUserEntityImpl> get copyWith =>
      __$$ChatUserEntityImplCopyWithImpl<_$ChatUserEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _ChatUserEntity implements ChatUserEntity {
  const factory _ChatUserEntity({
    required final String userId,
    required final String nickname,
    final String? profileImageUrl,
    final DateTime? lastOnlineAt,
  }) = _$ChatUserEntityImpl;

  @override
  String get userId;
  @override
  String get nickname;
  @override
  String? get profileImageUrl;
  @override
  DateTime? get lastOnlineAt;

  /// Create a copy of ChatUserEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatUserEntityImplCopyWith<_$ChatUserEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
