import 'package:json_annotation/json_annotation.dart';

part 'liturgical_calendar_model.g.dart';

/// 전례력 데이터 모델
@JsonSerializable()
class LiturgicalCalendarModel {
  final int year;
  final SeasonDates seasons;
  final List<SpecialDay> specialDays;

  const LiturgicalCalendarModel({
    required this.year,
    required this.seasons,
    required this.specialDays,
  });

  factory LiturgicalCalendarModel.fromJson(Map<String, dynamic> json) =>
      _$LiturgicalCalendarModelFromJson(json);

  Map<String, dynamic> toJson() => _$LiturgicalCalendarModelToJson(this);
}

/// 전례 시즌 날짜
@JsonSerializable()
class SeasonDates {
  final SeasonDate advent;
  final SeasonDate christmas;
  final SeasonDate lent;
  final SeasonDate easter;
  final PentecostDate pentecost;

  const SeasonDates({
    required this.advent,
    required this.christmas,
    required this.lent,
    required this.easter,
    required this.pentecost,
  });

  factory SeasonDates.fromJson(Map<String, dynamic> json) =>
      _$SeasonDatesFromJson(json);

  Map<String, dynamic> toJson() => _$SeasonDatesToJson(this);
}

/// 시즌 날짜 (시작일과 종료일)
@JsonSerializable()
class SeasonDate {
  final String start;
  final String end;

  const SeasonDate({
    required this.start,
    required this.end,
  });

  factory SeasonDate.fromJson(Map<String, dynamic> json) =>
      _$SeasonDateFromJson(json);

  Map<String, dynamic> toJson() => _$SeasonDateToJson(this);
}

/// 성령 강림일 (단일 날짜)
@JsonSerializable()
class PentecostDate {
  final String date;

  const PentecostDate({required this.date});

  factory PentecostDate.fromJson(Map<String, dynamic> json) =>
      _$PentecostDateFromJson(json);

  Map<String, dynamic> toJson() => _$PentecostDateToJson(this);
}

/// 특별한 축일
@JsonSerializable()
class SpecialDay {
  final String date;
  final String name;
  final String type; // solemnity, feast, memorial

  const SpecialDay({
    required this.date,
    required this.name,
    required this.type,
  });

  factory SpecialDay.fromJson(Map<String, dynamic> json) =>
      _$SpecialDayFromJson(json);

  Map<String, dynamic> toJson() => _$SpecialDayToJson(this);
}






























