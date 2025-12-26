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

/// 전례색 문자열을 Color로 변환하는 헬퍼 함수
Color _getLiturgicalColorFromString(String color) {
  switch (color) {
    case 'white':
      return LiturgyColors.goldPrimary; // 금색으로 표시 (흰색은 보이지 않으므로)
    case 'red':
      return LiturgyColors.pentecostPrimary; // 채도 낮춘 빨간색
    case 'green':
      return LiturgyColors.ordinaryPrimary;
    case 'purple':
      return LiturgyColors.adventPrimary;
    case 'rose':
      return const Color(0xFFD4878F); // 장미색 (채도 낮춤)
    case 'black':
      return Colors.black87;
    default:
      return LiturgyColors.ordinaryPrimary;
  }
}

/// 전례일 이름 요약 (헤더용)
String _summarizeLiturgicalDayName(String name) {
  // 너무 긴 이름은 요약
  // 예: "성 스테파노 부제 순교자 축일" -> "성 스테파노 순교자"
  // 예: "예수 성탄 대축일 팔일 축제 제2일" -> "성탄 팔일 축제"

  String result = name;

  // "축일", "대축일", "기념일" 등 제거
  result = result.replaceAll(' 축일', '');
  result = result.replaceAll(' 대축일', '');
  result = result.replaceAll(' 기념일', '');
  result = result.replaceAll('축일', '');
  result = result.replaceAll('대축일', '');
  result = result.replaceAll('기념일', '');

  // "부제" 제거 (성 스테파노 부제 순교자 -> 성 스테파노 순교자)
  result = result.replaceAll(' 부제', '');
  result = result.replaceAll('부제 ', '');

  // 일본어: 祝日, 大祝日 등 제거
  result = result.replaceAll('祝日', '');
  result = result.replaceAll('大祝日', '');
  result = result.replaceAll('記念日', '');

  // 영어: Feast, Solemnity 등 제거
  result = result.replaceAll(' Feast', '');
  result = result.replaceAll(' Solemnity', '');
  result = result.replaceAll(' Memorial', '');
  result = result.replaceAll('Feast of ', '');
  result = result.replaceAll('Solemnity of ', '');
  result = result.replaceAll('Memorial of ', '');

  // 최대 15자로 제한
  if (result.length > 15) {
    result = '${result.substring(0, 14)}…';
  }

  return result.trim();
}

/// 전례일 이름 Provider (말씀 전례일 카드 우선)
final liturgyDayNameProvider = Provider.family<String, String>((ref, locale) {
  // 1. 말씀 화면의 전례일 데이터에서 이름 가져오기 (우선)
  final liturgicalDayAsync = ref.watch(todayLiturgicalDayProvider);
  if (liturgicalDayAsync.hasValue && liturgicalDayAsync.value != null) {
    final liturgicalDay = liturgicalDayAsync.value!;
    // 전례일 이름이 있으면 사용, 없으면 시즌 이름 사용
    if (liturgicalDay.name.isNotEmpty) {
      return _summarizeLiturgicalDayName(liturgicalDay.name);
    }
    // 이름이 비어있으면 시즌 이름 반환
    return _getSeasonNameFromString(liturgicalDay.season, locale);
  }

  // 2. 전례일 데이터 로딩 중이거나 실패 시 기존 로직 사용
  final testDate = ref.watch(testDateOverrideProvider);
  final seasonAsync = ref.watch(currentLiturgySeasonProvider);
  final season =
      seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync(testDate);
  return LiturgySeasonUtil.getSeasonName(season, locale: locale);
});

/// 시즌 문자열을 로케일에 맞는 이름으로 변환
String _getSeasonNameFromString(String season, String locale) {
  switch (locale) {
    case 'ko':
      switch (season) {
        case 'ordinary':
          return '연중';
        case 'advent':
          return '대림';
        case 'christmas':
          return '성탄';
        case 'lent':
          return '사순';
        case 'easter':
          return '부활';
        default:
          return '연중';
      }
    case 'ja':
      switch (season) {
        case 'ordinary':
          return '年間';
        case 'advent':
          return '待降節';
        case 'christmas':
          return '降誕節';
        case 'lent':
          return '四旬節';
        case 'easter':
          return '復活節';
        default:
          return '年間';
      }
    case 'en':
    default:
      switch (season) {
        case 'ordinary':
          return 'Ordinary Time';
        case 'advent':
          return 'Advent';
        case 'christmas':
          return 'Christmas';
        case 'lent':
          return 'Lent';
        case 'easter':
          return 'Easter';
        default:
          return 'Ordinary Time';
      }
  }
}

