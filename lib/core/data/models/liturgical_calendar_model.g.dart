// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liturgical_calendar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiturgicalCalendarModel _$LiturgicalCalendarModelFromJson(
  Map<String, dynamic> json,
) => LiturgicalCalendarModel(
  year: (json['year'] as num).toInt(),
  seasons: SeasonDates.fromJson(json['seasons'] as Map<String, dynamic>),
  specialDays: (json['specialDays'] as List<dynamic>)
      .map((e) => SpecialDay.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LiturgicalCalendarModelToJson(
  LiturgicalCalendarModel instance,
) => <String, dynamic>{
  'year': instance.year,
  'seasons': instance.seasons,
  'specialDays': instance.specialDays,
};

SeasonDates _$SeasonDatesFromJson(Map<String, dynamic> json) => SeasonDates(
  advent: SeasonDate.fromJson(json['advent'] as Map<String, dynamic>),
  christmas: SeasonDate.fromJson(json['christmas'] as Map<String, dynamic>),
  lent: SeasonDate.fromJson(json['lent'] as Map<String, dynamic>),
  easter: SeasonDate.fromJson(json['easter'] as Map<String, dynamic>),
  pentecost: PentecostDate.fromJson(json['pentecost'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SeasonDatesToJson(SeasonDates instance) =>
    <String, dynamic>{
      'advent': instance.advent,
      'christmas': instance.christmas,
      'lent': instance.lent,
      'easter': instance.easter,
      'pentecost': instance.pentecost,
    };

SeasonDate _$SeasonDateFromJson(Map<String, dynamic> json) =>
    SeasonDate(start: json['start'] as String, end: json['end'] as String);

Map<String, dynamic> _$SeasonDateToJson(SeasonDate instance) =>
    <String, dynamic>{'start': instance.start, 'end': instance.end};

PentecostDate _$PentecostDateFromJson(Map<String, dynamic> json) =>
    PentecostDate(date: json['date'] as String);

Map<String, dynamic> _$PentecostDateToJson(PentecostDate instance) =>
    <String, dynamic>{'date': instance.date};

SpecialDay _$SpecialDayFromJson(Map<String, dynamic> json) => SpecialDay(
  date: json['date'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$SpecialDayToJson(SpecialDay instance) =>
    <String, dynamic>{
      'date': instance.date,
      'name': instance.name,
      'type': instance.type,
    };
