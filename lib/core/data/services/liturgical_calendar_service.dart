import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/liturgical_calendar_model.dart';
import '../../constants/liturgy_constants.dart';

/// 전례력 데이터 서비스
class LiturgicalCalendarService {
  /// 연도별 전례력 데이터 로드
  static Future<LiturgicalCalendarModel?> loadCalendar(int year) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/liturgical_calendar_$year.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return LiturgicalCalendarModel.fromJson(json);
    } catch (e) {
      // 파일이 없으면 null 반환 (기본 계산 로직 사용)
      return null;
    }
  }

  /// 현재 날짜에 맞는 전례력 데이터 로드
  /// 전례력 연도는 대림절 시작일부터 다음 해 대림절 전까지이므로,
  /// 현재 날짜가 속한 전례력 연도를 찾아야 함
  static Future<LiturgicalCalendarModel?> loadCurrentCalendar([
    DateTime? date,
  ]) async {
    final now = date ?? DateTime.now();
    final currentYear = now.year;

    // 가능한 연도들: 현재 연도, 이전 연도, 다음 연도
    // (대림절이 11-12월에 시작할 수 있으므로)
    final yearsToTry = [currentYear - 1, currentYear, currentYear + 1];

    for (final year in yearsToTry) {
      final calendar = await loadCalendar(year);
      if (calendar == null) continue;

      try {
        final adventStart = _parseDate(calendar.seasons.advent.start);

        // 다음 해 전례력 데이터를 확인하여 다음 대림절 시작일을 알아야 함
        final nextYearCalendar = await loadCalendar(year + 1);
        if (nextYearCalendar != null) {
          final nextAdventStart = _parseDate(
            nextYearCalendar.seasons.advent.start,
          );
          // 현재 날짜가 이 전례력 연도 범위 내에 있는지 확인
          // (대림절 시작일부터 다음 해 대림절 시작 전까지)
          if (now.isAfter(adventStart.subtract(const Duration(days: 1))) &&
              now.isBefore(nextAdventStart)) {
            return calendar;
          }
        } else {
          // 다음 해 데이터가 없으면, 현재 날짜가 대림절 시작일 이후인지 확인
          // (대림절은 연도를 넘지 않으므로, 현재가 대림절 시작일 이후면 이 전례력 연도)
          if (now.isAfter(adventStart.subtract(const Duration(days: 1)))) {
            // 단, 현재 연도가 전례력 연도보다 크면 다음 해 전례력일 수 있음
            if (now.year <= year + 1) {
              return calendar;
            }
          }
        }
      } catch (e) {
        // 파싱 오류가 있으면 다음 연도 시도
        continue;
      }
    }

    // 위 로직으로 찾지 못한 경우, 현재 연도 데이터를 반환 (있으면)
    return await loadCalendar(currentYear);
  }

  /// 날짜 문자열을 DateTime으로 변환
  static DateTime _parseDate(String dateString) {
    final parts = dateString.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// 데이터 파일에서 전례 시즌 가져오기 (없으면 계산 로직 사용)
  static Future<LiturgySeason> getSeasonForDate(DateTime date) async {
    final calendar = await loadCurrentCalendar(date);

    if (calendar == null) {
      // 데이터 파일이 없으면 기존 계산 로직 사용
      return LiturgySeasonUtil.getCurrentSeasonSync(date);
    }

    final seasons = calendar.seasons;

    // 성탄절 (대림절보다 먼저 체크)
    final christmasStart = _parseDate(seasons.christmas.start);
    final christmasEnd = _parseDate(seasons.christmas.end);
    if (date.isAfter(christmasStart.subtract(const Duration(days: 1))) &&
        date.isBefore(christmasEnd.add(const Duration(days: 1)))) {
      return LiturgySeason.christmas;
    }

    // 대림절
    final adventStart = _parseDate(seasons.advent.start);
    final adventEnd = _parseDate(seasons.advent.end);
    if (date.isAfter(adventStart.subtract(const Duration(days: 1))) &&
        date.isBefore(adventEnd.add(const Duration(days: 1)))) {
      return LiturgySeason.advent;
    }

    // 사순절
    final lentStart = _parseDate(seasons.lent.start);
    final lentEnd = _parseDate(seasons.lent.end);
    if (date.isAfter(lentStart.subtract(const Duration(days: 1))) &&
        date.isBefore(lentEnd.add(const Duration(days: 1)))) {
      return LiturgySeason.lent;
    }

    // 성령 강림 (부활절 시즌보다 먼저 체크)
    final pentecostDate = _parseDate(seasons.pentecost.date);
    if (date.year == pentecostDate.year &&
        date.month == pentecostDate.month &&
        date.day == pentecostDate.day) {
      return LiturgySeason.pentecost;
    }

    // 부활절
    final easterStart = _parseDate(seasons.easter.start);
    final easterEnd = _parseDate(seasons.easter.end);
    if (date.isAfter(easterStart.subtract(const Duration(days: 1))) &&
        date.isBefore(easterEnd.add(const Duration(days: 1)))) {
      return LiturgySeason.easter;
    }

    return LiturgySeason.ordinary;
  }

  /// 특정 날짜의 특별한 축일 가져오기
  static Future<SpecialDay?> getSpecialDayForDate(DateTime date) async {
    final calendar = await loadCurrentCalendar(date);
    if (calendar == null) return null;

    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      return calendar.specialDays.firstWhere((day) => day.date == dateString);
    } catch (e) {
      // 찾지 못한 경우 null 반환
      return null;
    }
  }
}

/// 전례력 데이터 Provider
final liturgicalCalendarProvider = FutureProvider<LiturgicalCalendarModel?>((
  ref,
) {
  return LiturgicalCalendarService.loadCurrentCalendar();
});
