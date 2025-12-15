import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/logger_service.dart';

/// 다국어 지원 서비스
class LocalizationService {
  LocalizationService._();
  static final LocalizationService instance = LocalizationService._();

  // 번역 데이터 캐시
  final Map<String, Map<String, dynamic>> _cache = {};

  /// 특정 로케일의 번역 데이터 로드
  Future<Map<String, dynamic>> loadTranslations(Locale locale) async {
    final languageCode = locale.languageCode;

    // 캐시 확인
    if (_cache.containsKey(languageCode)) {
      return _cache[languageCode]!;
    }

    try {
      // JSON 파일 로드
      final jsonString = await rootBundle.loadString(
        'assets/l10n/app_$languageCode.json',
      );

      final translations = json.decode(jsonString) as Map<String, dynamic>;

      // 캐시에 저장
      _cache[languageCode] = translations;

      AppLogger.debug('번역 데이터 로드 완료: $languageCode');
      return translations;
    } catch (e) {
      // 로드 실패 시 일본어로 폴백
      AppLogger.warning('번역 데이터 로드 실패 ($languageCode), 일본어로 폴백: $e');

      if (languageCode != 'ja') {
        return await loadTranslations(const Locale('ja', 'JP'));
      }

      // 일본어도 실패하면 빈 맵 반환
      return {};
    }
  }

  /// 번역 키로 값 가져오기
  Future<String?> getTranslation(
    Locale locale,
    String key, {
    Map<String, String>? parameters,
  }) async {
    final translations = await loadTranslations(locale);

    // 키를 점(.)으로 분리하여 중첩된 맵 탐색
    final keys = key.split('.');
    dynamic value = translations;

    for (final k in keys) {
      if (value is Map<String, dynamic>) {
        value = value[k];
      } else {
        return null;
      }
    }

    if (value is String) {
      // 매개변수 치환
      if (parameters != null) {
        String result = value;
        parameters.forEach((key, val) {
          result = result.replaceAll('{$key}', val);
        });
        return result;
      }
      return value;
    }

    return null;
  }

  /// 캐시된 번역 데이터 가져오기 (동기)
  Map<String, dynamic>? getCachedTranslations(String languageCode) {
    return _cache[languageCode];
  }

  /// 캐시 초기화
  void clearCache() {
    _cache.clear();
  }
}
