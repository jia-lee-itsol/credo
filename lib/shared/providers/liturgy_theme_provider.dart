import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/liturgy_constants.dart';
import '../../core/data/models/liturgical_calendar_model.dart';
import '../../core/data/services/liturgical_calendar_service.dart';
import '../../core/data/services/liturgical_reading_service.dart';
import '../../core/data/services/openai_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/theme/app_theme.dart';
import '../providers/locale_provider.dart';

/// 테스트용 날짜 오버라이드 (디버그 모드에서만 사용)
/// null이면 실제 날짜 사용, 설정하면 해당 날짜 사용
final testDateOverrideProvider = StateProvider<DateTime?>((ref) {
  // 디버그 모드에서만 부활절 날짜로 테스트
  // 2025년 부활절: 2025-04-20
  if (kDebugMode) {
    // 테스트하려면 아래 주석을 해제하세요
    // return DateTime(2025, 11, 30); // 대림절 (보라색)
    // return DateTime(2025, 12, 25); // 성탄절 (골드 포인트)
    // return DateTime(2025, 1, 15); // 연중시기(1) (초록색)
    // return DateTime(2025, 3, 5); // 사순절 (보라색)
    // return DateTime(2025, 4, 18); // 성주간 - 성금요일 (붉은색)
    // return DateTime(2025, 4, 20); // 부활절 (골드 포인트)
    // return DateTime(2025, 6, 8); // 성령 강림 (붉은색)
    // return DateTime(2025, 7, 15); // 연중시기(2) (초록색)
  }
  return null;
});

/// ChatGPT로 전례력 정보 가져오기 (캐싱 포함)
final liturgyInfoFromChatGPTProvider =
    FutureProvider.family<Map<String, dynamic>?, DateTime>((ref, date) async {
      final locale = ref.watch(localeProvider);
      final languageCode = locale.languageCode;
      final month = date.month;
      final day = date.day;
      final year = date.year;

      // 캐시 키 생성 (날짜별로 캐싱)
      final cacheKey = 'liturgy_info_chatgpt_$year-$month-$day';

      try {
        // SharedPreferences에서 캐시 확인
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString(cacheKey);

        String liturgyJson;
        if (cachedJson != null && cachedJson.isNotEmpty) {
          // 캐시 히트는 로그 출력 생략 (너무 자주 호출됨)
          liturgyJson = cachedJson;
        } else {
          // 캐시가 없으면 ChatGPT로 검색
          AppLogger.debug(
            '[LiturgyThemeProvider] ChatGPT로 전례력 확인 시작: $year-$month-$day',
          );

          final openAIService = OpenAIService();
          liturgyJson = await openAIService.getLiturgyInfoForDate(
            date: date,
            languageCode: languageCode,
          );

          // 캐시에 저장 (하루에 한 번만 검색)
          await prefs.setString(cacheKey, liturgyJson);
          AppLogger.debug(
            '[LiturgyThemeProvider] 전례력 확인 및 캐싱 완료: $year-$month-$day',
          );
        }

        // JSON 파싱 (코드 블록이나 마크다운 제거)
        String cleanJson = liturgyJson.trim();
        if (cleanJson.startsWith('```')) {
          final lines = cleanJson.split('\n');
          cleanJson = lines
              .where((line) => !line.trim().startsWith('```'))
              .join('\n')
              .trim();
        }
        final jsonStart = cleanJson.indexOf('{');
        final jsonEnd = cleanJson.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          cleanJson = cleanJson.substring(jsonStart, jsonEnd + 1);
        }

        final jsonData = jsonDecode(cleanJson) as Map<String, dynamic>;
        return jsonData;
      } catch (e, stackTrace) {
        AppLogger.error(
          '[LiturgyThemeProvider] ChatGPT 전례력 확인 실패: $year-$month-$day',
          e,
          stackTrace,
        );
        return null;
      }
    });

/// 현재 전례 시즌 Provider (ChatGPT 우선, 실패 시 기존 로직)
final currentLiturgySeasonProvider = FutureProvider<LiturgySeason>((ref) async {
  final testDate = ref.watch(testDateOverrideProvider);
  final date = testDate ?? DateTime.now();

  // ChatGPT로 전례력 정보 가져오기 시도
  final liturgyInfoAsync = ref.watch(liturgyInfoFromChatGPTProvider(date));
  if (liturgyInfoAsync.hasValue && liturgyInfoAsync.value != null) {
    final liturgyInfo = liturgyInfoAsync.value!;
    final seasonStr = liturgyInfo['season'] as String?;
    if (seasonStr != null) {
      // 문자열을 LiturgySeason enum으로 변환
      switch (seasonStr.toLowerCase()) {
        case 'ordinary':
          return LiturgySeason.ordinary;
        case 'advent':
          return LiturgySeason.advent;
        case 'christmas':
          return LiturgySeason.christmas;
        case 'lent':
          return LiturgySeason.lent;
        case 'easter':
          return LiturgySeason.easter;
        case 'pentecost':
          return LiturgySeason.pentecost;
      }
    }
  }

  // ChatGPT 실패 시 기존 로직 사용
  return await LiturgySeasonUtil.getCurrentSeason(testDate);
});

