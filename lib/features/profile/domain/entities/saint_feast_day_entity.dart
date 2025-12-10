import 'package:freezed_annotation/freezed_annotation.dart';

part 'saint_feast_day_entity.freezed.dart';

/// 성인 축일 엔티티
@freezed
class SaintFeastDayEntity with _$SaintFeastDayEntity {
  const factory SaintFeastDayEntity({
    required int month,
    required int day,
    required String name,
    required String nameEnglish,
    required String type, // solemnity, feast, memorial
    @Default(false) bool isJapanese,
    required String greeting,
    String? description,
  }) = _SaintFeastDayEntity;

  const SaintFeastDayEntity._();
}
