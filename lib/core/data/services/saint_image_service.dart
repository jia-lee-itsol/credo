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

      // 3. Wikimedia Commons에서 icon/painting/artwork 키워드로 검색
      final commonsUrl = await _getWikimediaCommonsImage(saint);
      if (commonsUrl != null &&
          commonsUrl.isNotEmpty &&
          !failedUrls.contains(commonsUrl)) {
        // 캐시에 저장
        await prefs.setString(cacheKey, commonsUrl);
        AppLogger.debug(
          '[SaintImageService] Wikimedia Commons에서 이미지 찾음: ${saint.name}',
        );
        return commonsUrl;
      }

      // 4. GPT 이미지 URL 검색은 비활성화
      // GPT는 존재하지 않는 URL을 생성하는 경향이 있어서 404 에러가 발생함

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

      // 다양한 검색어 시도
      final searchTerms = _generateSearchTerms(englishName);

      for (final searchTerm in searchTerms) {
        final encodedName = Uri.encodeComponent(searchTerm);

        try {
          final response = await _dio.get(
            'https://en.wikipedia.org/api/rest_v1/page/summary/$encodedName',
          );

          if (response.statusCode == 200) {
            final data = response.data as Map<String, dynamic>;
            final thumbnail = data['thumbnail'] as Map<String, dynamic>?;
            final imageUrl = thumbnail?['source'] as String?;

            if (imageUrl != null) {
              AppLogger.debug(
                '[SaintImageService] Wikipedia에서 이미지 찾음: $searchTerm',
              );
              return imageUrl;
            }
          }
        } catch (e) {
          // 다음 검색어 시도
          continue;
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

  /// 검색어 변형 생성
  List<String> _generateSearchTerms(String name) {
    final terms = <String>[];

    // St. -> Saint 변환, 그리고 Saint/St. 제거 버전도 생성
    final normalized = name
        .replaceAll('St. ', 'Saint ')
        .replaceAll('St ', 'Saint ');

    // 원본 이름
    terms.add(name);
    if (normalized != name) terms.add(normalized);

    // "Pope Saint X" -> "Pope X"
    if (name.toLowerCase().contains('pope')) {
      final withoutSaint = normalized
          .replaceAll('Saint ', '')
          .replaceAll('saint ', '')
          .replaceAll('성 ', '');
      if (!terms.contains(withoutSaint)) terms.add(withoutSaint);

      // Pope_X (Wikipedia 형식)
      final wikipediaFormat = withoutSaint.replaceAll(' ', '_');
      if (!terms.contains(wikipediaFormat)) terms.add(wikipediaFormat);
    }

    // "Saint X" -> "X (saint)", "X"
    if (normalized.toLowerCase().contains('saint')) {
      final withoutSaint = normalized
          .replaceAll('Saint ', '')
          .replaceAll('saint ', '')
          .replaceAll('Pope ', '')
          .replaceAll('pope ', '');
      final saintFormat = '$withoutSaint (saint)';
      if (!terms.contains(saintFormat)) terms.add(saintFormat);
      if (!terms.contains(withoutSaint)) terms.add(withoutSaint);
    }

    // 공백을 언더스코어로 변환 (Wikipedia URL 형식)
    final underscoreFormat = name.replaceAll(' ', '_');
    if (!terms.contains(underscoreFormat)) terms.add(underscoreFormat);

    AppLogger.debug('[SaintImageService] 검색어 목록: $terms');

    return terms;
  }

  /// 여러 Wikipedia 언어 버전에서 이미지 검색
  Future<String?> _getWikipediaImageMultiLang(SaintFeastDayModel saint) async {
    // 언어별 이름과 해당 Wikipedia 언어 코드 매핑
    // 성인은 주로 유럽 출신이므로 유럽 언어 Wikipedia도 포함
    final languageSearchList = <_WikiSearchEntry>[
      // 영어 우선 검색
      _WikiSearchEntry('en', saint.nameEn),
      _WikiSearchEntry('en', saint.name),
      // 라틴어 (가톨릭 공식 언어)
      _WikiSearchEntry('la', saint.nameEn),
      // 이탈리아어 (바티칸/로마 소재)
      _WikiSearchEntry('it', saint.nameEn),
      _WikiSearchEntry('it', saint.name),
      // 프랑스어
      _WikiSearchEntry('fr', saint.nameEn),
      _WikiSearchEntry('fr', saint.name),
      // 스페인어
      _WikiSearchEntry('es', saint.nameEs),
      _WikiSearchEntry('es', saint.nameEn),
      // 포르투갈어
      _WikiSearchEntry('pt', saint.namePt),
      _WikiSearchEntry('pt', saint.nameEn),
      // 독일어
      _WikiSearchEntry('de', saint.nameEn),
      // 폴란드어 (많은 성인 배출)
      _WikiSearchEntry('pl', saint.nameEn),
      // 한국어
      _WikiSearchEntry('ko', saint.nameKo),
      _WikiSearchEntry('ko', saint.name),
      // 일본어 (name 필드가 기본 일본어 이름)
      _WikiSearchEntry('ja', saint.name),
      // 중국어
      _WikiSearchEntry('zh', saint.nameZh),
      // 베트남어
      _WikiSearchEntry('vi', saint.nameVi),
    ];

    // 중복 제거된 검색 목록 생성
    final searchedSet = <String>{};

    for (final entry in languageSearchList) {
      if (entry.name == null || entry.name!.isEmpty) continue;

      final searchKey = '${entry.langCode}:${entry.name}';
      if (searchedSet.contains(searchKey)) continue;
      searchedSet.add(searchKey);

      // 다양한 검색어 시도
      final searchTerms = _generateSearchTermsForLanguage(entry.name!, entry.langCode);

      for (final searchTerm in searchTerms) {
        try {
          final encodedName = Uri.encodeComponent(searchTerm);
          final response = await _dio.get(
            'https://${entry.langCode}.wikipedia.org/api/rest_v1/page/summary/$encodedName',
          );

          if (response.statusCode == 200) {
            final data = response.data as Map<String, dynamic>;
            final thumbnail = data['thumbnail'] as Map<String, dynamic>?;
            final imageUrl = thumbnail?['source'] as String?;

            if (imageUrl != null) {
              AppLogger.debug(
                '[SaintImageService] Wikipedia에서 이미지 찾음 (${entry.langCode}): $searchTerm',
              );
              return imageUrl;
            }
          }
        } catch (e) {
          // 다음 검색어 시도
          continue;
        }
      }
    }

    return null;
  }

  /// 언어별 검색어 변형 생성
  List<String> _generateSearchTermsForLanguage(String name, String langCode) {
    final terms = <String>[];

    // 원본 이름
    terms.add(name);

    // 공백을 언더스코어로 변환 (Wikipedia URL 형식)
    final underscoreFormat = name.replaceAll(' ', '_');
    if (!terms.contains(underscoreFormat)) terms.add(underscoreFormat);

    // 영어/라틴어 계열 언어의 경우 Saint 관련 변환
    if (['en', 'la', 'it', 'fr', 'es', 'pt', 'de', 'pl'].contains(langCode)) {
      // 언어별 "Saint" 키워드 변환
      final saintVariations = _getSaintVariations(langCode);

      for (final saintWord in saintVariations) {
        // "Saint X" -> "X (saint)" 형식
        if (name.toLowerCase().contains(saintWord.toLowerCase())) {
          final withoutSaint = name
              .replaceAll(RegExp('$saintWord ', caseSensitive: false), '')
              .replaceAll(RegExp('$saintWord', caseSensitive: false), '')
              .trim();

          if (withoutSaint.isNotEmpty) {
            // "(saint)" 형식으로 검색
            final saintFormat = '$withoutSaint (saint)';
            if (!terms.contains(saintFormat)) terms.add(saintFormat);

            // 이름만으로 검색
            if (!terms.contains(withoutSaint)) terms.add(withoutSaint);

            // 언더스코어 형식
            final underscoreWithoutSaint = withoutSaint.replaceAll(' ', '_');
            if (!terms.contains(underscoreWithoutSaint)) {
              terms.add(underscoreWithoutSaint);
            }
          }
        }
      }

      // St. -> Saint 변환
      if (name.contains('St.') || name.contains('St ')) {
        final normalized = name
            .replaceAll('St. ', 'Saint ')
            .replaceAll('St ', 'Saint ');
        if (!terms.contains(normalized)) terms.add(normalized);
      }
    }

    // 한국어의 경우 "성" 제거
    if (langCode == 'ko' && name.startsWith('성 ')) {
      final withoutSaint = name.replaceFirst('성 ', '');
      if (!terms.contains(withoutSaint)) terms.add(withoutSaint);
    }

    // 일본어의 경우 "聖" 제거
    if (langCode == 'ja' && name.startsWith('聖')) {
      final withoutSaint = name.replaceFirst('聖', '');
      if (!terms.contains(withoutSaint)) terms.add(withoutSaint);
    }

    // 중국어의 경우 "圣"/"聖" 제거
    if (langCode == 'zh') {
      if (name.startsWith('圣')) {
        final withoutSaint = name.replaceFirst('圣', '');
        if (!terms.contains(withoutSaint)) terms.add(withoutSaint);
      }
      if (name.startsWith('聖')) {
        final withoutSaint = name.replaceFirst('聖', '');
        if (!terms.contains(withoutSaint)) terms.add(withoutSaint);
      }
    }

    return terms;
  }

  /// 언어별 "Saint" 키워드 목록
  List<String> _getSaintVariations(String langCode) {
    switch (langCode) {
      case 'en':
        return ['Saint', 'St.', 'St'];
      case 'la':
        return ['Sanctus', 'Sancta', 'S.'];
      case 'it':
        return ['San', 'Santa', 'Santo', 'Sant\''];
      case 'fr':
        return ['Saint', 'Sainte', 'St'];
      case 'es':
        return ['San', 'Santa', 'Santo'];
      case 'pt':
        return ['São', 'Santa', 'Santo'];
      case 'de':
        return ['Heiliger', 'Heilige', 'Hl.'];
      case 'pl':
        return ['Święty', 'Święta', 'Św.'];
      default:
        return ['Saint', 'St.', 'St'];
    }
  }

  /// Wikimedia Commons에서 성인 이미지 검색 (icon, painting, artwork 키워드 사용)
  Future<String?> _getWikimediaCommonsImage(SaintFeastDayModel saint) async {
    final englishName = saint.nameEn ?? saint.name;
    if (englishName.isEmpty) return null;

    // Saint 접두사 제거한 이름 추출
    final cleanName = englishName
        .replaceAll(RegExp(r'^Saint\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'^St\.\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^St\s+', caseSensitive: false), '')
        .trim();

    // 검색 키워드 조합
    final searchQueries = [
      'Saint $cleanName icon',
      'Saint $cleanName painting',
      'Saint $cleanName artwork',
      'Saint $cleanName',
      '$cleanName saint icon',
      '$cleanName saint painting',
      '$cleanName icon orthodox',
      '$cleanName catholic saint',
      englishName,
    ];

    for (final query in searchQueries) {
      try {
        // Wikimedia Commons API 검색
        final response = await _dio.get(
          'https://commons.wikimedia.org/w/api.php',
          queryParameters: {
            'action': 'query',
            'generator': 'search',
            'gsrsearch': query,
            'gsrnamespace': '6', // File namespace
            'gsrlimit': '5',
            'prop': 'imageinfo',
            'iiprop': 'url|mime',
            'iiurlwidth': '400', // 썸네일 크기
            'format': 'json',
          },
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final queryResult = data['query'] as Map<String, dynamic>?;
          final pages = queryResult?['pages'] as Map<String, dynamic>?;

          if (pages != null && pages.isNotEmpty) {
            // 이미지 파일만 필터링
            for (final pageData in pages.values) {
              final page = pageData as Map<String, dynamic>;
              final imageInfo = page['imageinfo'] as List<dynamic>?;
              
              if (imageInfo != null && imageInfo.isNotEmpty) {
                final info = imageInfo[0] as Map<String, dynamic>;
                final mime = info['mime'] as String?;
                
                // 이미지 파일인지 확인 (svg 제외 - 렌더링 문제)
                if (mime != null &&
                    (mime.startsWith('image/jpeg') ||
                        mime.startsWith('image/png') ||
                        mime.startsWith('image/gif') ||
                        mime.startsWith('image/webp'))) {
                  // 썸네일 URL 사용 (더 빠른 로딩)
                  final thumbUrl = info['thumburl'] as String?;
                  final originalUrl = info['url'] as String?;
                  final imageUrl = thumbUrl ?? originalUrl;

                  if (imageUrl != null && imageUrl.isNotEmpty) {
                    AppLogger.debug(
                      '[SaintImageService] Wikimedia Commons에서 이미지 찾음: $query\nURL: $imageUrl',
                    );
                    return imageUrl;
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        // 다음 검색어 시도
        continue;
      }
    }

    return null;
  }
}

/// Wikipedia 검색 엔트리
class _WikiSearchEntry {
  final String langCode;
  final String? name;

  _WikiSearchEntry(this.langCode, this.name);
}