/// 현재 전례 시즌 Provider (동기 - 하위 호환성)
final currentLiturgySeasonSyncProvider = Provider<LiturgySeason>((ref) {
  final testDate = ref.watch(testDateOverrideProvider);
  return LiturgySeasonUtil.getCurrentSeasonSync(testDate);
});

/// 전례 시즌 이름 Provider (ChatGPT 우선)
final liturgySeasonNameProvider = Provider.family<String, String>((
  ref,
  locale,
) {
  final testDate = ref.watch(testDateOverrideProvider);
  final date = testDate ?? DateTime.now();

  // ChatGPT로 전례력 정보 가져오기 시도
  final liturgyInfoAsync = ref.watch(liturgyInfoFromChatGPTProvider(date));
  if (liturgyInfoAsync.hasValue && liturgyInfoAsync.value != null) {
    final liturgyInfo = liturgyInfoAsync.value!;
    final seasonName = liturgyInfo['seasonName'] as String?;
    if (seasonName != null && seasonName.isNotEmpty) {
      return seasonName;
    }
  }

  // ChatGPT 실패 시 기존 로직 사용
  final seasonAsync = ref.watch(currentLiturgySeasonProvider);
  final season =
      seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync(testDate);

  // 특별한 축일 체크 (성금요일, 수난 주일 등)
  final specialDayAsync = ref.watch(specialDayProvider(date));
  if (specialDayAsync.hasValue && specialDayAsync.value != null) {
    final specialDay = specialDayAsync.value!;
    final name = specialDay.name;

    // 성주간 특별 날짜
    if (name.contains('受難') || name.contains('Passion')) {
      return locale == 'ja'
          ? '受難の主日'
          : (locale == 'ko' ? '수난 주일' : 'Passion Sunday');
    }
    if (name.contains('聖金曜日') || name.contains('Good Friday')) {
      return locale == 'ja'
          ? '聖金曜日'
          : (locale == 'ko' ? '성금요일' : 'Good Friday');
    }
    if (name.contains('聖木曜日') || name.contains('Holy Thursday')) {
      return locale == 'ja'
          ? '聖木曜日'
          : (locale == 'ko' ? '성목요일' : 'Holy Thursday');
    }
    if (name.contains('聖土曜日') || name.contains('Holy Saturday')) {
      return locale == 'ja'
          ? '聖土曜日'
          : (locale == 'ko' ? '성토요일' : 'Holy Saturday');
    }
    if (name.contains('復活') || name.contains('Easter')) {
      return locale == 'ja'
          ? '復活の主日'
          : (locale == 'ko' ? '부활 주일' : 'Easter Sunday');
    }
  }

  return LiturgySeasonUtil.getSeasonName(season, locale: locale);
});

/// 앱 테마 Provider
final appThemeProvider = Provider<ThemeData>((ref) {
  final season = ref.watch(currentLiturgySeasonSyncProvider);
  final primaryColor = ref.watch(liturgyPrimaryColorProvider);
  return AppTheme.lightTheme(season, primaryColorOverride: primaryColor);
});

/// 특별한 축일 Provider
final specialDayProvider = FutureProvider.family<SpecialDay?, DateTime>((
  ref,
  date,
) async {
  return await LiturgicalCalendarService.getSpecialDayForDate(date);
});