/// 전례 기본 색상 Provider (말씀 전례일 카드 우선)
final liturgyPrimaryColorProvider = Provider<Color>((ref) {
  // 날짜 변경 감지를 위해 currentDateStringProvider를 watch
  ref.watch(currentDateStringProvider);

  // 1. 말씀 화면의 전례일 데이터에서 색상 가져오기 (우선)
  final liturgicalDayAsync = ref.watch(todayLiturgicalDayProvider);
  if (liturgicalDayAsync.hasValue && liturgicalDayAsync.value != null) {
    final liturgicalDay = liturgicalDayAsync.value!;
    return _getLiturgicalColorFromString(liturgicalDay.color);
  }

  // 2. 전례일 데이터 로딩 중이거나 실패 시 기존 로직 사용
  final testDate = ref.watch(testDateOverrideProvider);
  final seasonAsync = ref.watch(currentLiturgySeasonProvider);
  final season =
      seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync(testDate);

  return LiturgyColors.getPrimaryColor(season);
});

/// 전례색 문자열에서 그라데이션 시작 색상 반환
Color _getGradientStartFromColorString(String color) {
  switch (color) {
    case 'white':
      return LiturgyColors.christmasGradientStart;
    case 'red':
      return LiturgyColors.pentecostGradientStart;
    case 'green':
      return LiturgyColors.ordinaryGradientStart;
    case 'purple':
      return LiturgyColors.adventGradientStart;
    case 'rose':
      return const Color(0xFFDEA0A7); // 장미색 밝은 톤 (채도 낮춤)
    case 'black':
      return const Color(0xFF424242);
    default:
      return LiturgyColors.ordinaryGradientStart;
  }
}

/// 전례색 문자열에서 그라데이션 끝 색상 반환
Color _getGradientEndFromColorString(String color) {
  switch (color) {
    case 'white':
      return LiturgyColors.christmasGradientEnd;
    case 'red':
      return LiturgyColors.pentecostGradientEnd;
    case 'green':
      return LiturgyColors.ordinaryGradientEnd;
    case 'purple':
      return LiturgyColors.adventGradientEnd;
    case 'rose':
      return const Color(0xFFD4878F); // 장미색 진한 톤 (채도 낮춤)
    case 'black':
      return const Color(0xFF212121);
    default:
      return LiturgyColors.ordinaryGradientEnd;
  }
}

/// 전례 그라데이션 시작 색상 Provider
final liturgyGradientStartColorProvider = Provider<Color>((ref) {
  // 1. 말씀 화면의 전례일 데이터에서 색상 가져오기 (우선)
  final liturgicalDayAsync = ref.watch(todayLiturgicalDayProvider);
  if (liturgicalDayAsync.hasValue && liturgicalDayAsync.value != null) {
    final liturgicalDay = liturgicalDayAsync.value!;
    return _getGradientStartFromColorString(liturgicalDay.color);
  }

  // 2. 전례일 데이터 로딩 중이거나 실패 시 기존 로직 사용
  final testDate = ref.watch(testDateOverrideProvider);
  final seasonAsync = ref.watch(currentLiturgySeasonProvider);
  final season =
      seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync(testDate);
  return LiturgyColors.getGradientStartColor(season);
});

/// 전례 그라데이션 끝 색상 Provider
final liturgyGradientEndColorProvider = Provider<Color>((ref) {
  // 1. 말씀 화면의 전례일 데이터에서 색상 가져오기 (우선)
  final liturgicalDayAsync = ref.watch(todayLiturgicalDayProvider);
  if (liturgicalDayAsync.hasValue && liturgicalDayAsync.value != null) {
    final liturgicalDay = liturgicalDayAsync.value!;
    return _getGradientEndFromColorString(liturgicalDay.color);
  }

  // 2. 전례일 데이터 로딩 중이거나 실패 시 기존 로직 사용
  final testDate = ref.watch(testDateOverrideProvider);
  final seasonAsync = ref.watch(currentLiturgySeasonProvider);
  final season =
      seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync(testDate);
  return LiturgyColors.getGradientEndColor(season);
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
