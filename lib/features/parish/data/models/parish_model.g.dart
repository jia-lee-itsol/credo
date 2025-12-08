// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parish_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParishModelImpl _$$ParishModelImplFromJson(Map<String, dynamic> json) =>
    _$ParishModelImpl(
      parishId: json['parish_id'] as String,
      name: json['name'] as String,
      prefecture: json['prefecture'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      officialSite: json['official_site'] as String?,
      hasOfficialAccount: json['has_official_account'] as bool? ?? false,
      nearestStation: json['nearest_station'] as String?,
      imageUrl: json['image_url'] as String?,
      massTimes:
          (json['mass_times'] as List<dynamic>?)
              ?.map((e) => MassTimeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ParishModelImplToJson(_$ParishModelImpl instance) =>
    <String, dynamic>{
      'parish_id': instance.parishId,
      'name': instance.name,
      'prefecture': instance.prefecture,
      'address': instance.address,
      'phone': instance.phone,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'official_site': instance.officialSite,
      'has_official_account': instance.hasOfficialAccount,
      'nearest_station': instance.nearestStation,
      'image_url': instance.imageUrl,
      'mass_times': instance.massTimes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$MassTimeModelImpl _$$MassTimeModelImplFromJson(Map<String, dynamic> json) =>
    _$MassTimeModelImpl(
      massId: json['mass_id'] as String,
      parishId: json['parish_id'] as String,
      weekday: (json['weekday'] as num).toInt(),
      time: json['time'] as String,
      language: json['language'] as String,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$MassTimeModelImplToJson(_$MassTimeModelImpl instance) =>
    <String, dynamic>{
      'mass_id': instance.massId,
      'parish_id': instance.parishId,
      'weekday': instance.weekday,
      'time': instance.time,
      'language': instance.language,
      'note': instance.note,
    };
