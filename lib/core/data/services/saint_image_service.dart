import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saint_feast_day_model.dart';
import '../../services/logger_service.dart';

/// 성인 이미지 서비스
/// Wikipedia API를 사용하여 성인 이미지를 검색합니다.
class SaintImageService {
  final Dio _dio;

  SaintImageService({Dio? dio}) : _dio = dio ?? Dio();

  /// 이미지 URL이 유효한지 확인 (HEAD 요청으로 빠르게 확인)
  Future<bool> validateImageUrl(String url) async {
    try {
      final response = await _dio.head(
        url,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );
      final isValid = response.statusCode != null && response.statusCode! < 400;
      AppLogger.debug(
        '[SaintImageService] URL 유효성 검사: $url -> ${isValid ? "유효" : "유효하지 않음"}',
      );
      return isValid;
    } catch (e) {
      AppLogger.debug('[SaintImageService] URL 유효성 검사 실패: $url - $e');
      return false;
    }
  }

  /// 성인 이미지 URL 검색
  ///
  /// [saint] 성인 모델
  /// [languageCode] 언어 코드
  ///
  /// 반환: 이미지 URL (없으면 null)
  Future<String?> searchSaintImage(
    SaintFeastDayModel saint,
    String languageCode,
  ) async {
    try {
      AppLogger.debug(
        '[SaintImageService] 이미지 검색 시작: ${saint.name} (${saint.nameEn ?? saint.name})',
      );

      // 캐시 키 생성
      final cacheKey =
          'saint_image_${saint.month}_${saint.day}_${saint.name.hashCode}';

      // SharedPreferences에서 캐시 확인
      final prefs = await SharedPreferences.getInstance();
      final cachedUrl = prefs.getString(cacheKey);

      // 실패한 URL 목록 확인
      final failedUrlsKey = 'failed_saint_image_urls';
      final failedUrlsJson = prefs.getString(failedUrlsKey);
      final failedUrls = failedUrlsJson != null
          ? (jsonDecode(failedUrlsJson) as List<dynamic>)
                .map((e) => e as String)
                .toSet()
          : <String>{};

      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        // 실패한 URL이면 무시하고 재검색
        if (failedUrls.contains(cachedUrl)) {
          AppLogger.debug(
            '[SaintImageService] 캐시된 URL이 실패한 URL 목록에 있음, 재검색: ${saint.name}\nURL: $cachedUrl',
          );
          // 캐시 삭제
          await prefs.remove(cacheKey);
        } else {
          AppLogger.debug(
            '[SaintImageService] 캐시에서 이미지 URL 로드: ${saint.name}\nURL: $cachedUrl',
          );
          return cachedUrl;
        }
      }

      AppLogger.debug('[SaintImageService] 캐시에 없음, 새로 검색 시작: ${saint.name}');

      // 1. Wikipedia API로 이미지 검색 시도 (더 빠르고 안정적)
      final wikipediaUrl = await _getWikipediaImage(saint, languageCode);
      if (wikipediaUrl != null &&
          wikipediaUrl.isNotEmpty &&
          !failedUrls.contains(wikipediaUrl)) {
        // 캐시에 저장
        await prefs.setString(cacheKey, wikipediaUrl);
        AppLogger.debug(
          '[SaintImageService] Wikipedia에서 이미지 찾음: ${saint.name}',
        );
        return wikipediaUrl;
      }

      // 2. 여러 Wikipedia 언어 버전 시도
      final multiLangUrl = await _getWikipediaImageMultiLang(saint);
      if (multiLangUrl != null &&
          multiLangUrl.isNotEmpty &&
          !failedUrls.contains(multiLangUrl)) {
        // 캐시에 저장
        await prefs.setString(cacheKey, multiLangUrl);
        AppLogger.debug(
          '[SaintImageService] Wikipedia (다국어)에서 이미지 찾음: ${saint.name}',
        );
        return multiLangUrl;
      }

      // 3. GPT 이미지 URL 검색은 비활성화
      // GPT는 존재하지 않는 URL을 생성하는 경향이 있어서 404 에러가 발생함
      // Wikipedia API에서 이미지를 찾지 못하면 null 반환

      AppLogger.debug(
        '[SaintImageService] 이미지를 찾을 수 없음: ${saint.name} (${saint.nameEn ?? saint.name})',
      );
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[SaintImageService] 이미지 검색 실패: ${saint.name}',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Wikipedia API를 사용하여 성인 이미지 가져오기
  Future<String?> _getWikipediaImage(
    SaintFeastDayModel saint,
    String languageCode,
  ) async {
    try {
      final englishName = saint.nameEn ?? saint.name;
      if (englishName.isEmpty) return null;

      // URL 인코딩
      final encodedName = Uri.encodeComponent(englishName);

      // Wikipedia API로 이미지 검색
      final response = await _dio.get(
        'https://en.wikipedia.org/api/rest_v1/page/summary/$encodedName',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final thumbnail = data['thumbnail'] as Map<String, dynamic>?;
        final imageUrl = thumbnail?['source'] as String?;

        if (imageUrl != null) {
          AppLogger.debug(
            '[SaintImageService] Wikipedia에서 이미지 찾음: $englishName',
          );
          return imageUrl;
        }
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        '[SaintImageService] Wikipedia 이미지 검색 실패: ${saint.name}',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// 여러 Wikipedia 언어 버전에서 이미지 검색
  Future<String?> _getWikipediaImageMultiLang(SaintFeastDayModel saint) async {
    // 여러 언어 버전 시도
    final names = [
      saint.nameEn,
      saint.nameKo,
      saint.nameZh,
      saint.nameVi,
      saint.nameEs,
      saint.namePt,
      saint.name,
    ].where((name) => name != null && name.isNotEmpty).toList();

    for (final name in names) {
      try {
        final encodedName = Uri.encodeComponent(name!);
        final response = await _dio.get(
          'https://en.wikipedia.org/api/rest_v1/page/summary/$encodedName',
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final thumbnail = data['thumbnail'] as Map<String, dynamic>?;
          final imageUrl = thumbnail?['source'] as String?;

          if (imageUrl != null) {
            AppLogger.debug(
              '[SaintImageService] Wikipedia에서 이미지 찾음 (다국어): $name',
            );
            return imageUrl;
          }
        }
      } catch (e) {
        // 다음 이름 시도
        continue;
      }
    }

    return null;
  }
}
