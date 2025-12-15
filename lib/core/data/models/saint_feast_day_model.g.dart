// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saint_feast_day_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaintFeastDayModel _$SaintFeastDayModelFromJson(Map<String, dynamic> json) =>
    SaintFeastDayModel(
      month: (json['month'] as num).toInt(),
      day: (json['day'] as num).toInt(),
      name: json['name'] as String,
      nameEn: json['nameEn'] as String?,
      nameKo: json['nameKo'] as String?,
      nameZh: json['nameZh'] as String?,
      nameVi: json['nameVi'] as String?,
      nameEs: json['nameEs'] as String?,
      namePt: json['namePt'] as String?,
      type: json['type'] as String,
      isJapanese: json['isJapanese'] as bool,
      greeting: json['greeting'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SaintFeastDayModelToJson(SaintFeastDayModel instance) =>
    <String, dynamic>{
      'month': instance.month,
      'day': instance.day,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'nameKo': instance.nameKo,
      'nameZh': instance.nameZh,
      'nameVi': instance.nameVi,
      'nameEs': instance.nameEs,
      'namePt': instance.namePt,
      'type': instance.type,
      'isJapanese': instance.isJapanese,
      'greeting': instance.greeting,
      'description': instance.description,
    };

SaintsFeastDaysModel _$SaintsFeastDaysModelFromJson(
  Map<String, dynamic> json,
) => SaintsFeastDaysModel(
  saints: (json['saints'] as List<dynamic>)
      .map((e) => SaintFeastDayModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  japaneseSaints: (json['japaneseSaints'] as List<dynamic>)
      .map((e) => SaintFeastDayModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SaintsFeastDaysModelToJson(
  SaintsFeastDaysModel instance,
) => <String, dynamic>{
  'saints': instance.saints,
  'japaneseSaints': instance.japaneseSaints,
};
