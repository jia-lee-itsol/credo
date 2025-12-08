import 'package:json_annotation/json_annotation.dart';

part 'saint_feast_day_model.g.dart';

/// 성인 축일 모델
@JsonSerializable()
class SaintFeastDayModel {
  final int month;
  final int day;
  final String name;
  @JsonKey(name: 'nameEn')
  final String nameEnglish;
  final String type; // solemnity, feast, memorial
  @JsonKey(name: 'isJapanese')
  final bool isJapanese;
  final String greeting;
  final String? description;

  const SaintFeastDayModel({
    required this.month,
    required this.day,
    required this.name,
    required this.nameEnglish,
    required this.type,
    required this.isJapanese,
    required this.greeting,
    this.description,
  });

  factory SaintFeastDayModel.fromJson(Map<String, dynamic> json) =>
      _$SaintFeastDayModelFromJson(json);

  Map<String, dynamic> toJson() => _$SaintFeastDayModelToJson(this);
}

/// 성인 축일 데이터 모델
@JsonSerializable()
class SaintsFeastDaysModel {
  final List<SaintFeastDayModel> saints;
  @JsonKey(name: 'japaneseSaints')
  final List<SaintFeastDayModel> japaneseSaints;

  const SaintsFeastDaysModel({
    required this.saints,
    required this.japaneseSaints,
  });

  factory SaintsFeastDaysModel.fromJson(Map<String, dynamic> json) =>
      _$SaintsFeastDaysModelFromJson(json);

  Map<String, dynamic> toJson() => _$SaintsFeastDaysModelToJson(this);
}
