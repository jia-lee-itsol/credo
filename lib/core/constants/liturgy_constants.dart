import 'package:flutter/material.dart';
import '../data/services/liturgical_calendar_service.dart';

/// 전례 시즌 열거형
enum LiturgySeason {
  ordinary,      // 연중 시기 (녹색)
  advent,        // 대림절 (보라색)
  christmas,     // 성탄절 (흰색/금색)
  lent,          // 사순절 (보라색)
  easter,        // 부활절 (흰색/금색)
  pentecost,     // 성령 강림 (빨간색)
}

/// 전례색 상수
class LiturgyColors {
  LiturgyColors._();

  // 연중 시기 - 녹색 (희망, 성장)
  static const Color ordinaryPrimary = Color(0xFF2E7D32);
  static const Color ordinaryLight = Color(0xFF60AD5E);
  static const Color ordinaryDark = Color(0xFF005005);
  static const Color ordinaryBackground = Color(0xFFF1F8E9);

  // 대림절/사순절 - 보라색 (준비, 회개)
  static const Color adventPrimary = Color(0xFF6A1B9A);
  static const Color adventLight = Color(0xFF9C4DCC);
  static const Color adventDark = Color(0xFF38006B);
  static const Color adventBackground = Color(0xFFF3E5F5);

  // 성탄절/부활절 - 흰색/금색 (기쁨, 축제)
  static const Color christmasPrimary = Color(0xFFFFD700);
  static const Color christmasLight = Color(0xFFFFFF52);
  static const Color christmasDark = Color(0xFFC7A600);
  static const Color christmasBackground = Color(0xFFFFFDE7);

  // 성령 강림/순교자 - 빨간색 (성령, 희생)
  static const Color pentecostPrimary = Color(0xFFC62828);
  static const Color pentecostLight = Color(0xFFFF5F52);
  static const Color pentecostDark = Color(0xFF8E0000);
  static const Color pentecostBackground = Color(0xFFFFEBEE);

  /// 전례 시즌에 따른 기본 색상 반환
  static Color getPrimaryColor(LiturgySeason season) {
    switch (season) {
      case LiturgySeason.ordinary:
        return ordinaryPrimary;
      case LiturgySeason.advent:
      case LiturgySeason.lent:
        return adventPrimary;
      case LiturgySeason.christmas:
      case LiturgySeason.easter:
        return christmasPrimary;
      case LiturgySeason.pentecost:
        return pentecostPrimary;
    }
  }

  /// 전례 시즌에 따른 배경 색상 반환
  static Color getBackgroundColor(LiturgySeason season) {
    switch (season) {
      case LiturgySeason.ordinary:
        return ordinaryBackground;
      case LiturgySeason.advent:
      case LiturgySeason.lent:
        return adventBackground;
      case LiturgySeason.christmas:
      case LiturgySeason.easter:
        return christmasBackground;
      case LiturgySeason.pentecost:
        return pentecostBackground;
    }
  }

  /// 전례 시즌에 따른 ColorScheme seed 반환
  static Color getSeedColor(LiturgySeason season) {
    return getPrimaryColor(season);
  }
}

/// 전례 시즌 유틸리티
class LiturgySeasonUtil {
  LiturgySeasonUtil._();

  /// 현재 날짜에 해당하는 전례 시즌 계산
  /// 데이터 파일이 있으면 우선 사용, 없으면 계산 로직 사용
  static Future<LiturgySeason> getCurrentSeason([DateTime? date]) async {
    final now = date ?? DateTime.now();
    
    // 데이터 파일에서 시즌 가져오기 시도
    try {
      final season = await LiturgicalCalendarService.getSeasonForDate(now);
      return season;
    } catch (e) {
      // 실패하면 계산 로직 사용
      return getCurrentSeasonSync(now);
    }
  }

