import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:credo/shared/providers/font_scale_provider.dart';

void main() {
  late FontScaleNotifier notifier;
  late SharedPreferences prefs;

  setUp(() async {
    // SharedPreferences 초기화
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await prefs.clear();
  });

  group('FontScaleNotifier', () {
    test('초기 상태는 기본 글씨 크기(1.0)이어야 함', () {
      // Arrange & Act
      notifier = FontScaleNotifier();

      // Assert
      expect(notifier.state, 1.0);
    });

    test('저장된 글씨 크기가 있으면 불러와야 함', () async {
      // Arrange
      await prefs.setDouble('font_scale', 1.2);

      // Act
      notifier = FontScaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100)); // 비동기 로드 대기

      // Assert
      expect(notifier.state, 1.2);
    });

    test('setFontScale은 글씨 크기를 설정하고 저장해야 함', () async {
      // Arrange
      notifier = FontScaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await notifier.setFontScale(1.3);

      // Assert
      expect(notifier.state, 1.3);
      expect(prefs.getDouble('font_scale'), 1.3);
    });

    test('setFontScale은 최소값(0.8) 이하로 설정하면 0.8로 제한해야 함', () async {
      // Arrange
      notifier = FontScaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await notifier.setFontScale(0.5);

      // Assert
      expect(notifier.state, 0.8);
      expect(prefs.getDouble('font_scale'), 0.8);
    });

    test('setFontScale은 최대값(1.6) 이상으로 설정하면 1.6으로 제한해야 함', () async {
      // Arrange
      notifier = FontScaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await notifier.setFontScale(2.0);

      // Assert
      expect(notifier.state, 1.6);
      expect(prefs.getDouble('font_scale'), 1.6);
    });

    test('setFontScale은 범위 내 값은 그대로 설정해야 함', () async {
      // Arrange
      notifier = FontScaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await notifier.setFontScale(1.15);

      // Assert
      expect(notifier.state, 1.15);
      expect(prefs.getDouble('font_scale'), 1.15);
    });

    test('resetFontScale은 기본값(1.0)으로 리셋해야 함', () async {
      // Arrange
      notifier = FontScaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      await notifier.setFontScale(1.5);

      // Act
      await notifier.resetFontScale();

      // Assert
      expect(notifier.state, 1.0);
      expect(prefs.getDouble('font_scale'), 1.0);
    });
  });
}

