import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/data/services/localization_service.dart';

const String _localeLanguageKey = 'locale_language';
const String _localeCountryKey = 'locale_country';
const String _defaultLanguage = 'ja';
const String _defaultCountry = 'JP';

/// 로케일 Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale(_defaultLanguage, _defaultCountry)) {
    _loadLocale();
  }

  /// 저장된 로케일 불러오기
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString(_localeLanguageKey) ?? _defaultLanguage;
      final country = prefs.getString(_localeCountryKey) ?? _defaultCountry;
      final loadedLocale = Locale(language, country);
      state = loadedLocale;

      // 번역 데이터 미리 로드
      try {
        await LocalizationService.instance.loadTranslations(loadedLocale);
      } catch (e) {
        // 번역 데이터 로드 실패 시 무시 (나중에 필요할 때 로드됨)
      }

      // 날짜 포맷 로케일 초기화
      try {
        await initializeDateFormatting(language, country);
      } catch (e) {
        // 날짜 포맷 초기화 실패 시 무시
      }
    } catch (e) {
      // 에러 발생 시 기본값 사용
      state = const Locale(_defaultLanguage, _defaultCountry);
    }
  }

  /// 로케일 설정
  Future<void> setLocale(Locale locale) async {
    try {
      state = locale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeLanguageKey, locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString(_localeCountryKey, locale.countryCode!);
      } else {
        await prefs.remove(_localeCountryKey);
      }

      // 번역 데이터 미리 로드
      try {
        await LocalizationService.instance.loadTranslations(locale);
      } catch (e) {
        // 번역 데이터 로드 실패 시 무시 (나중에 필요할 때 로드됨)
      }

      // 날짜 포맷 로케일 동적 업데이트
      try {
        await initializeDateFormatting(locale.languageCode, locale.countryCode);
      } catch (e) {
        // 날짜 포맷 초기화 실패 시 무시 (기존 포맷 유지)
      }
    } catch (e) {
      // 에러 발생 시에도 상태는 업데이트 (UI는 변경되지만 저장 실패)
      state = locale;
    }
  }

  /// 언어 코드로 로케일 설정
  Future<void> setLocaleByLanguageCode(String languageCode) async {
    // 언어 코드에 맞는 기본 국가 코드 매핑
    final countryMap = <String, String>{
      'ja': 'JP',
      'en': 'US',
      'ko': 'KR',
      'zh': 'CN',
      'vi': 'VN',
      'es': 'ES',
      'pt': 'PT',
    };

    final countryCode = countryMap[languageCode] ?? languageCode.toUpperCase();
    await setLocale(Locale(languageCode, countryCode));
  }

  /// 기본 로케일로 리셋
  Future<void> resetLocale() async {
    await setLocale(const Locale(_defaultLanguage, _defaultCountry));
  }
}
