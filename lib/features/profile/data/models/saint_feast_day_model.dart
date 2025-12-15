import '../../../../core/data/models/saint_feast_day_model.dart' as core;
import '../../domain/entities/saint_feast_day_entity.dart';

/// 성인 축일 모델 (core 모델을 엔티티로 변환)
extension SaintFeastDayModelExtension on core.SaintFeastDayModel {
  /// Entity로 변환
  SaintFeastDayEntity toEntity() {
    return SaintFeastDayEntity(
      month: month,
      day: day,
      name: name,
      nameEnglish: nameEn ?? name,
      type: type,
      isJapanese: isJapanese,
      greeting: greeting,
      description: description,
    );
  }
}
