import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  group('SearchHistoryService - 게시글 검색 히스토리', () {
    test('savePostSearchHistory는 검색어를 저장해야 함', () async {
      // Act
      await SearchHistoryService.savePostSearchHistory('test query');

      // Assert
      final history = await SearchHistoryService.getPostSearchHistory();
      expect(history, contains('test query'));
      expect(history.first, 'test query');
    });

    test('savePostSearchHistory는 빈 문자열을 저장하지 않아야 함', () async {
      // Act
      await SearchHistoryService.savePostSearchHistory('   ');

      // Assert
      final history = await SearchHistoryService.getPostSearchHistory();
      expect(history, isEmpty);
    });

    test('savePostSearchHistory는 중복 검색어를 제거하고 맨 앞에 추가해야 함', () async {
      // Arrange
      await SearchHistoryService.savePostSearchHistory('query1');
      await SearchHistoryService.savePostSearchHistory('query2');

      // Act
      await SearchHistoryService.savePostSearchHistory('query1');

      // Assert
      final history = await SearchHistoryService.getPostSearchHistory();
      expect(history.length, 2);
      expect(history.first, 'query1');
      expect(history[1], 'query2');
    });

    test('savePostSearchHistory는 최대 10개까지만 저장해야 함', () async {
      // Arrange & Act
      for (int i = 1; i <= 12; i++) {
        await SearchHistoryService.savePostSearchHistory('query$i');
      }

      // Assert
      final history = await SearchHistoryService.getPostSearchHistory();
      expect(history.length, 10);
      expect(history.first, 'query12');
      expect(history.last, 'query3');
    });

    test('getPostSearchHistory는 저장된 히스토리를 반환해야 함', () async {
      // Arrange
      await SearchHistoryService.savePostSearchHistory('query1');
      await SearchHistoryService.savePostSearchHistory('query2');

      // Act
      final history = await SearchHistoryService.getPostSearchHistory();

      // Assert
      expect(history.length, 2);
      expect(history, ['query2', 'query1']);
    });

    test('getPostSearchHistory는 히스토리가 없으면 빈 리스트를 반환해야 함', () async {
      // Act
      final history = await SearchHistoryService.getPostSearchHistory();

      // Assert
      expect(history, isEmpty);
    });

    test('clearPostSearchHistory는 모든 히스토리를 삭제해야 함', () async {
      // Arrange
      await SearchHistoryService.savePostSearchHistory('query1');
      await SearchHistoryService.savePostSearchHistory('query2');

      // Act
      await SearchHistoryService.clearPostSearchHistory();

      // Assert
      final history = await SearchHistoryService.getPostSearchHistory();
      expect(history, isEmpty);
    });

    test('removePostSearchHistory는 특정 검색어를 삭제해야 함', () async {
      // Arrange
      await SearchHistoryService.savePostSearchHistory('query1');
      await SearchHistoryService.savePostSearchHistory('query2');
      await SearchHistoryService.savePostSearchHistory('query3');

      // Act
      await SearchHistoryService.removePostSearchHistory('query2');

      // Assert
      final history = await SearchHistoryService.getPostSearchHistory();
      expect(history.length, 2);
      expect(history, isNot(contains('query2')));
      expect(history, contains('query1'));
      expect(history, contains('query3'));
    });
  });

  group('SearchHistoryService - 성당 검색 히스토리', () {
    test('saveParishSearchHistory는 검색어를 저장해야 함', () async {
      // Act
      await SearchHistoryService.saveParishSearchHistory('parish query');

      // Assert
      final history = await SearchHistoryService.getParishSearchHistory();
      expect(history, contains('parish query'));
      expect(history.first, 'parish query');
    });

    test('saveParishSearchHistory는 빈 문자열을 저장하지 않아야 함', () async {
      // Act
      await SearchHistoryService.saveParishSearchHistory('   ');

      // Assert
      final history = await SearchHistoryService.getParishSearchHistory();
      expect(history, isEmpty);
    });

    test('saveParishSearchHistory는 중복 검색어를 제거하고 맨 앞에 추가해야 함', () async {
      // Arrange
      await SearchHistoryService.saveParishSearchHistory('parish1');
      await SearchHistoryService.saveParishSearchHistory('parish2');

      // Act
      await SearchHistoryService.saveParishSearchHistory('parish1');

      // Assert
      final history = await SearchHistoryService.getParishSearchHistory();
      expect(history.length, 2);
      expect(history.first, 'parish1');
      expect(history[1], 'parish2');
    });

    test('saveParishSearchHistory는 최대 10개까지만 저장해야 함', () async {
      // Arrange & Act
      for (int i = 1; i <= 12; i++) {
        await SearchHistoryService.saveParishSearchHistory('parish$i');
      }

      // Assert
      final history = await SearchHistoryService.getParishSearchHistory();
      expect(history.length, 10);
      expect(history.first, 'parish12');
      expect(history.last, 'parish3');
    });

    test('getParishSearchHistory는 저장된 히스토리를 반환해야 함', () async {
      // Arrange
      await SearchHistoryService.saveParishSearchHistory('parish1');
      await SearchHistoryService.saveParishSearchHistory('parish2');

      // Act
      final history = await SearchHistoryService.getParishSearchHistory();

      // Assert
      expect(history.length, 2);
      expect(history, ['parish2', 'parish1']);
    });

    test('getParishSearchHistory는 히스토리가 없으면 빈 리스트를 반환해야 함', () async {
      // Act
      final history = await SearchHistoryService.getParishSearchHistory();

      // Assert
      expect(history, isEmpty);
    });

    test('clearParishSearchHistory는 모든 히스토리를 삭제해야 함', () async {
      // Arrange
      await SearchHistoryService.saveParishSearchHistory('parish1');
      await SearchHistoryService.saveParishSearchHistory('parish2');

      // Act
      await SearchHistoryService.clearParishSearchHistory();

      // Assert
      final history = await SearchHistoryService.getParishSearchHistory();
      expect(history, isEmpty);
    });

    test('removeParishSearchHistory는 특정 검색어를 삭제해야 함', () async {
      // Arrange
      await SearchHistoryService.saveParishSearchHistory('parish1');
      await SearchHistoryService.saveParishSearchHistory('parish2');
      await SearchHistoryService.saveParishSearchHistory('parish3');

      // Act
      await SearchHistoryService.removeParishSearchHistory('parish2');

      // Assert
      final history = await SearchHistoryService.getParishSearchHistory();
      expect(history.length, 2);
      expect(history, isNot(contains('parish2')));
      expect(history, contains('parish1'));
      expect(history, contains('parish3'));
    });

    test('게시글과 성당 검색 히스토리는 독립적으로 관리되어야 함', () async {
      // Arrange & Act
      await SearchHistoryService.savePostSearchHistory('post query');
      await SearchHistoryService.saveParishSearchHistory('parish query');

      // Assert
      final postHistory = await SearchHistoryService.getPostSearchHistory();
      final parishHistory = await SearchHistoryService.getParishSearchHistory();

      expect(postHistory, contains('post query'));
      expect(postHistory, isNot(contains('parish query')));
      expect(parishHistory, contains('parish query'));
      expect(parishHistory, isNot(contains('post query')));
    });
  });
}

