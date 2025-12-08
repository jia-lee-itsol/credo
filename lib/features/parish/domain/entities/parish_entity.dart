import 'package:freezed_annotation/freezed_annotation.dart';

part 'parish_entity.freezed.dart';

/// 교회 엔티티
@freezed
class ParishEntity with _$ParishEntity {
  const factory ParishEntity({
    required String parishId,
    required String name,
    required String prefecture,
    required String address,
    String? phone,
    required double latitude,
    required double longitude,
    String? officialSite,
    @Default(false) bool hasOfficialAccount,
    String? nearestStation,
    String? imageUrl,
    @Default([]) List<MassTimeEntity> massTimes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ParishEntity;

  const ParishEntity._();

  /// 전체 주소
  String get fullAddress => '$prefecture $address';

  /// 오늘의 미사 시간 목록
  List<MassTimeEntity> getMassTodayTimes() {
    final today = DateTime.now().weekday % 7;
    return massTimes.where((mt) => mt.weekday == today).toList();
  }

  /// 특정 요일의 미사 시간 목록
  List<MassTimeEntity> getMassTimesByWeekday(int weekday) {
    return massTimes.where((mt) => mt.weekday == weekday).toList();
  }

  /// 특정 언어의 미사 시간 목록
  List<MassTimeEntity> getMassTimesByLanguage(String language) {
    return massTimes.where((mt) => mt.language == language).toList();
  }
}

/// 미사 시간 엔티티
@freezed
class MassTimeEntity with _$MassTimeEntity {
  const factory MassTimeEntity({
    required String massId,
    required String parishId,
    required int weekday, // 0 = 일요일, 6 = 토요일
    required String time, // HH:mm 형식
    required String language,
    String? note,
  }) = _MassTimeEntity;

  const MassTimeEntity._();

  /// 시간을 DateTime으로 변환
  DateTime getTimeAsDateTime() {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// 표시용 시간 문자열
  String get displayTime => time;

  /// 요일 표시 (일본어)
  String get weekdayDisplayJa {
    const days = ['日', '月', '火', '水', '木', '金', '土'];
    return days[weekday % 7];
  }
}
