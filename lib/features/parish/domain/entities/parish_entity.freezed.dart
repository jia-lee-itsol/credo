// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parish_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ParishEntity {
  String get parishId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get prefecture => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get officialSite => throw _privateConstructorUsedError;
  bool get hasOfficialAccount => throw _privateConstructorUsedError;
  String? get nearestStation => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<MassTimeEntity> get massTimes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of ParishEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParishEntityCopyWith<ParishEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParishEntityCopyWith<$Res> {
  factory $ParishEntityCopyWith(
    ParishEntity value,
    $Res Function(ParishEntity) then,
  ) = _$ParishEntityCopyWithImpl<$Res, ParishEntity>;
  @useResult
  $Res call({
    String parishId,
    String name,
    String prefecture,
    String address,
    String? phone,
    double latitude,
    double longitude,
    String? officialSite,
    bool hasOfficialAccount,
    String? nearestStation,
    String? imageUrl,
    List<MassTimeEntity> massTimes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$ParishEntityCopyWithImpl<$Res, $Val extends ParishEntity>
    implements $ParishEntityCopyWith<$Res> {
  _$ParishEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParishEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parishId = null,
    Object? name = null,
    Object? prefecture = null,
    Object? address = null,
    Object? phone = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? officialSite = freezed,
    Object? hasOfficialAccount = null,
    Object? nearestStation = freezed,
    Object? imageUrl = freezed,
    Object? massTimes = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            parishId: null == parishId
                ? _value.parishId
                : parishId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            prefecture: null == prefecture
                ? _value.prefecture
                : prefecture // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            officialSite: freezed == officialSite
                ? _value.officialSite
                : officialSite // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasOfficialAccount: null == hasOfficialAccount
                ? _value.hasOfficialAccount
                : hasOfficialAccount // ignore: cast_nullable_to_non_nullable
                      as bool,
            nearestStation: freezed == nearestStation
                ? _value.nearestStation
                : nearestStation // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            massTimes: null == massTimes
                ? _value.massTimes
                : massTimes // ignore: cast_nullable_to_non_nullable
                      as List<MassTimeEntity>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$ParishEntityImplCopyWith<$Res>
    implements $ParishEntityCopyWith<$Res> {
  factory _$$ParishEntityImplCopyWith(
    _$ParishEntityImpl value,
    $Res Function(_$ParishEntityImpl) then,
  ) = __$$ParishEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String parishId,
    String name,
    String prefecture,
    String address,
    String? phone,
    double latitude,
    double longitude,
    String? officialSite,
    bool hasOfficialAccount,
    String? nearestStation,
    String? imageUrl,
    List<MassTimeEntity> massTimes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ParishEntityImplCopyWithImpl<$Res>
    extends _$ParishEntityCopyWithImpl<$Res, _$ParishEntityImpl>
    implements _$$ParishEntityImplCopyWith<$Res> {
  __$$ParishEntityImplCopyWithImpl(
    _$ParishEntityImpl _value,
    $Res Function(_$ParishEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParishEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parishId = null,
    Object? name = null,
    Object? prefecture = null,
    Object? address = null,
    Object? phone = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? officialSite = freezed,
    Object? hasOfficialAccount = null,
    Object? nearestStation = freezed,
    Object? imageUrl = freezed,
    Object? massTimes = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ParishEntityImpl(
        parishId: null == parishId
            ? _value.parishId
            : parishId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        prefecture: null == prefecture
            ? _value.prefecture
            : prefecture // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        officialSite: freezed == officialSite
            ? _value.officialSite
            : officialSite // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasOfficialAccount: null == hasOfficialAccount
            ? _value.hasOfficialAccount
            : hasOfficialAccount // ignore: cast_nullable_to_non_nullable
                  as bool,
        nearestStation: freezed == nearestStation
            ? _value.nearestStation
            : nearestStation // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        massTimes: null == massTimes
            ? _value._massTimes
            : massTimes // ignore: cast_nullable_to_non_nullable
                  as List<MassTimeEntity>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$ParishEntityImpl extends _ParishEntity {
  const _$ParishEntityImpl({
    required this.parishId,
    required this.name,
    required this.prefecture,
    required this.address,
    this.phone,
    required this.latitude,
    required this.longitude,
    this.officialSite,
    this.hasOfficialAccount = false,
    this.nearestStation,
    this.imageUrl,
    final List<MassTimeEntity> massTimes = const [],
    this.createdAt,
    this.updatedAt,
  }) : _massTimes = massTimes,
       super._();

  @override
  final String parishId;
  @override
  final String name;
  @override
  final String prefecture;
  @override
  final String address;
  @override
  final String? phone;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? officialSite;
  @override
  @JsonKey()
  final bool hasOfficialAccount;
  @override
  final String? nearestStation;
  @override
  final String? imageUrl;
  final List<MassTimeEntity> _massTimes;
  @override
  @JsonKey()
  List<MassTimeEntity> get massTimes {
    if (_massTimes is EqualUnmodifiableListView) return _massTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_massTimes);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ParishEntity(parishId: $parishId, name: $name, prefecture: $prefecture, address: $address, phone: $phone, latitude: $latitude, longitude: $longitude, officialSite: $officialSite, hasOfficialAccount: $hasOfficialAccount, nearestStation: $nearestStation, imageUrl: $imageUrl, massTimes: $massTimes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParishEntityImpl &&
            (identical(other.parishId, parishId) ||
                other.parishId == parishId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.prefecture, prefecture) ||
                other.prefecture == prefecture) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.officialSite, officialSite) ||
                other.officialSite == officialSite) &&
            (identical(other.hasOfficialAccount, hasOfficialAccount) ||
                other.hasOfficialAccount == hasOfficialAccount) &&
            (identical(other.nearestStation, nearestStation) ||
                other.nearestStation == nearestStation) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(
              other._massTimes,
              _massTimes,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    parishId,
    name,
    prefecture,
    address,
    phone,
    latitude,
    longitude,
    officialSite,
    hasOfficialAccount,
    nearestStation,
    imageUrl,
    const DeepCollectionEquality().hash(_massTimes),
    createdAt,
    updatedAt,
  );

  /// Create a copy of ParishEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParishEntityImplCopyWith<_$ParishEntityImpl> get copyWith =>
      __$$ParishEntityImplCopyWithImpl<_$ParishEntityImpl>(this, _$identity);
}

abstract class _ParishEntity extends ParishEntity {
  const factory _ParishEntity({
    required final String parishId,
    required final String name,
    required final String prefecture,
    required final String address,
    final String? phone,
    required final double latitude,
    required final double longitude,
    final String? officialSite,
    final bool hasOfficialAccount,
    final String? nearestStation,
    final String? imageUrl,
    final List<MassTimeEntity> massTimes,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$ParishEntityImpl;
  const _ParishEntity._() : super._();

  @override
  String get parishId;
  @override
  String get name;
  @override
  String get prefecture;
  @override
  String get address;
  @override
  String? get phone;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get officialSite;
  @override
  bool get hasOfficialAccount;
  @override
  String? get nearestStation;
  @override
  String? get imageUrl;
  @override
  List<MassTimeEntity> get massTimes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ParishEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParishEntityImplCopyWith<_$ParishEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MassTimeEntity {
  String get massId => throw _privateConstructorUsedError;
  String get parishId => throw _privateConstructorUsedError;
  int get weekday => throw _privateConstructorUsedError; // 0 = 일요일, 6 = 토요일
  String get time => throw _privateConstructorUsedError; // HH:mm 형식
  String get language => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Create a copy of MassTimeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MassTimeEntityCopyWith<MassTimeEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MassTimeEntityCopyWith<$Res> {
  factory $MassTimeEntityCopyWith(
    MassTimeEntity value,
    $Res Function(MassTimeEntity) then,
  ) = _$MassTimeEntityCopyWithImpl<$Res, MassTimeEntity>;
  @useResult
  $Res call({
    String massId,
    String parishId,
    int weekday,
    String time,
    String language,
    String? note,
  });
}

/// @nodoc
class _$MassTimeEntityCopyWithImpl<$Res, $Val extends MassTimeEntity>
    implements $MassTimeEntityCopyWith<$Res> {
  _$MassTimeEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MassTimeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? massId = null,
    Object? parishId = null,
    Object? weekday = null,
    Object? time = null,
    Object? language = null,
    Object? note = freezed,
  }) {
    return _then(
      _value.copyWith(
            massId: null == massId
                ? _value.massId
                : massId // ignore: cast_nullable_to_non_nullable
                      as String,
            parishId: null == parishId
                ? _value.parishId
                : parishId // ignore: cast_nullable_to_non_nullable
                      as String,
            weekday: null == weekday
                ? _value.weekday
                : weekday // ignore: cast_nullable_to_non_nullable
                      as int,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MassTimeEntityImplCopyWith<$Res>
    implements $MassTimeEntityCopyWith<$Res> {
  factory _$$MassTimeEntityImplCopyWith(
    _$MassTimeEntityImpl value,
    $Res Function(_$MassTimeEntityImpl) then,
  ) = __$$MassTimeEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String massId,
    String parishId,
    int weekday,
    String time,
    String language,
    String? note,
  });
}

/// @nodoc
class __$$MassTimeEntityImplCopyWithImpl<$Res>
    extends _$MassTimeEntityCopyWithImpl<$Res, _$MassTimeEntityImpl>
    implements _$$MassTimeEntityImplCopyWith<$Res> {
  __$$MassTimeEntityImplCopyWithImpl(
    _$MassTimeEntityImpl _value,
    $Res Function(_$MassTimeEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MassTimeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? massId = null,
    Object? parishId = null,
    Object? weekday = null,
    Object? time = null,
    Object? language = null,
    Object? note = freezed,
  }) {
    return _then(
      _$MassTimeEntityImpl(
        massId: null == massId
            ? _value.massId
            : massId // ignore: cast_nullable_to_non_nullable
                  as String,
        parishId: null == parishId
            ? _value.parishId
            : parishId // ignore: cast_nullable_to_non_nullable
                  as String,
        weekday: null == weekday
            ? _value.weekday
            : weekday // ignore: cast_nullable_to_non_nullable
                  as int,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$MassTimeEntityImpl extends _MassTimeEntity {
  const _$MassTimeEntityImpl({
    required this.massId,
    required this.parishId,
    required this.weekday,
    required this.time,
    required this.language,
    this.note,
  }) : super._();

  @override
  final String massId;
  @override
  final String parishId;
  @override
  final int weekday;
  // 0 = 일요일, 6 = 토요일
  @override
  final String time;
  // HH:mm 형식
  @override
  final String language;
  @override
  final String? note;

  @override
  String toString() {
    return 'MassTimeEntity(massId: $massId, parishId: $parishId, weekday: $weekday, time: $time, language: $language, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MassTimeEntityImpl &&
            (identical(other.massId, massId) || other.massId == massId) &&
            (identical(other.parishId, parishId) ||
                other.parishId == parishId) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, massId, parishId, weekday, time, language, note);

  /// Create a copy of MassTimeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MassTimeEntityImplCopyWith<_$MassTimeEntityImpl> get copyWith =>
      __$$MassTimeEntityImplCopyWithImpl<_$MassTimeEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _MassTimeEntity extends MassTimeEntity {
  const factory _MassTimeEntity({
    required final String massId,
    required final String parishId,
    required final int weekday,
    required final String time,
    required final String language,
    final String? note,
  }) = _$MassTimeEntityImpl;
  const _MassTimeEntity._() : super._();

  @override
  String get massId;
  @override
  String get parishId;
  @override
  int get weekday; // 0 = 일요일, 6 = 토요일
  @override
  String get time; // HH:mm 형식
  @override
  String get language;
  @override
  String? get note;

  /// Create a copy of MassTimeEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MassTimeEntityImplCopyWith<_$MassTimeEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
