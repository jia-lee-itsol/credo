import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saint_feast_day_model.dart';
import '../../../shared/providers/liturgy_theme_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../error/failures.dart';
import '../../services/logger_service.dart';
import 'openai_service.dart';

/// 성인 축일 데이터 서비스
class SaintFeastDayService {
  static SaintsFeastDaysModel? _cachedData;

  /// 성인 축일 데이터 로드
  static Future<SaintsFeastDaysModel> loadSaintsFeastDays() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/saints/saints_feast_days.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _cachedData = SaintsFeastDaysModel.fromJson(json);
      return _cachedData!;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load saints feast days data', e, stackTrace);
      throw CacheFailure(message: '성인 축일 데이터를 불러오는데 실패했습니다: $e');
    }
  }

  /// 특정 날짜의 성인 축일 가져오기 (JSON 파일에서)
  static Future<List<SaintFeastDayModel>> getSaintsForDateFromJson(
    DateTime date,
  ) async {
    final data = await loadSaintsFeastDays();
    final month = date.month;
    final day = date.day;

    // 모든 성인 목록에서 해당 날짜 찾기
    final allSaints = [...data.saints, ...data.japaneseSaints];

    return allSaints
        .where((saint) => saint.month == month && saint.day == day)
        .toList();
  }

  /// ChatGPT를 사용하여 특정 날짜의 성인 축일 검색 (캐싱 포함)
  ///
  /// [date] 검색할 날짜
  /// [languageCode] 언어 코드
  ///
  /// 반환: 성인 모델 목록
  static Future<List<SaintFeastDayModel>> getSaintsForDateFromChatGPT(
    DateTime date,
    String languageCode,
  ) async {
    final month = date.month;
    final day = date.day;
    final year = date.year;

    // 오늘 날짜 확인 (시간 제거)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final requestDate = DateTime(year, month, day);
    final isToday = todayDate.isAtSameMomentAs(requestDate);

    // 캐시 키 생성 (날짜별로 캐싱)
    final cacheKey = 'saints_chatgpt_$year-$month-$day';

    try {
      // SharedPreferences에서 캐시 확인
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);

      String saintsJson;

      // 당일인 경우에만 캐시 사용, 다른 날짜는 항상 새로 가져오기
      if (isToday && cachedJson != null && cachedJson.isNotEmpty) {
        AppLogger.debug(
          '[SaintFeastDayService] 캐시에서 성인 검색 결과 로드: $year-$month-$day (오늘)',
        );
        saintsJson = cachedJson;
      } else {
        // 오늘이 아니거나 캐시가 없으면 ChatGPT로 검색
        if (!isToday && cachedJson != null) {
          // 오늘이 아닌 경우 기존 캐시 삭제
          await prefs.remove(cacheKey);
          AppLogger.debug(
            '[SaintFeastDayService] 오늘이 아니므로 캐시 삭제: $year-$month-$day',
          );
        }

        AppLogger.debug(
          '[SaintFeastDayService] ChatGPT로 성인 검색 시작: $year-$month-$day',
        );

        final openAIService = OpenAIService();
        saintsJson = await openAIService.searchSaintsForDate(
          date: date,
          languageCode: languageCode,
        );

        // 당일인 경우에만 캐시에 저장
        if (isToday) {
          await prefs.setString(cacheKey, saintsJson);
          AppLogger.debug(
            '[SaintFeastDayService] 성인 검색 및 캐싱 완료: $year-$month-$day (오늘)',
          );
        } else {
          AppLogger.debug(
            '[SaintFeastDayService] 성인 검색 완료 (캐시 없음): $year-$month-$day',
          );
        }
      }

      // JSON 파싱 (코드 블록이나 마크다운 제거)
      String cleanJson = saintsJson.trim();
      // JSON 코드 블록 제거
      if (cleanJson.startsWith('```')) {
        final lines = cleanJson.split('\n');
        cleanJson = lines
            .where((line) => !line.trim().startsWith('```'))
            .join('\n')
            .trim();
      }
      // JSON 객체만 추출
      final jsonStart = cleanJson.indexOf('{');
      final jsonEnd = cleanJson.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        cleanJson = cleanJson.substring(jsonStart, jsonEnd + 1);
      }

      final jsonData = jsonDecode(cleanJson) as Map<String, dynamic>;
      final saintsList = jsonData['saints'] as List<dynamic>?;

      if (saintsList == null || saintsList.isEmpty) {
        AppLogger.warning(
          '[SaintFeastDayService] ChatGPT 검색 결과에 성인이 없음: $year-$month-$day',
        );
        return [];
      }

      // SaintFeastDayModel 리스트로 변환
      final saints = <SaintFeastDayModel>[];
      for (final saintData in saintsList) {
        try {
          final saintMap = saintData as Map<String, dynamic>;
          final name = saintMap['name'] as String? ?? '';
          final nameEn = saintMap['nameEn'] as String?;
          final type = saintMap['type'] as String? ?? 'memorial';

          if (name.isNotEmpty) {
            saints.add(
              SaintFeastDayModel(
                month: month,
                day: day,
                name: name,
                nameEn: nameEn,
                nameKo: languageCode == 'ko' ? name : null,
                nameZh: languageCode == 'zh' ? name : null,
                nameVi: languageCode == 'vi' ? name : null,
                nameEs: languageCode == 'es' ? name : null,
                namePt: languageCode == 'pt' ? name : null,
                type: type,
                isJapanese: false,
                greeting: '',
              ),
            );
          }
        } catch (e) {
          AppLogger.warning('[SaintFeastDayService] 성인 데이터 파싱 실패: $saintData');
          continue;
        }
      }

      return saints;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[SaintFeastDayService] ChatGPT 성인 검색 실패: $year-$month-$day',
        e,
        stackTrace,
      );
      // 검색 실패 시 빈 리스트 반환 (또는 JSON 파일에서 가져오기)
      return [];
    }
  }

  /// 오늘의 성인 축일 가져오기 (JSON 파일에서)
  static Future<List<SaintFeastDayModel>> getTodaySaints() async {
    return getSaintsForDateFromJson(DateTime.now());
  }

  /// 성인 이름을 특정 언어로 번역 (캐싱 포함)
  ///
  /// [saint] 성인 모델
  /// [languageCode] 언어 코드: 'ko', 'zh', 'vi', 'es', 'pt'
  ///
  /// 반환: 번역된 성인 이름 (캐시에서 가져오거나 새로 번역)
  static Future<String> getTranslatedName(
    SaintFeastDayModel saint,
    String languageCode,
  ) async {
    // 일본어와 영어는 번역 불필요
    if (languageCode == 'ja') {
      return saint.name;
    }
    if (languageCode == 'en') {
      return saint.nameEn ?? saint.name;
    }

    // 캐시 키 생성 (성인 이름과 언어로 고유 키 생성)
    final cacheKey =
        'saint_name_${saint.month}_${saint.day}_${saint.name.hashCode}_$languageCode';

    try {
      // SharedPreferences에서 캐시 확인
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString(cacheKey);

      if (cachedName != null && cachedName.isNotEmpty) {
        AppLogger.debug(
          '[SaintFeastDayService] 캐시에서 성인 이름 로드: ${saint.name} ($languageCode)',
        );
        return cachedName;
      }

      // 캐시가 없으면 번역
      AppLogger.debug(
        '[SaintFeastDayService] 성인 이름 번역 시작: ${saint.name} ($languageCode)',
      );

      final openAIService = OpenAIService();
      final translatedName = await openAIService.translateSaintName(
        japaneseName: saint.name,
        englishName: saint.nameEn,
        targetLanguage: languageCode,
      );

      // 캐시에 저장 (성인 이름은 변하지 않으므로 영구 캐싱)
      await prefs.setString(cacheKey, translatedName);
      AppLogger.debug(
        '[SaintFeastDayService] 성인 이름 번역 및 캐싱 완료: ${saint.name} -> $translatedName ($languageCode)',
      );

      return translatedName;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[SaintFeastDayService] 성인 이름 번역 실패: ${saint.name} ($languageCode)',
        e,
        stackTrace,
      );
      // 번역 실패 시 폴백
      if (languageCode == 'vi' ||
          languageCode == 'es' ||
          languageCode == 'pt') {
        return saint.nameEn ?? saint.name;
      }
      return saint.name;
    }
  }

  /// 성인 목록의 모든 이름을 특정 언어로 번역 (캐싱 포함)
  ///
  /// [saints] 성인 모델 목록
  /// [languageCode] 언어 코드
  ///
  /// 반환: 번역된 이름이 포함된 성인 모델 목록
  static Future<List<SaintFeastDayModel>> getSaintsWithTranslatedNames(
    List<SaintFeastDayModel> saints,
    String languageCode,
  ) async {
    // 일본어와 영어는 번역 불필요
    if (languageCode == 'ja' || languageCode == 'en') {
      return saints;
    }

    // 각 성인 이름을 번역
    final translatedSaints = <SaintFeastDayModel>[];

    for (final saint in saints) {
      try {
        final translatedName = await getTranslatedName(saint, languageCode);

        // 번역된 이름으로 새 모델 생성
        final translatedSaint = SaintFeastDayModel(
          month: saint.month,
          day: saint.day,
          name: saint.name,
          nameEn: saint.nameEn,
          nameKo: languageCode == 'ko' ? translatedName : saint.nameKo,
          nameZh: languageCode == 'zh' ? translatedName : saint.nameZh,
          nameVi: languageCode == 'vi' ? translatedName : saint.nameVi,
          nameEs: languageCode == 'es' ? translatedName : saint.nameEs,
          namePt: languageCode == 'pt' ? translatedName : saint.namePt,
          type: saint.type,
          isJapanese: saint.isJapanese,
          greeting: saint.greeting,
          description: saint.description,
        );

        translatedSaints.add(translatedSaint);
      } catch (e) {
        // 번역 실패해도 원본 성인 추가
        AppLogger.warning(
          '[SaintFeastDayService] 성인 이름 번역 실패, 원본 사용: ${saint.name}',
        );
        translatedSaints.add(saint);
      }
    }

    return translatedSaints;
  }
}

/// 오늘의 성인 축일 Provider (ChatGPT 검색, 번역된 이름 포함)
final todaySaintsProvider = FutureProvider<List<SaintFeastDayModel>>((
  ref,
) async {
  final testDate = ref.watch(testDateOverrideProvider);
  final date = testDate ?? DateTime.now();
  final locale = ref.watch(localeProvider);
  final languageCode = locale.languageCode;

  // ChatGPT로 성인 검색 (캐싱 포함)
  final saints = await SaintFeastDayService.getSaintsForDateFromChatGPT(
    date,
    languageCode,
  );

  // 다른 언어로 번역이 필요한 경우 번역
  if (languageCode != 'ja' && languageCode != 'en') {
    return await SaintFeastDayService.getSaintsWithTranslatedNames(
      saints,
      languageCode,
    );
  }

  return saints;
});
