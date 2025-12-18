import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/logger_service.dart';
import '../meditation_guide_provider.dart';

/// 묵상 가이드 캐시 관리 유틸리티
class MeditationGuideCache {
  /// 캐시 키 생성
  static String getCacheKey(MeditationGuideParams params) {
    return '${params.dateKey}_${params.readingType}_${params.language}';
  }

  /// Firestore에서 캐시된 묵상 가이드 가져오기
  /// 같은 날짜에 생성된 캐시가 있으면 반환 (하루에 한 번만 생성)
  static Future<String?> getCachedGuide(
    String cacheKey,
    String dateKey,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('meditation_guides')
          .doc(cacheKey)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final cachedDateKey = data?['dateKey'] as String?;
        final guide = data?['guide'] as String?;

        // 같은 날짜에 생성된 캐시가 있으면 반환
        if (cachedDateKey == dateKey && guide != null && guide.isNotEmpty) {
          AppLogger.debug('[MeditationGuideProvider] 같은 날짜의 캐시 발견: $dateKey');
          // 캐시된 guide에는 이미 참고 말씀이 포함되어 있으므로 그대로 반환
          return guide;
        } else {
          // 날짜가 다르면 캐시 무효 (새로운 날짜의 묵상 가이드 생성 필요)
          AppLogger.debug(
            '[MeditationGuideProvider] 날짜가 다른 캐시 발견 (무시): 캐시=$cachedDateKey, 요청=$dateKey',
          );
          return null;
        }
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[MeditationGuideProvider] 캐시 조회 실패: $cacheKey',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Firestore에 묵상 가이드 캐싱
  static Future<void> cacheGuide(
    String cacheKey,
    String guide,
    MeditationGuideParams params,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('meditation_guides')
          .doc(cacheKey)
          .set({
            'guide': guide,
            'dateKey': params.dateKey,
            'readingType': params.readingType,
            'reference': params.reference,
            'title': params.title,
            'language': params.language,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e, stackTrace) {
      AppLogger.error(
        '[MeditationGuideProvider] 캐시 저장 실패: $cacheKey',
        e,
        stackTrace,
      );
      // 캐시 저장 실패해도 에러를 던지지 않음 (이미 guide는 반환됨)
    }
  }
}