/// 전례 기본 색상 Provider (ChatGPT 우선, 특별한 축일 고려)
final liturgyPrimaryColorProvider = Provider<Color>((ref) {
  // 날짜 변경 감지를 위해 currentDateStringProvider를 watch
  ref.watch(currentDateStringProvider);

  final testDate = ref.watch(testDateOverrideProvider);
  final date = testDate ?? DateTime.now();

  // ChatGPT로 전례력 정보 가져오기 시도
  final liturgyInfoAsync = ref.watch(liturgyInfoFromChatGPTProvider(date));
  if (liturgyInfoAsync.hasValue && liturgyInfoAsync.value != null) {
    final liturgyInfo = liturgyInfoAsync.value!;
    final colorType = liturgyInfo['colorType'] as String?;
    final specialDay = liturgyInfo['specialDay'] as bool? ?? false;
    final specialDayType = liturgyInfo['specialDayType'] as String?;

    // 특별한 축일 색상 우선
    if (specialDay) {
      if (specialDayType == 'martyr' || specialDayType == 'passion') {
        return LiturgyColors.pentecostPrimary; // 붉은색
      }
      if (specialDayType == 'saint') {
        return LiturgyColors.saintPrimary; // 골드
      }
    }

    // 색상 타입에 따라 색상 반환
    if (colorType != null) {
      switch (colorType.toLowerCase()) {
        case 'green':
          return LiturgyColors.ordinaryPrimary;
        case 'purple':
          return LiturgyColors.adventPrimary;
        case 'gold':
          return LiturgyColors.goldPrimary;
        case 'red':
          return LiturgyColors.pentecostPrimary;
        case 'white':
          return LiturgyColors.goldPrimary; // 흰색 시기에는 골드 포인트
      }
    }
  }

  // ChatGPT 실패 시 기존 로직 사용
  final seasonAsync = ref.watch(currentLiturgySeasonProvider);
  final season =
      seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync(testDate);

  // 성주간 특별 날짜를 날짜 기반으로 직접 계산 (데이터 로딩 실패 대비)
  final year = date.year;
  final easter = LiturgySeasonUtil.calculateEaster(year);
  final goodFriday = easter.subtract(const Duration(days: 2)); // 부활절 2일 전
  final passionSunday = easter.subtract(
    const Duration(days: 7),
  ); // 부활절 7일 전 (주일)

  // 성금요일 체크 (날짜 기반)
  if (date.year == goodFriday.year &&
      date.month == goodFriday.month &&
      date.day == goodFriday.day) {
    return LiturgyColors.pentecostPrimary; // 붉은색
  }

  // 수난 주일 체크 (날짜 기반) - 부활절 7일 전 일요일
  if (date.year == passionSunday.year &&
      date.month == passionSunday.month &&
      date.day == passionSunday.day) {
    return LiturgyColors.pentecostPrimary; // 붉은색
  }

  // 특별한 축일 체크 (성금요일, 수난 주일, 순교자 축일은 붉은색 우선)
  final specialDayAsync = ref.watch(specialDayProvider(date));
  if (specialDayAsync.hasValue && specialDayAsync.value != null) {
    final specialDay = specialDayAsync.value!;
    final name = specialDay.name;

    // 성주간 특별 날짜 - 붉은색 (수난 주일, 성금요일)
    if (name.isNotEmpty &&
        (name.contains('受難') ||
            name.contains('聖金曜日') ||
            name.contains('Passion') ||
            name.contains('Good Friday'))) {
      return LiturgyColors.pentecostPrimary; // 붉은색
    }

    // 순교자 축일 - 붉은색
    if (name.isNotEmpty &&
        (name.contains('殉教') ||
            name.contains('殉教者') ||
            name.contains('martyr') ||
            name.contains('Martyr'))) {
      return LiturgyColors.martyrPrimary; // 붉은색
    }
  }

  return LiturgyColors.getPrimaryColor(season);
});

/// 전례 배경 색상 Provider (ChatGPT 우선)
final liturgyBackgroundColorProvider = Provider<Color>((ref) {
  final testDate = ref.watch(testDateOverrideProvider);
  final date = testDate ?? DateTime.now();

  // ChatGPT로 전례력 정보 가져오기 시도
  final liturgyInfoAsync = ref.watch(liturgyInfoFromChatGPTProvider(date));
  if (liturgyInfoAsync.hasValue && liturgyInfoAsync.value != null) {
    final liturgyInfo = liturgyInfoAsync.value!;
    final colorType = liturgyInfo['colorType'] as String?;

    // 색상 타입에 따라 배경 색상 반환
    if (colorType != null) {
      switch (colorType.toLowerCase()) {
        case 'green':
          return LiturgyColors.ordinaryBackground;
        case 'purple':
          return LiturgyColors.adventBackground;
        case 'gold':
        case 'white':
          return LiturgyColors.goldBackground;
        case 'red':
          return LiturgyColors.pentecostBackground;
      }
    }
  }

  // ChatGPT 실패 시 기존 로직 사용
  final season = ref.watch(currentLiturgySeasonSyncProvider);
  return LiturgyColors.getBackgroundColor(season);
});

/// 전례 시즌 정보 Notifier (수동 업데이트 필요 시 사용)
class LiturgySeasonNotifier extends StateNotifier<LiturgySeason> {
  LiturgySeasonNotifier() : super(LiturgySeasonUtil.getCurrentSeasonSync());

  /// 시즌 새로고침
  Future<void> refresh() async {
    state = await LiturgySeasonUtil.getCurrentSeason();
  }

  /// 특정 날짜로 시즌 설정 (테스트/미리보기용)
  Future<void> setDate(DateTime date) async {
    state = await LiturgySeasonUtil.getCurrentSeason(date);
  }
}

/// 전례 시즌 Notifier Provider
final liturgySeasonNotifierProvider =
    StateNotifierProvider<LiturgySeasonNotifier, LiturgySeason>((ref) {
      return LiturgySeasonNotifier();
    });

/// 전례력 캐시 삭제 (강제 새로고침용)
Future<void> clearLiturgyCache() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now();
  final year = today.year;
  final month = today.month;
  final day = today.day;

  // 오늘 날짜의 전례력 캐시 삭제
  final cacheKey = 'liturgy_info_chatgpt_$year-$month-$day';
  await prefs.remove(cacheKey);

  AppLogger.debug('[LiturgyThemeProvider] 전례력 캐시 삭제 완료: $year-$month-$day');
}
