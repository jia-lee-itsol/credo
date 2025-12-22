// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FriendModel _$FriendModelFromJson(Map<String, dynamic> json) {
  return _FriendModel.fromJson(json);
}

/// @nodoc
mixin _$FriendModel {
  String get odId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get friendId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get nickname => throw _privateConstructorUsedError;

  /// Serializes this FriendModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendModelCopyWith<FriendModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendModelCopyWith<$Res> {
  factory $FriendModelCopyWith(
    FriendModel value,
    $Res Function(FriendModel) then,
  ) = _$FriendModelCopyWithImpl<$Res, FriendModel>;
  @useResult
  $Res call({
    String odId,
    String userId,
    String friendId,
    String status,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? updatedAt,
    String? nickname,
  });
}

/// @nodoc
class _$FriendModelCopyWithImpl<$Res, $Val extends FriendModel>
    implements $FriendModelCopyWith<$Res> {
  _$FriendModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendModel
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
                      as String,
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
abstract class _$$FriendModelImplCopyWith<$Res>
    implements $FriendModelCopyWith<$Res> {
  factory _$$FriendModelImplCopyWith(
    _$FriendModelImpl value,
    $Res Function(_$FriendModelImpl) then,
  ) = __$$FriendModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String odId,
    String userId,
    String friendId,
    String status,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? updatedAt,
    String? nickname,
  });
}

/// @nodoc
class __$$FriendModelImplCopyWithImpl<$Res>
    extends _$FriendModelCopyWithImpl<$Res, _$FriendModelImpl>
    implements _$$FriendModelImplCopyWith<$Res> {
  __$$FriendModelImplCopyWithImpl(
    _$FriendModelImpl _value,
    $Res Function(_$FriendModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendModel
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
      _$FriendModelImpl(
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
                  as String,
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
@JsonSerializable()
class _$FriendModelImpl extends _FriendModel {
  const _$FriendModelImpl({
    required this.odId,
    required this.userId,
    required this.friendId,
    required this.status,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required this.createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    this.updatedAt,
    this.nickname,
  }) : super._();

  factory _$FriendModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendModelImplFromJson(json);

  @override
  final String odId;
  @override
  final String userId;
  @override
  final String friendId;
  @override
  final String status;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  final DateTime? updatedAt;
  @override
  final String? nickname;

  @override
  String toString() {
    return 'FriendModel(odId: $odId, userId: $userId, friendId: $friendId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of FriendModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendModelImplCopyWith<_$FriendModelImpl> get copyWith =>
      __$$FriendModelImplCopyWithImpl<_$FriendModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendModelImplToJson(this);
  }
}

abstract class _FriendModel extends FriendModel {
  const factory _FriendModel({
    required final String odId,
    required final String userId,
    required final String friendId,
    required final String status,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required final DateTime createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    final DateTime? updatedAt,
    final String? nickname,
  }) = _$FriendModelImpl;
  const _FriendModel._() : super._();

  factory _FriendModel.fromJson(Map<String, dynamic> json) =
      _$FriendModelImpl.fromJson;

  @override
  String get odId;
  @override
  String get userId;
  @override
  String get friendId;
  @override
  String get status;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get updatedAt;
  @override
  String? get nickname;

  /// Create a copy of FriendModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendModelImplCopyWith<_$FriendModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
