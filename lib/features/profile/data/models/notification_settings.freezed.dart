// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
  /// 전체 알림 ON/OFF
  bool get enabled => throw _privateConstructorUsedError;

  /// 공지사항 알림
  bool get notices => throw _privateConstructorUsedError;

  /// 댓글 알림
  bool get comments => throw _privateConstructorUsedError;

  /// 좋아요 알림 (선택사항)
  bool get likes => throw _privateConstructorUsedError;

  /// 일일 미사 독서 알림 (선택사항)
  bool get dailyMass => throw _privateConstructorUsedError;

  /// 조용한 시간 활성화 여부
  bool get quietHoursEnabled => throw _privateConstructorUsedError;

  /// 조용한 시간 시작 (24시간 형식, 0-23)
  int get quietHoursStart => throw _privateConstructorUsedError;

  /// 조용한 시간 종료 (24시간 형식, 0-23)
  int get quietHoursEnd => throw _privateConstructorUsedError;

  /// 업데이트 시간
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(
    NotificationSettings value,
    $Res Function(NotificationSettings) then,
  ) = _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call({
    bool enabled,
    bool notices,
    bool comments,
    bool likes,
    bool dailyMass,
    bool quietHoursEnabled,
    int quietHoursStart,
    int quietHoursEnd,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<
  $Res,
  $Val extends NotificationSettings
>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? notices = null,
    Object? comments = null,
    Object? likes = null,
    Object? dailyMass = null,
    Object? quietHoursEnabled = null,
    Object? quietHoursStart = null,
    Object? quietHoursEnd = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            notices: null == notices
                ? _value.notices
                : notices // ignore: cast_nullable_to_non_nullable
                      as bool,
            comments: null == comments
                ? _value.comments
                : comments // ignore: cast_nullable_to_non_nullable
                      as bool,
            likes: null == likes
                ? _value.likes
                : likes // ignore: cast_nullable_to_non_nullable
                      as bool,
            dailyMass: null == dailyMass
                ? _value.dailyMass
                : dailyMass // ignore: cast_nullable_to_non_nullable
                      as bool,
            quietHoursEnabled: null == quietHoursEnabled
                ? _value.quietHoursEnabled
                : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            quietHoursStart: null == quietHoursStart
                ? _value.quietHoursStart
                : quietHoursStart // ignore: cast_nullable_to_non_nullable
                      as int,
            quietHoursEnd: null == quietHoursEnd
                ? _value.quietHoursEnd
                : quietHoursEnd // ignore: cast_nullable_to_non_nullable
                      as int,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(
    _$NotificationSettingsImpl value,
    $Res Function(_$NotificationSettingsImpl) then,
  ) = __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool enabled,
    bool notices,
    bool comments,
    bool likes,
    bool dailyMass,
    bool quietHoursEnabled,
    int quietHoursStart,
    int quietHoursEnd,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(
    _$NotificationSettingsImpl _value,
    $Res Function(_$NotificationSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? notices = null,
    Object? comments = null,
    Object? likes = null,
    Object? dailyMass = null,
    Object? quietHoursEnabled = null,
    Object? quietHoursStart = null,
    Object? quietHoursEnd = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$NotificationSettingsImpl(
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        notices: null == notices
            ? _value.notices
            : notices // ignore: cast_nullable_to_non_nullable
                  as bool,
        comments: null == comments
            ? _value.comments
            : comments // ignore: cast_nullable_to_non_nullable
                  as bool,
        likes: null == likes
            ? _value.likes
            : likes // ignore: cast_nullable_to_non_nullable
                  as bool,
        dailyMass: null == dailyMass
            ? _value.dailyMass
            : dailyMass // ignore: cast_nullable_to_non_nullable
                  as bool,
        quietHoursEnabled: null == quietHoursEnabled
            ? _value.quietHoursEnabled
            : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        quietHoursStart: null == quietHoursStart
            ? _value.quietHoursStart
            : quietHoursStart // ignore: cast_nullable_to_non_nullable
                  as int,
        quietHoursEnd: null == quietHoursEnd
            ? _value.quietHoursEnd
            : quietHoursEnd // ignore: cast_nullable_to_non_nullable
                  as int,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSettingsImpl extends _NotificationSettings {
  const _$NotificationSettingsImpl({
    this.enabled = true,
    this.notices = true,
    this.comments = true,
    this.likes = false,
    this.dailyMass = false,
    this.quietHoursEnabled = false,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 7,
    this.updatedAt = null,
  }) : super._();

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

  /// 전체 알림 ON/OFF
  @override
  @JsonKey()
  final bool enabled;

  /// 공지사항 알림
  @override
  @JsonKey()
  final bool notices;

  /// 댓글 알림
  @override
  @JsonKey()
  final bool comments;

  /// 좋아요 알림 (선택사항)
  @override
  @JsonKey()
  final bool likes;

  /// 일일 미사 독서 알림 (선택사항)
  @override
  @JsonKey()
  final bool dailyMass;

  /// 조용한 시간 활성화 여부
  @override
  @JsonKey()
  final bool quietHoursEnabled;

  /// 조용한 시간 시작 (24시간 형식, 0-23)
  @override
  @JsonKey()
  final int quietHoursStart;

  /// 조용한 시간 종료 (24시간 형식, 0-23)
  @override
  @JsonKey()
  final int quietHoursEnd;

  /// 업데이트 시간
  @override
  @JsonKey()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'NotificationSettings(enabled: $enabled, notices: $notices, comments: $comments, likes: $likes, dailyMass: $dailyMass, quietHoursEnabled: $quietHoursEnabled, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.notices, notices) || other.notices == notices) &&
            (identical(other.comments, comments) ||
                other.comments == comments) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.dailyMass, dailyMass) ||
                other.dailyMass == dailyMass) &&
            (identical(other.quietHoursEnabled, quietHoursEnabled) ||
                other.quietHoursEnabled == quietHoursEnabled) &&
            (identical(other.quietHoursStart, quietHoursStart) ||
                other.quietHoursStart == quietHoursStart) &&
            (identical(other.quietHoursEnd, quietHoursEnd) ||
                other.quietHoursEnd == quietHoursEnd) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    enabled,
    notices,
    comments,
    likes,
    dailyMass,
    quietHoursEnabled,
    quietHoursStart,
    quietHoursEnd,
    updatedAt,
  );

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
  get copyWith =>
      __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(this);
  }
}

abstract class _NotificationSettings extends NotificationSettings {
  const factory _NotificationSettings({
    final bool enabled,
    final bool notices,
    final bool comments,
    final bool likes,
    final bool dailyMass,
    final bool quietHoursEnabled,
    final int quietHoursStart,
    final int quietHoursEnd,
    final DateTime? updatedAt,
  }) = _$NotificationSettingsImpl;
  const _NotificationSettings._() : super._();

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  /// 전체 알림 ON/OFF
  @override
  bool get enabled;

  /// 공지사항 알림
  @override
  bool get notices;

  /// 댓글 알림
  @override
  bool get comments;

  /// 좋아요 알림 (선택사항)
  @override
  bool get likes;

  /// 일일 미사 독서 알림 (선택사항)
  @override
  bool get dailyMass;

  /// 조용한 시간 활성화 여부
  @override
  bool get quietHoursEnabled;

  /// 조용한 시간 시작 (24시간 형식, 0-23)
  @override
  int get quietHoursStart;

  /// 조용한 시간 종료 (24시간 형식, 0-23)
  @override
  int get quietHoursEnd;

  /// 업데이트 시간
  @override
  DateTime? get updatedAt;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
