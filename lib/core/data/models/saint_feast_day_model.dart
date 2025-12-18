import 'package:json_annotation/json_annotation.dart';

part 'saint_feast_day_model.g.dart';

/// 성인 축일 모델
@JsonSerializable()
class SaintFeastDayModel {
  final int month;
  final int day;
  @JsonKey(name: 'name')
  final String name; // 일본어 이름 (기본값, 하위 호환성)
  @JsonKey(name: 'nameEn')
  final String? nameEn; // 영어 이름
  @JsonKey(name: 'nameKo')
  final String? nameKo; // 한국어 이름
  @JsonKey(name: 'nameZh')
  final String? nameZh; // 중국어 이름
  @JsonKey(name: 'nameVi')
  final String? nameVi; // 베트남어 이름
  @JsonKey(name: 'nameEs')
  final String? nameEs; // 스페인어 이름
  @JsonKey(name: 'namePt')
  final String? namePt; // 포르투갈어 이름
  final String type; // solemnity, feast, memorial
  @JsonKey(name: 'isJapanese')
  final bool isJapanese;
  final String greeting;
  final String? description;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl; // 성인 이미지 URL

  const SaintFeastDayModel({
    required this.month,
    required this.day,
    required this.name,
    this.nameEn,
    this.nameKo,
    this.nameZh,
    this.nameVi,
    this.nameEs,
    this.namePt,
    required this.type,
    required this.isJapanese,
    required this.greeting,
    this.description,
    this.imageUrl,
  });

  /// 현재 로케일에 맞는 이름 반환
  String getName(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return name;
      case 'en':
        return nameEn ?? name;
      case 'ko':
        return nameKo ?? name;
      case 'zh':
        return nameZh ?? name;
      case 'vi':
        return nameVi ?? nameEn ?? name;
      case 'es':
        return nameEs ?? nameEn ?? name;
      case 'pt':
        return namePt ?? nameEn ?? name;
      default:
        return name;
    }
  }

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
