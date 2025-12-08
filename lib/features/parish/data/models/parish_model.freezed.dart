// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parish_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ParishModel _$ParishModelFromJson(Map<String, dynamic> json) {
  return _ParishModel.fromJson(json);
}

/// @nodoc
mixin _$ParishModel {
  @JsonKey(name: 'parish_id')
  String get parishId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get prefecture => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'official_site')
  String? get officialSite => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_official_account')
  bool get hasOfficialAccount => throw _privateConstructorUsedError;
  @JsonKey(name: 'nearest_station')
  String? get nearestStation => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'mass_times')
  List<MassTimeModel> get massTimes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ParishModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParishModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParishModelCopyWith<ParishModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParishModelCopyWith<$Res> {
  factory $ParishModelCopyWith(
    ParishModel value,
    $Res Function(ParishModel) then,
  ) = _$ParishModelCopyWithImpl<$Res, ParishModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'parish_id') String parishId,
    String name,
    String prefecture,
    String address,
    String? phone,
    double latitude,
    double longitude,
    @JsonKey(name: 'official_site') String? officialSite,
    @JsonKey(name: 'has_official_account') bool hasOfficialAccount,
    @JsonKey(name: 'nearest_station') String? nearestStation,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'mass_times') List<MassTimeModel> massTimes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$ParishModelCopyWithImpl<$Res, $Val extends ParishModel>
    implements $ParishModelCopyWith<$Res> {
  _$ParishModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParishModel
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
                      as List<MassTimeModel>,
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
abstract class _$$ParishModelImplCopyWith<$Res>
    implements $ParishModelCopyWith<$Res> {
  factory _$$ParishModelImplCopyWith(
    _$ParishModelImpl value,
    $Res Function(_$ParishModelImpl) then,
  ) = __$$ParishModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'parish_id') String parishId,
    String name,
    String prefecture,
    String address,
    String? phone,
    double latitude,
    double longitude,
    @JsonKey(name: 'official_site') String? officialSite,
    @JsonKey(name: 'has_official_account') bool hasOfficialAccount,
    @JsonKey(name: 'nearest_station') String? nearestStation,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'mass_times') List<MassTimeModel> massTimes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ParishModelImplCopyWithImpl<$Res>
    extends _$ParishModelCopyWithImpl<$Res, _$ParishModelImpl>
    implements _$$ParishModelImplCopyWith<$Res> {
  __$$ParishModelImplCopyWithImpl(
    _$ParishModelImpl _value,
    $Res Function(_$ParishModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParishModel
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
      _$ParishModelImpl(
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
                  as List<MassTimeModel>,
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
@JsonSerializable()
class _$ParishModelImpl extends _ParishModel {
  const _$ParishModelImpl({
    @JsonKey(name: 'parish_id') required this.parishId,
    required this.name,
    required this.prefecture,
    required this.address,
    this.phone,
    required this.latitude,
    required this.longitude,
    @JsonKey(name: 'official_site') this.officialSite,
    @JsonKey(name: 'has_official_account') this.hasOfficialAccount = false,
    @JsonKey(name: 'nearest_station') this.nearestStation,
    @JsonKey(name: 'image_url') this.imageUrl,
    @JsonKey(name: 'mass_times') final List<MassTimeModel> massTimes = const [],
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _massTimes = massTimes,
       super._();

  factory _$ParishModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParishModelImplFromJson(json);

  @override
  @JsonKey(name: 'parish_id')
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
  @JsonKey(name: 'official_site')
  final String? officialSite;
  @override
  @JsonKey(name: 'has_official_account')
  final bool hasOfficialAccount;
  @override
  @JsonKey(name: 'nearest_station')
  final String? nearestStation;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final List<MassTimeModel> _massTimes;
  @override
  @JsonKey(name: 'mass_times')
  List<MassTimeModel> get massTimes {
    if (_massTimes is EqualUnmodifiableListView) return _massTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_massTimes);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ParishModel(parishId: $parishId, name: $name, prefecture: $prefecture, address: $address, phone: $phone, latitude: $latitude, longitude: $longitude, officialSite: $officialSite, hasOfficialAccount: $hasOfficialAccount, nearestStation: $nearestStation, imageUrl: $imageUrl, massTimes: $massTimes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParishModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of ParishModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParishModelImplCopyWith<_$ParishModelImpl> get copyWith =>
      __$$ParishModelImplCopyWithImpl<_$ParishModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParishModelImplToJson(this);
  }
}

abstract class _ParishModel extends ParishModel {
  const factory _ParishModel({
    @JsonKey(name: 'parish_id') required final String parishId,
    required final String name,
    required final String prefecture,
    required final String address,
    final String? phone,
    required final double latitude,
    required final double longitude,
    @JsonKey(name: 'official_site') final String? officialSite,
    @JsonKey(name: 'has_official_account') final bool hasOfficialAccount,
    @JsonKey(name: 'nearest_station') final String? nearestStation,
    @JsonKey(name: 'image_url') final String? imageUrl,
    @JsonKey(name: 'mass_times') final List<MassTimeModel> massTimes,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$ParishModelImpl;
  const _ParishModel._() : super._();

  factory _ParishModel.fromJson(Map<String, dynamic> json) =
      _$ParishModelImpl.fromJson;

  @override
  @JsonKey(name: 'parish_id')
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
  @JsonKey(name: 'official_site')
  String? get officialSite;
  @override
  @JsonKey(name: 'has_official_account')
  bool get hasOfficialAccount;
  @override
  @JsonKey(name: 'nearest_station')
  String? get nearestStation;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'mass_times')
  List<MassTimeModel> get massTimes;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of ParishModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParishModelImplCopyWith<_$ParishModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MassTimeModel _$MassTimeModelFromJson(Map<String, dynamic> json) {
  return _MassTimeModel.fromJson(json);
}

/// @nodoc
mixin _$MassTimeModel {
  @JsonKey(name: 'mass_id')
  String get massId => throw _privateConstructorUsedError;
  @JsonKey(name: 'parish_id')
  String get parishId => throw _privateConstructorUsedError;
  int get weekday => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this MassTimeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MassTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MassTimeModelCopyWith<MassTimeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MassTimeModelCopyWith<$Res> {
  factory $MassTimeModelCopyWith(
    MassTimeModel value,
    $Res Function(MassTimeModel) then,
  ) = _$MassTimeModelCopyWithImpl<$Res, MassTimeModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'mass_id') String massId,
    @JsonKey(name: 'parish_id') String parishId,
    int weekday,
    String time,
    String language,
    String? note,
  });
}

/// @nodoc
class _$MassTimeModelCopyWithImpl<$Res, $Val extends MassTimeModel>
    implements $MassTimeModelCopyWith<$Res> {
  _$MassTimeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MassTimeModel
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
abstract class _$$MassTimeModelImplCopyWith<$Res>
    implements $MassTimeModelCopyWith<$Res> {
  factory _$$MassTimeModelImplCopyWith(
    _$MassTimeModelImpl value,
    $Res Function(_$MassTimeModelImpl) then,
  ) = __$$MassTimeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'mass_id') String massId,
    @JsonKey(name: 'parish_id') String parishId,
    int weekday,
    String time,
    String language,
    String? note,
  });
}

/// @nodoc
class __$$MassTimeModelImplCopyWithImpl<$Res>
    extends _$MassTimeModelCopyWithImpl<$Res, _$MassTimeModelImpl>
    implements _$$MassTimeModelImplCopyWith<$Res> {
  __$$MassTimeModelImplCopyWithImpl(
    _$MassTimeModelImpl _value,
    $Res Function(_$MassTimeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MassTimeModel
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
      _$MassTimeModelImpl(
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
@JsonSerializable()
class _$MassTimeModelImpl extends _MassTimeModel {
  const _$MassTimeModelImpl({
    @JsonKey(name: 'mass_id') required this.massId,
    @JsonKey(name: 'parish_id') required this.parishId,
    required this.weekday,
    required this.time,
    required this.language,
    this.note,
  }) : super._();

  factory _$MassTimeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MassTimeModelImplFromJson(json);

  @override
  @JsonKey(name: 'mass_id')
  final String massId;
  @override
  @JsonKey(name: 'parish_id')
  final String parishId;
  @override
  final int weekday;
  @override
  final String time;
  @override
  final String language;
  @override
  final String? note;

  @override
  String toString() {
    return 'MassTimeModel(massId: $massId, parishId: $parishId, weekday: $weekday, time: $time, language: $language, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MassTimeModelImpl &&
            (identical(other.massId, massId) || other.massId == massId) &&
            (identical(other.parishId, parishId) ||
                other.parishId == parishId) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, massId, parishId, weekday, time, language, note);

  /// Create a copy of MassTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MassTimeModelImplCopyWith<_$MassTimeModelImpl> get copyWith =>
      __$$MassTimeModelImplCopyWithImpl<_$MassTimeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MassTimeModelImplToJson(this);
  }
}

abstract class _MassTimeModel extends MassTimeModel {
  const factory _MassTimeModel({
    @JsonKey(name: 'mass_id') required final String massId,
    @JsonKey(name: 'parish_id') required final String parishId,
    required final int weekday,
    required final String time,
    required final String language,
    final String? note,
  }) = _$MassTimeModelImpl;
  const _MassTimeModel._() : super._();

  factory _MassTimeModel.fromJson(Map<String, dynamic> json) =
      _$MassTimeModelImpl.fromJson;

  @override
  @JsonKey(name: 'mass_id')
  String get massId;
  @override
  @JsonKey(name: 'parish_id')
  String get parishId;
  @override
  int get weekday;
  @override
  String get time;
  @override
  String get language;
  @override
  String? get note;

  /// Create a copy of MassTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MassTimeModelImplCopyWith<_$MassTimeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
