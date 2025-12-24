import 'package:flutter/material.dart';
import '../data/services/liturgical_calendar_service.dart';

/// 전례 시즌 열거형
enum LiturgySeason {
  ordinary, // 연중 시기 (녹색)
  advent, // 대림절 (보라색)
  christmas, // 성탄절 (흰색/금색)
  lent, // 사순절 (보라색)
  easter, // 부활절 (흰색/금색)
  pentecost, // 성령 강림 (빨간색)
}

/// 전례색 상수
class LiturgyColors {
  LiturgyColors._();

  // 연중 시기 - 초록색 (희망, 성장)
  static const Color ordinaryPrimary = Color(0xFF2E7D32);
  static const Color ordinaryLight = Color(0xFF60AD5E);
  static const Color ordinaryDark = Color(0xFF005005);
  static const Color ordinaryBackground = Color(0xFFF1F8E9);

  // 대림절 - 보라색 (기다림, 준비)
  static const Color adventPrimary = Color(0xFF7B1FA2);
  static const Color adventLight = Color(0xFFE1BEE7);
  static const Color adventDark = Color(0xFF4A148C);
  static const Color adventBackground = Color(0xFFF3E5F5);

  // 사순절 - 보라색 (회개, 속죄)
  static const Color lentPrimary = Color(0xFF7B1FA2);
  static const Color lentLight = Color(0xFFE1BEE7);
  static const Color lentDark = Color(0xFF4A148C);
  static const Color lentBackground = Color(0xFFF3E5F5);

  // 골드 포인트 색상 (흰색 시기용) - 채도 낮춘 골드
  static const Color goldPrimary = Color(0xFFD4AF37); // 클래식 골드 (채도 낮음)
  static const Color goldLight = Color(0xFFF4E4BC); // 밝은 골드
  static const Color goldDark = Color(0xFFB8860B); // 어두운 골드
  static const Color goldBackground = Color(0xFFFFFDE7);

  // 성탄절 - 흰색 배경 + 골드 포인트 (기쁨, 순결)
  static const Color christmasPrimary = Color(0xFFD4AF37); // 클래식 골드 (채도 낮음)
  static const Color christmasLight = Color(0xFFFFFFFF);
  static const Color christmasDark = Color(0xFFB8860B);
  static const Color christmasBackground = Color(0xFFFFFBFE);

  // 부활절 - 흰색 배경 + 골드 포인트 (승리, 영광)
  static const Color easterPrimary = Color(0xFFD4AF37); // 클래식 골드 (채도 낮음)
  static const Color easterLight = Color(0xFFFFFFFF);
  static const Color easterDark = Color(0xFFB8860B);
  static const Color easterBackground = Color(0xFFFFFBFE);

  // 성령 강림(오순절) - 붉은색 (성령, 순교)
  static const Color pentecostPrimary = Color(0xFFC62828);
  static const Color pentecostLight = Color(0xFFFF5F52);
  static const Color pentecostDark = Color(0xFF8E0000);
  static const Color pentecostBackground = Color(0xFFFFEBEE);

  // 순교자 축일 - 붉은색 (피흘림)
  static const Color martyrPrimary = Color(0xFFC62828);
  static const Color martyrLight = Color(0xFFFF5F52);
  static const Color martyrDark = Color(0xFF8E0000);
  static const Color martyrBackground = Color(0xFFFFEBEE);

  // 성모 마리아 축일/성인 축일 - 흰색 배경 + 골드 포인트 (기쁨, 성덕)
  static const Color saintPrimary = Color(0xFFD4AF37); // 클래식 골드 (채도 낮음)
  static const Color saintLight = Color(0xFFFFFFFF);
  static const Color saintDark = Color(0xFFB8860B);
  static const Color saintBackground = Color(0xFFFFFBFE);

  /// 전례 시즌에 따른 기본 색상 반환
  static Color getPrimaryColor(LiturgySeason season) {
    switch (season) {
      case LiturgySeason.ordinary:
        return ordinaryPrimary;
      case LiturgySeason.advent:
        return adventPrimary;
      case LiturgySeason.lent:
        return lentPrimary;
      case LiturgySeason.christmas:
        return christmasPrimary;
      case LiturgySeason.easter:
        return easterPrimary;
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
        return adventBackground;
      case LiturgySeason.lent:
        return lentBackground;
      case LiturgySeason.christmas:
        return christmasBackground;
      case LiturgySeason.easter:
        return easterBackground;
      case LiturgySeason.pentecost:
        return pentecostBackground;
    }
  }

  /// 전례 시즌에 따른 ColorScheme seed 반환
  static Color getSeedColor(LiturgySeason season) {
    return getPrimaryColor(season);
  }