  /// 동기 버전 (하위 호환성 유지)
  /// 데이터 파일을 사용하지 않고 계산만 수행
  static LiturgySeason getCurrentSeasonSync([DateTime? date]) {
    final now = date ?? DateTime.now();
    final year = now.year;

    // 부활절 계산 (Anonymous Gregorian algorithm)
    final easter = _calculateEaster(year);

    // 대림절 시작: 11월 30일에 가장 가까운 일요일
    final adventStart = _calculateAdventStart(year);

    // 성탄절: 12월 25일 ~ 1월 첫째 일요일 이후
    final christmas = DateTime(year, 12, 25);
    final epiphany = _calculateEpiphany(year + 1);

    // 사순절: 부활절 46일 전 (재의 수요일)
    final ashWednesday = easter.subtract(const Duration(days: 46));

    // 부활절 시즌: 부활절 ~ 성령 강림 (부활절 후 50일)
    final pentecost = easter.add(const Duration(days: 49));

    // 현재 날짜 기준 전례 시즌 판별
    if (now.isAfter(adventStart.subtract(const Duration(days: 1))) &&
        now.isBefore(christmas)) {
      return LiturgySeason.advent;
    }

    if ((now.isAfter(christmas.subtract(const Duration(days: 1))) &&
            now.year == year) ||
        (now.isBefore(epiphany.add(const Duration(days: 1))) &&
            now.year == year + 1)) {
      return LiturgySeason.christmas;
    }

    if (now.isAfter(ashWednesday.subtract(const Duration(days: 1))) &&
        now.isBefore(easter)) {
      return LiturgySeason.lent;
    }

    if (now.isAfter(easter.subtract(const Duration(days: 1))) &&
        now.isBefore(pentecost.add(const Duration(days: 1)))) {
      return LiturgySeason.easter;
    }

    if (now.day == pentecost.day &&
        now.month == pentecost.month &&
        now.year == pentecost.year) {
      return LiturgySeason.pentecost;
    }

    return LiturgySeason.ordinary;
  }

  /// 부활절 날짜 계산 (Anonymous Gregorian algorithm)
  static DateTime _calculateEaster(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;

    return DateTime(year, month, day);
  }

  /// 대림절 시작일 계산 (11월 30일에 가장 가까운 일요일)
  static DateTime _calculateAdventStart(int year) {
    final nov30 = DateTime(year, 11, 30);
    final weekday = nov30.weekday % 7; // 일요일 = 0

    if (weekday == 0) {
      return nov30;
    } else if (weekday <= 3) {
      return nov30.subtract(Duration(days: weekday));
    } else {
      return nov30.add(Duration(days: 7 - weekday));
    }
  }

  /// 주현절 계산 (1월 6일 또는 가장 가까운 일요일)
  static DateTime _calculateEpiphany(int year) {
    // 일본에서는 1월 6일을 주현절로 사용
    return DateTime(year, 1, 6);
  }

  /// 전례 시즌 이름 반환
  static String getSeasonName(LiturgySeason season, {String locale = 'ja'}) {
    if (locale == 'ja') {
      switch (season) {
        case LiturgySeason.ordinary:
          return '年間';
        case LiturgySeason.advent:
          return '待降節';
        case LiturgySeason.christmas:
          return '降誕節';
        case LiturgySeason.lent:
          return '四旬節';
        case LiturgySeason.easter:
          return '復活節';
        case LiturgySeason.pentecost:
          return '聖霊降臨';
      }
    } else if (locale == 'ko') {
      switch (season) {
        case LiturgySeason.ordinary:
          return '연중';
        case LiturgySeason.advent:
          return '대림';
        case LiturgySeason.christmas:
          return '성탄';
        case LiturgySeason.lent:
          return '사순';
        case LiturgySeason.easter:
          return '부활';
        case LiturgySeason.pentecost:
          return '성령 강림';
      }
    } else {
      switch (season) {
        case LiturgySeason.ordinary:
          return 'Ordinary Time';
        case LiturgySeason.advent:
          return 'Advent';
        case LiturgySeason.christmas:
          return 'Christmas';
        case LiturgySeason.lent:
          return 'Lent';
        case LiturgySeason.easter:
          return 'Easter';
        case LiturgySeason.pentecost:
          return 'Pentecost';
      }
    }
  }
}
