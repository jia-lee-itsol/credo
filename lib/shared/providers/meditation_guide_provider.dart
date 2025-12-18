import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/services/openai_service.dart';
import '../../core/services/logger_service.dart';
import 'utils/meditation_guide_cache.dart';
import 'utils/meditation_guide_formatter.dart';
import 'utils/meditation_guide_defaults.dart';

/// 묵상 가이드 Provider
/// 날짜, 독서 타입, 언어별로 묵상 가이드를 생성하고 Firestore에 캐싱합니다.
final meditationGuideProvider = FutureProvider.family<String, MeditationGuideParams>((
  ref,
  params,
) async {
  // Firestore에서 캐시 확인 (하루에 한 번만 생성, 나머지는 캐싱)
  final cacheKey = MeditationGuideCache.getCacheKey(params);
  try {
    final cachedGuide = await MeditationGuideCache.getCachedGuide(
      cacheKey,
      params.dateKey,
    );
    if (cachedGuide != null) {
      AppLogger.debug(
        '[MeditationGuideProvider] 캐시에서 묵상 가이드 로드: ${params.readingType} (${params.language})',
      );
      // 캐시된 guide에 참고 말씀이 없으면 추가
      final guideWithReference = MeditationGuideFormatter.ensureReferenceInGuide(
        cachedGuide,
        params.reference,
        params.language,
      );
      return guideWithReference;
    }
  } catch (e) {
    // 캐시 조회 실패해도 계속 진행 (GPT로 생성)
    AppLogger.warning(
      '[MeditationGuideProvider] 캐시 조회 실패, GPT로 생성 진행: ${params.readingType} (${params.language})',
    );
  }

  // 캐시가 없으면 GPT로 생성 (하루에 한 번만)
  try {
    AppLogger.debug(
      '[MeditationGuideProvider] GPT로 묵상 가이드 생성 시작: ${params.readingType} (${params.language})',
    );
    final openAIService = OpenAIService();
    final guide = await openAIService.generateMeditationGuide(
      readingType: params.readingType,
      reference: params.reference,
      title: params.title,
      language: params.language,
    );

    // 묵상 가이드 하단에 참고 말씀 추가
    final guideWithReference = MeditationGuideFormatter.addReferenceToGuide(
      guide,
      params.reference,
      params.language,
    );

    // Firestore에 캐싱 (에러가 발생해도 guide는 반환)
    try {
      await MeditationGuideCache.cacheGuide(cacheKey, guideWithReference, params);
      AppLogger.debug(
        '[MeditationGuideProvider] 묵상 가이드 생성 및 캐싱 완료: ${params.readingType} (${params.language})',
      );
    } catch (e) {
      // 캐싱 실패해도 guide는 반환
      AppLogger.warning(
        '[MeditationGuideProvider] 캐싱 실패했지만 guide는 반환: ${params.readingType} (${params.language})',
      );
    }

    return guideWithReference;
  } catch (e, stackTrace) {
    AppLogger.error(
      '[MeditationGuideProvider] 묵상 가이드 생성 실패: ${params.readingType} (${params.language})',
      e,
      stackTrace,
    );
    // 에러 발생 시 기본 메시지 반환 (참고 말씀 추가)
    final defaultGuide = MeditationGuideDefaults.getDefaultMeditationGuide(
      params.language,
    );
    return MeditationGuideFormatter.addReferenceToGuide(
      defaultGuide,
      params.reference,
      params.language,
    );
  }
});

/// 묵상 가이드 파라미터
class MeditationGuideParams {
  final String dateKey; // YYYY-MM-DD 형식
  final String
  readingType; // 'firstReading', 'psalm', 'secondReading', 'gospel'
  final String reference; // 성경 구절 참조
  final String? title; // 독서 제목
  final String language; // 언어 코드: 'ja', 'ko', 'en' 등

  const MeditationGuideParams({
    required this.dateKey,
    required this.readingType,
    required this.reference,
    this.title,
    required this.language,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationGuideParams &&
          runtimeType == other.runtimeType &&
          dateKey == other.dateKey &&
          readingType == other.readingType &&
          reference == other.reference &&
          title == other.title &&
          language == other.language;

  @override
  int get hashCode =>
      dateKey.hashCode ^
      readingType.hashCode ^
      reference.hashCode ^
      (title?.hashCode ?? 0) ^
      language.hashCode;
}
