import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/data/services/openai_service.dart';
import '../../../../core/data/services/liturgical_reading_service.dart';
import '../../../../core/data/services/saint_feast_day_service.dart' as core;
import '../../../../core/services/logger_service.dart';
import '../../../../shared/providers/locale_provider.dart';

/// 오늘의 묵상 한마디 Provider (하루에 한 번 생성, 캐싱)
final dailyReflectionProvider = FutureProvider<String?>((ref) async {
  // 날짜 변경 감지
  ref.watch(currentDateStringProvider);
  // 새로고침 트리거
  ref.watch(dailyReflectionRefreshTriggerProvider);

  final locale = ref.watch(localeProvider);
  final languageCode = locale.languageCode;

  final now = DateTime.now();
  final year = now.year;
  final month = now.month;
  final day = now.day;

  // 캐시 키
  final cacheKey = 'daily_reflection_$year-$month-${day}_$languageCode';

  try {
    // SharedPreferences에서 캐시 확인
    final prefs = await SharedPreferences.getInstance();
    final cachedReflection = prefs.getString(cacheKey);

    if (cachedReflection != null && cachedReflection.isNotEmpty) {
      AppLogger.debug('[DailyReflectionProvider] 캐시에서 묵상 한마디 로드');
      return cachedReflection;
    }

    // 오늘의 복음 정보 가져오기
    String? gospelReference;
    String? gospelTitle;
    try {
      final liturgicalDay = await ref.watch(todayLiturgicalDayProvider.future);
      if (liturgicalDay != null) {
        gospelReference = liturgicalDay.readings.gospel.reference;
        gospelTitle = liturgicalDay.readings.gospel.title;
      }
    } catch (e) {
      AppLogger.warning('[DailyReflectionProvider] 복음 정보 로드 실패: $e');
    }

    // 오늘의 성인 정보 가져오기
    List<String>? saintNames;
    try {
      final saints = await ref.watch(core.todaySaintsProvider.future);
      if (saints.isNotEmpty) {
        saintNames = saints
            .map((saint) => saint.getName(languageCode))
            .toList();
      }
    } catch (e) {
      AppLogger.warning('[DailyReflectionProvider] 성인 정보 로드 실패: $e');
    }

    // 묵상 한마디 생성
    final openAIService = OpenAIService();
    final reflection = await openAIService.generateDailyReflection(
      gospelReference: gospelReference,
      gospelTitle: gospelTitle,
      saintNames: saintNames,
      language: languageCode,
    );

    // 캐시에 저장
    await prefs.setString(cacheKey, reflection);
    AppLogger.debug('[DailyReflectionProvider] 묵상 한마디 생성 및 캐싱 완료');

    return reflection;
  } catch (e, stackTrace) {
    AppLogger.error('[DailyReflectionProvider] 묵상 한마디 생성 실패', e, stackTrace);
    return null;
  }
});

/// 묵상 한마디 새로고침 트리거
final dailyReflectionRefreshTriggerProvider = StateProvider<int>((ref) => 0);

/// 묵상 한마디 캐시 삭제 및 새로고침
Future<void> refreshDailyReflection(WidgetRef ref) async {
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;
  final day = now.day;

  final prefs = await SharedPreferences.getInstance();
  final languages = ['ja', 'ko', 'en', 'zh', 'vi', 'es', 'pt'];
  for (final lang in languages) {
    final cacheKey = 'daily_reflection_$year-$month-${day}_$lang';
    await prefs.remove(cacheKey);
  }

  // 트리거 값을 변경하여 provider 재실행
  ref.read(dailyReflectionRefreshTriggerProvider.notifier).state++;
}