  /// 특별한 축일 타입에 따른 색상 반환 (순교자, 성인, 성주간 등)
  /// 전례 시기보다 우선하지 않고, 참고용으로 사용
  static Color? getColorForSpecialDayType(String? type, String? name) {
    if (type == null || name == null) return null;

    // 성주간 특별 날짜 - 붉은색 (수난 주일, 성금요일)
    if (name.contains('受難') ||
        name.contains('聖金曜日') ||
        name.contains('Passion') ||
        name.contains('Good Friday')) {
      return pentecostPrimary; // 붉은색
    }

    // 순교자 축일 체크
    if (name.contains('殉教') ||
        name.contains('殉教者') ||
        name.contains('martyr') ||
        name.contains('Martyr')) {
      return martyrPrimary;
    }

    // 성인 축일 체크 (순교자가 아닌 경우)
    if (type == 'solemnity' || type == 'feast') {
      // 성모 마리아 축일
      if (name.contains('マリア') ||
          name.contains('聖母') ||
          name.contains('Mary') ||
          name.contains('Mother of God')) {
        return saintPrimary;
      }
      // 기타 성인 축일
      if (name.contains('聖') && !name.contains('殉教')) {
        return saintPrimary;
      }
    }

    return null;
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

    // 날짜만 비교하기 위해 시간 부분 제거
    final nowDate = DateTime(now.year, now.month, now.day);

    // 부활절 계산 (Anonymous Gregorian algorithm)
    final easter = _calculateEaster(year);
    final easterDate = DateTime(easter.year, easter.month, easter.day);

    // 대림절 시작: 11월 30일에 가장 가까운 일요일
    final adventStart = _calculateAdventStart(year);
    final adventStartDate = DateTime(adventStart.year, adventStart.month, adventStart.day);

    // 성탄절: 12월 25일 ~ 1월 6일 (주현절)
    final christmasDate = DateTime(year, 12, 25);

    // 사순절: 부활절 46일 전 (재의 수요일)
    final ashWednesday = easter.subtract(const Duration(days: 46));
    final ashWednesdayDate = DateTime(ashWednesday.year, ashWednesday.month, ashWednesday.day);

    // 부활절 시즌: 부활절 ~ 성령 강림 (부활절 후 50일)
    final pentecost = easter.add(const Duration(days: 49));
    final pentecostDate = DateTime(pentecost.year, pentecost.month, pentecost.day);

    // 현재 날짜 기준 전례 시즌 판별
    // 성탄절: 12월 25일 ~ 다음해 1월 6일
    if (nowDate.month == 12 && nowDate.day >= 25) {
      return LiturgySeason.christmas;
    }
    if (nowDate.month == 1 && nowDate.day <= 6) {
      return LiturgySeason.christmas;
    }

    // 대림절: 대림절 시작일 ~ 12월 24일
    if ((nowDate.isAtSameMomentAs(adventStartDate) || nowDate.isAfter(adventStartDate)) &&
        nowDate.isBefore(christmasDate)) {
      return LiturgySeason.advent;
    }

    // 사순절: 재의 수요일 ~ 부활절 전날
    if ((nowDate.isAtSameMomentAs(ashWednesdayDate) || nowDate.isAfter(ashWednesdayDate)) &&
        nowDate.isBefore(easterDate)) {
      return LiturgySeason.lent;
    }

    // 성령 강림 (부활절 시즌보다 먼저 체크)
    if (nowDate.isAtSameMomentAs(pentecostDate)) {
      return LiturgySeason.pentecost;
    }

    // 부활절 시즌 (부활절 ~ 성령 강림 전날)
    if ((nowDate.isAtSameMomentAs(easterDate) || nowDate.isAfter(easterDate)) &&
        nowDate.isBefore(pentecostDate)) {
      return LiturgySeason.easter;
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

  /// 부활절 날짜 반환 (public 메서드)
  static DateTime calculateEaster(int year) {
    return _calculateEaster(year);
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

  /// 전례 시즌 이름 반환
  static String getSeasonName(LiturgySeason season, {String locale = 'ja'}) {
    switch (locale) {
      case 'ja':
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
      case 'ko':
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
      case 'zh':
        switch (season) {
          case LiturgySeason.ordinary:
            return '常年期';
          case LiturgySeason.advent:
            return '将临期';
          case LiturgySeason.christmas:
            return '圣诞期';
          case LiturgySeason.lent:
            return '四旬期';
          case LiturgySeason.easter:
            return '复活期';
          case LiturgySeason.pentecost:
            return '圣神降临';
        }
      case 'vi':
        switch (season) {
          case LiturgySeason.ordinary:
            return 'Thường Niên';
          case LiturgySeason.advent:
            return 'Mùa Vọng';
          case LiturgySeason.christmas:
            return 'Giáng Sinh';
          case LiturgySeason.lent:
            return 'Mùa Chay';
          case LiturgySeason.easter:
            return 'Phục Sinh';
          case LiturgySeason.pentecost:
            return 'Hiện Xuống';
        }
      case 'es':
        switch (season) {
          case LiturgySeason.ordinary:
            return 'Tiempo Ordinario';
          case LiturgySeason.advent:
            return 'Adviento';
          case LiturgySeason.christmas:
            return 'Navidad';
          case LiturgySeason.lent:
            return 'Cuaresma';
          case LiturgySeason.easter:
            return 'Pascua';
          case LiturgySeason.pentecost:
            return 'Pentecostés';
        }
      case 'pt':
        switch (season) {
          case LiturgySeason.ordinary:
            return 'Tempo Comum';
          case LiturgySeason.advent:
            return 'Advento';
          case LiturgySeason.christmas:
            return 'Natal';
          case LiturgySeason.lent:
            return 'Quaresma';
          case LiturgySeason.easter:
            return 'Páscoa';
          case LiturgySeason.pentecost:
            return 'Pentecostes';
        }
      default: // 영어 (en 등)
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
