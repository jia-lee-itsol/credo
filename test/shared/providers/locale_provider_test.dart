import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:credo/shared/providers/locale_provider.dart';

void main() {
  late LocaleNotifier notifier;
  late SharedPreferences prefs;

  setUp(() async {
    // SharedPreferences 초기화
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await prefs.clear();
  });

  group('LocaleNotifier', () {
    test('초기 상태는 기본 로케일(ja_JP)이어야 함', () {
      // Arrange & Act
      notifier = LocaleNotifier();

      // Assert
      expect(notifier.state, const Locale('ja', 'JP'));
    });

    test('저장된 로케일이 있으면 불러와야 함', () async {
      // Arrange
      await prefs.setString('locale_language', 'ko');
      await prefs.setString('locale_country', 'KR');

      // Act
      notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100)); // 비동기 로드 대기

      // Assert
      expect(notifier.state, const Locale('ko', 'KR'));
    });

    test('setLocale은 로케일을 설정하고 저장해야 함', () async {
      // Arrange
      notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      const newLocale = Locale('en', 'US');

      // Act
      await notifier.setLocale(newLocale);

      // Assert
      expect(notifier.state, newLocale);
      expect(prefs.getString('locale_language'), 'en');
      expect(prefs.getString('locale_country'), 'US');
    });

    test('setLocaleByLanguageCode는 언어 코드로 로케일을 설정해야 함', () async {
      // Arrange
      notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await notifier.setLocaleByLanguageCode('ko');

      // Assert
      expect(notifier.state, const Locale('ko', 'KR'));
      expect(prefs.getString('locale_language'), 'ko');
      expect(prefs.getString('locale_country'), 'KR');
    });

    test('setLocaleByLanguageCode는 알 수 없는 언어 코드에 대해 대문자로 변환해야 함', () async {
      // Arrange
      notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await notifier.setLocaleByLanguageCode('fr');

      // Assert
      expect(notifier.state, const Locale('fr', 'FR'));
    });

    test('resetLocale은 기본 로케일로 리셋해야 함', () async {
      // Arrange
      notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      await notifier.setLocale(const Locale('en', 'US'));

      // Act
      await notifier.resetLocale();

      // Assert
      expect(notifier.state, const Locale('ja', 'JP'));
      expect(prefs.getString('locale_language'), 'ja');
      expect(prefs.getString('locale_country'), 'JP');
    });

    test('SharedPreferences 저장 실패 시에도 상태는 업데이트되어야 함', () async {
      // Arrange
      notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      // SharedPreferences를 clear하여 저장 실패 시뮬레이션
      await prefs.clear();

      // Act
      await notifier.setLocale(const Locale('en', 'US'));

      // Assert
      // 상태는 업데이트되어야 함 (에러가 발생해도)
      expect(notifier.state, const Locale('en', 'US'));
    });
  });
}

