import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:credo/shared/providers/search_history_provider.dart';
import 'package:credo/core/data/services/search_history_service.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await prefs.clear();
  });

  group('postSearchHistoryProvider', () {
    test('저장된 검색 히스토리를 반환해야 함', () async {
      // Arrange
      await SearchHistoryService.savePostSearchHistory('test query 1');
      await SearchHistoryService.savePostSearchHistory('test query 2');

      // Act
      final container = ProviderContainer();
      final history = await container.read(postSearchHistoryProvider.future);

      // Assert
      expect(history, isNotEmpty);
      expect(history, contains('test query 1'));
      expect(history, contains('test query 2'));

      container.dispose();
    });

    test('히스토리가 없으면 빈 리스트를 반환해야 함', () async {
      // Act
      final container = ProviderContainer();
      final history = await container.read(postSearchHistoryProvider.future);

      // Assert
      expect(history, isEmpty);

      container.dispose();
    });
  });

  group('parishSearchHistoryProvider', () {
    test('저장된 검색 히스토리를 반환해야 함', () async {
      // Arrange
      await SearchHistoryService.saveParishSearchHistory('parish query 1');
      await SearchHistoryService.saveParishSearchHistory('parish query 2');

      // Act
      final container = ProviderContainer();
      final history = await container.read(parishSearchHistoryProvider.future);

      // Assert
      expect(history, isNotEmpty);
      expect(history, contains('parish query 1'));
      expect(history, contains('parish query 2'));

      container.dispose();
    });

    test('히스토리가 없으면 빈 리스트를 반환해야 함', () async {
      // Act
      final container = ProviderContainer();
      final history = await container.read(parishSearchHistoryProvider.future);

      // Assert
      expect(history, isEmpty);

      container.dispose();
    });
  });
}

