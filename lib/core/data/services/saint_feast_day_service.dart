import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saint_feast_day_model.dart';
import '../../../shared/providers/liturgy_theme_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../services/logger_service.dart';
import 'openai_service.dart';
import 'liturgical_reading_service.dart';
import 'saint_image_service.dart';

/// 성인 축일 데이터 서비스
class SaintFeastDayService {
  /// 오늘의 성인 캐시 삭제 (강제 새로고침용)
  static Future<void> clearTodaySaintsCache() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final month = today.month;
    final day = today.day;
    final year = today.year;

    // 모든 언어의 캐시 삭제
    final languages = ['ja', 'ko', 'en', 'zh', 'vi', 'es', 'pt'];
    for (final lang in languages) {
      final cacheKey = 'saints_chatgpt_$year-$month-${day}_$lang';
      final cacheDateKey = 'saints_chatgpt_date_$year-$month-${day}_$lang';
      await prefs.remove(cacheKey);
      await prefs.remove(cacheDateKey);
    }

    // 실패한 이미지 URL 목록도 삭제
    await prefs.remove('failed_saint_image_urls');

    AppLogger.debug('[SaintFeastDayService] 오늘의 성인 캐시 삭제 완료: $year-$month-$day');
  }

  /// JSON 문자열을 파싱하여 Map으로 변환
  static Map<String, dynamic>? _parseJsonString(String jsonString) {
    try {
      String cleanJson = jsonString.trim();
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
      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.warning('[SaintFeastDayService] JSON 파싱 실패: $e');
      return null;
    }
  }

  /// 성인 축일 데이터 로드 (더 이상 JSON 파일 사용 안 함, GPT 전용)
  /// 하위 호환성을 위해 유지하지만 빈 리스트 반환
  static Future<SaintsFeastDaysModel> loadSaintsFeastDays() async {
    AppLogger.warning(
      '[SaintFeastDayService] loadSaintsFeastDays는 더 이상 사용되지 않습니다. GPT를 사용하세요.',
    );
    // 빈 모델 반환 (하위 호환성)
    return const SaintsFeastDaysModel(saints: [], japaneseSaints: []);
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

    // 캐시 키 생성 (날짜별, 언어별로 캐싱)
    final cacheKey = 'saints_chatgpt_$year-$month-${day}_$languageCode';
    final cacheDateKey =
        'saints_chatgpt_date_$year-$month-${day}_$languageCode';

    try {
      // SharedPreferences에서 캐시 확인
      final prefs = await SharedPreferences.getInstance();
      String? cachedJson = prefs.getString(cacheKey);
      final cachedDate = prefs.getString(cacheDateKey);
      final todayDateString = '${today.year}-${today.month}-${today.day}';

      String? saintsJson;

      // 오늘이고, 캐시가 있고, 캐시 날짜가 오늘인 경우에만 캐시 사용
      bool useCache = false;
      if (isToday &&
          cachedJson != null &&
          cachedJson.isNotEmpty &&
          cachedDate == todayDateString) {
        // 캐시된 데이터에 이미지가 있는지 확인
        final jsonData = _parseJsonString(cachedJson);
        if (jsonData != null) {
          final saintsList = jsonData['saints'] as List<dynamic>?;

          // 캐시된 데이터에 이미지가 하나라도 없으면 캐시 무효화하고 다시 검색
          bool hasImage = false;
          if (saintsList != null && saintsList.isNotEmpty) {
            for (final saintData in saintsList) {
              final saintMap = saintData as Map<String, dynamic>;
              final imageUrl = saintMap['imageUrl'] as String?;
              if (imageUrl != null && imageUrl.isNotEmpty) {
                hasImage = true;
                break;
              }
            }
          }

          if (hasImage) {
            AppLogger.debug(
              '[SaintFeastDayService] 캐시에서 성인 검색 결과 로드: $year-$month-$day ($languageCode)',
            );
            saintsJson = cachedJson;
            useCache = true;
          } else {
            // 이미지가 없으면 캐시 무효화하고 다시 검색
            AppLogger.debug(
              '[SaintFeastDayService] 캐시에 이미지가 없어 재검색: $year-$month-$day ($languageCode)',
            );
            await prefs.remove(cacheKey);
            await prefs.remove(cacheDateKey);
            cachedJson = null; // 캐시 무효화 표시
          }
        } else {
          // 캐시 파싱 실패 시 다시 검색
          AppLogger.warning(
            '[SaintFeastDayService] 캐시 파싱 실패, 재검색: $year-$month-$day ($languageCode)',
          );
          await prefs.remove(cacheKey);
          await prefs.remove(cacheDateKey);
          cachedJson = null;
        }
      }

      // 캐시가 없거나 무효화된 경우 ChatGPT로 검색
      if (!useCache) {
        // 오늘이 아니거나 캐시가 없거나 날짜가 다르면 ChatGPT로 검색
        if (!isToday && cachedJson != null) {
          // 오늘이 아닌 경우 기존 캐시 삭제
          await prefs.remove(cacheKey);
          await prefs.remove(cacheDateKey);
          AppLogger.debug(
            '[SaintFeastDayService] 오늘이 아니므로 캐시 삭제: $year-$month-$day ($languageCode)',
          );
        }

        AppLogger.debug(
          '[SaintFeastDayService] ChatGPT로 성인 검색 시작: $year-$month-$day ($languageCode)',
        );

        final openAIService = OpenAIService();
        saintsJson = await openAIService.searchSaintsForDate(
          date: date,
          languageCode: languageCode,
        );

        // 당일인 경우에만 캐시에 저장
        if (isToday) {
          await prefs.setString(cacheKey, saintsJson);
          await prefs.setString(cacheDateKey, todayDateString);
          AppLogger.debug(
            '[SaintFeastDayService] 성인 검색 및 캐싱 완료: $year-$month-$day ($languageCode)',
          );
        } else {
          AppLogger.debug(
            '[SaintFeastDayService] 성인 검색 완료 (캐시 없음): $year-$month-$day ($languageCode)',
          );
        }
      }

      // JSON 파싱
      final jsonData = _parseJsonString(saintsJson!);
      if (jsonData == null) {
        AppLogger.warning(
          '[SaintFeastDayService] JSON 파싱 실패: $year-$month-$day ($languageCode)',
        );
        return [];
      }
      final saintsList = jsonData['saints'] as List<dynamic>?;

      if (saintsList == null || saintsList.isEmpty) {
        AppLogger.warning(
          '[SaintFeastDayService] ChatGPT 검색 결과에 성인이 없음: $year-$month-$day',
        );
        return [];
      }

      // SaintFeastDayModel 리스트로 변환
      // GPT가 이미 해당 언어로 이름을 반환하므로, 언어별 필드에 직접 저장
      final saints = <SaintFeastDayModel>[];
      for (final saintData in saintsList) {
        try {
          final saintMap = saintData as Map<String, dynamic>;
          final name = saintMap['name'] as String? ?? '';
          final nameEn = saintMap['nameEn'] as String?;
          final type = saintMap['type'] as String? ?? 'memorial';
          var imageUrl = saintMap['imageUrl'] as String?;

          if (name.isNotEmpty) {
            // GPT가 반환한 이름을 해당 언어 필드에 저장
            // 일본어는 기본 name 필드에, 영어는 nameEn에 저장
            // 다른 언어는 해당 언어 필드에 저장
            final japaneseName = languageCode == 'ja' ? name : (nameEn ?? name);
            final englishName = languageCode == 'en' ? name : nameEn;

            // GPT가 반환한 이미지 URL이 유효한지 확인하고, 없거나 유효하지 않으면 Wikipedia API 사용
            String? validImageUrl = imageUrl;
            if (validImageUrl != null && validImageUrl.isNotEmpty) {
              // GPT가 반환한 URL 유효성 확인
              final imageService = SaintImageService();
              final isValid = await imageService.validateImageUrl(validImageUrl);
              if (!isValid) {
                AppLogger.debug(
                  '[SaintFeastDayService] GPT 이미지 URL 유효하지 않음, Wikipedia 검색: $name',
                );
                validImageUrl = null;
              }
            }

            // 이미지 URL이 없으면 Wikipedia API로 검색
            if (validImageUrl == null || validImageUrl.isEmpty) {
              final tempSaint = SaintFeastDayModel(
                month: month,
                day: day,
                name: japaneseName,
                nameEn: englishName,
                type: type,
                isJapanese: false,
                greeting: '',
              );
              final imageService = SaintImageService();
              validImageUrl = await imageService.searchSaintImage(
                tempSaint,
                languageCode,
              );
            }

            saints.add(
              SaintFeastDayModel(
                month: month,
                day: day,
                name: japaneseName, // 일본어 이름 (기본값)
                nameEn: englishName,
                nameKo: languageCode == 'ko' ? name : null,
                nameZh: languageCode == 'zh' ? name : null,
                nameVi: languageCode == 'vi' ? name : null,
                nameEs: languageCode == 'es' ? name : null,
                namePt: languageCode == 'pt' ? name : null,
                type: type,
                isJapanese: false,
                greeting: '',
                imageUrl: validImageUrl,
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
      // 검색 실패 시 빈 리스트 반환
      return [];
    }
  }

  /// 오늘의 성인 축일 가져오기 (GPT 사용, 언어별 캐싱 포함)
  ///
  /// [languageCode] 언어 코드 (선택사항, 없으면 기본값 사용)
  static Future<List<SaintFeastDayModel>> getTodaySaints({
    String? languageCode,
  }) async {
    final today = DateTime.now();
    final locale = languageCode ?? 'ja'; // 기본값은 일본어

    // GPT를 사용하여 오늘의 성인 검색 (언어별 캐싱 포함)
    return await getSaintsForDateFromChatGPT(today, locale);
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

/// 오늘의 성인 축일 Provider (ChatGPT 검색, 각 언어별로 하루 한번 검색 후 캐싱)
/// 날짜가 바뀌면 자동으로 새로 로드됨
final todaySaintsProvider = FutureProvider<List<SaintFeastDayModel>>((
  ref,
) async {
  // 날짜 변경 감지를 위해 currentDateStringProvider를 watch
  ref.watch(currentDateStringProvider);

  final testDate = ref.watch(testDateOverrideProvider);
  final date = testDate ?? DateTime.now();
  final locale = ref.watch(localeProvider);
  final languageCode = locale.languageCode;

  // ChatGPT로 성인 검색 (언어별 캐싱 포함, 하루 한번만 검색)
  // GPT가 이미 해당 언어로 이름을 반환하므로 추가 번역 불필요
  final saints = await SaintFeastDayService.getSaintsForDateFromChatGPT(
    date,
    languageCode,
  );

  return saints;
});
