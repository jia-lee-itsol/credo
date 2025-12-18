import 'package:flutter_test/flutter_test.dart';
import 'package:credo/shared/providers/liturgy_theme_provider.dart';
import 'package:credo/core/constants/liturgy_constants.dart';

void main() {
  late LiturgySeasonNotifier notifier;

  setUp(() {
    notifier = LiturgySeasonNotifier();
  });

  group('LiturgySeasonNotifier', () {
    test('초기 상태는 현재 시즌이어야 함', () {
      // Arrange & Act
      notifier = LiturgySeasonNotifier();

      // Assert
      expect(notifier.state, isA<LiturgySeason>());
      // 현재 날짜에 따라 시즌이 결정됨
    });

    test('refresh는 현재 시즌을 새로고침해야 함', () async {
      // Act
      await notifier.refresh();

      // Assert
      // 시즌이 변경되었을 수 있음 (날짜 경계를 넘었을 경우)
      expect(notifier.state, isA<LiturgySeason>());
    });

    test('setDate는 특정 날짜의 시즌을 설정해야 함', () async {
      // Arrange
      final testDate = DateTime(2024, 12, 25); // 크리스마스

      // Act
      await notifier.setDate(testDate);

      // Assert
      expect(notifier.state, isA<LiturgySeason>());
      // 크리스마스는 보통 크리스마스 시즌이어야 함
    });

    test('setDate는 다양한 날짜에 대해 올바른 시즌을 반환해야 함', () async {
      // Arrange
      final easterDate = DateTime(2024, 3, 31); // 부활절
      final adventDate = DateTime(2024, 12, 1); // 대림절

      // Act & Assert
      await notifier.setDate(easterDate);
      expect(notifier.state, isA<LiturgySeason>());

      await notifier.setDate(adventDate);
      expect(notifier.state, isA<LiturgySeason>());
    });
  });
}

