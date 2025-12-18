import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:credo/core/data/services/cache_service.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await prefs.clear();
  });

  group('CacheService - 기본 캐시 기능', () {
    test('setCache는 데이터를 저장해야 함', () async {
      // Arrange
      final testData = {'key': 'value', 'number': 123};

      // Act
      await CacheService.setCache('test_key', testData);

      // Assert
      final cached = await CacheService.getCache<Map<String, dynamic>>(
        'test_key',
        (json) => json,
      );
      expect(cached, isNotNull);
      expect(cached?['key'], 'value');
      expect(cached?['number'], 123);
    });

    test('getCache는 만료되지 않은 캐시를 반환해야 함', () async {
      // Arrange
      final testData = {'key': 'value'};
      await CacheService.setCache(
        'test_key',
        testData,
        expiration: const Duration(days: 1),
      );

      // Act
      final cached = await CacheService.getCache<Map<String, dynamic>>(
        'test_key',
        (json) => json,
      );

      // Assert
      expect(cached, isNotNull);
      expect(cached?['key'], 'value');
    });

    test('getCache는 만료된 캐시를 null로 반환해야 함', () async {
      // Arrange
      final testData = {'key': 'value'};
      await CacheService.setCache(
        'test_key',
        testData,
        expiration: const Duration(seconds: -1), // 이미 만료됨
      );

      // Act
      final cached = await CacheService.getCache<Map<String, dynamic>>(
        'test_key',
        (json) => json,
      );

      // Assert
      expect(cached, isNull);
    });

    test('getCache는 존재하지 않는 캐시를 null로 반환해야 함', () async {
      // Act
      final cached = await CacheService.getCache<Map<String, dynamic>>(
        'non_existent_key',
        (json) => json,
      );

      // Assert
      expect(cached, isNull);
    });

    test('removeCache는 캐시를 삭제해야 함', () async {
      // Arrange
      final testData = {'key': 'value'};
      await CacheService.setCache('test_key', testData);

      // Act
      await CacheService.removeCache('test_key');

      // Assert
      final cached = await CacheService.getCache<Map<String, dynamic>>(
        'test_key',
        (json) => json,
      );
      expect(cached, isNull);
    });

    test('clearAllCache는 모든 캐시를 삭제해야 함', () async {
      // Arrange
      await CacheService.setCache('key1', {'data': 1});
      await CacheService.setCache('key2', {'data': 2});

      // Act
      await CacheService.clearAllCache();

      // Assert
      final cached1 = await CacheService.getCache<Map<String, dynamic>>(
        'key1',
        (json) => json,
      );
      final cached2 = await CacheService.getCache<Map<String, dynamic>>(
        'key2',
        (json) => json,
      );
      expect(cached1, isNull);
      expect(cached2, isNull);
    });
  });

  group('CacheService - 일일 미사 독서 캐싱', () {
    test('cacheDailyMassReading는 데이터를 저장해야 함', () async {
      // Arrange
      final readingData = {
        'firstReading': 'First reading text',
        'gospel': 'Gospel text',
      };

      // Act
      await CacheService.cacheDailyMassReading('2024-01-01', readingData);

      // Assert
      final cached = await CacheService.getCachedDailyMassReading('2024-01-01');
      expect(cached, isNotNull);
      expect(cached?['firstReading'], 'First reading text');
      expect(cached?['gospel'], 'Gospel text');
    });

    test('getCachedDailyMassReading는 저장된 데이터를 반환해야 함', () async {
      // Arrange
      final readingData = {'gospel': 'Gospel text'};
      await CacheService.cacheDailyMassReading('2024-01-01', readingData);

      // Act
      final cached = await CacheService.getCachedDailyMassReading('2024-01-01');

      // Assert
      expect(cached, isNotNull);
      expect(cached?['gospel'], 'Gospel text');
    });
  });

  group('CacheService - 교회 정보 캐싱', () {
    test('cacheParishInfo는 교회 정보를 저장해야 함', () async {
      // Arrange
      final parishData = {
        'name': 'Test Parish',
        'address': 'Test Address',
      };

      // Act
      await CacheService.cacheParishInfo('parish1', parishData);

      // Assert
      final cached = await CacheService.getCachedParishInfo('parish1');
      expect(cached, isNotNull);
      expect(cached?['name'], 'Test Parish');
      expect(cached?['address'], 'Test Address');
    });

    test('cacheAllParishes는 모든 교회 정보를 저장해야 함', () async {
      // Arrange
      final parishesData = {
        'region1': [
          {'id': 'parish1', 'name': 'Parish 1'},
          {'id': 'parish2', 'name': 'Parish 2'},
        ],
        'region2': [
          {'id': 'parish3', 'name': 'Parish 3'},
        ],
      };

      // Act
      await CacheService.cacheAllParishes(parishesData);

      // Assert
      final cached = await CacheService.getCachedAllParishes();
      expect(cached, isNotNull);
      expect(cached?['region1'], isA<List<Map<String, dynamic>>>());
      expect(cached?['region1']?.length, 2);
      expect(cached?['region2']?.length, 1);
    });
  });

  group('CacheService - 게시글 캐싱', () {
    test('cachePost는 게시글을 저장해야 함', () async {
      // Arrange
      final postData = {
        'id': 'post1',
        'title': 'Test Post',
        'body': 'Test Body',
      };

      // Act
      await CacheService.cachePost('post1', postData);

      // Assert
      final cached = await CacheService.getCachedPost('post1');
      expect(cached, isNotNull);
      expect(cached?['id'], 'post1');
      expect(cached?['title'], 'Test Post');
    });

    test('cachePostList는 게시글 목록을 저장해야 함', () async {
      // Arrange
      final postsData = [
        {'id': 'post1', 'title': 'Post 1'},
        {'id': 'post2', 'title': 'Post 2'},
      ];

      // Act
      await CacheService.cachePostList('parish_123', postsData);

      // Assert
      final cached = await CacheService.getCachedPostList('parish_123');
      expect(cached, isNotNull);
      expect(cached?.length, 2);
      expect(cached?[0]['id'], 'post1');
      expect(cached?[1]['id'], 'post2');
    });

    test('markPostAsRead는 게시글을 읽음으로 표시해야 함', () async {
      // Act
      await CacheService.markPostAsRead('post1');
      await CacheService.markPostAsRead('post2');

      // Assert
      final readPosts = await CacheService.getReadPostIds();
      expect(readPosts, contains('post1'));
      expect(readPosts, contains('post2'));
    });

    test('getReadPostIds는 읽은 게시글 목록을 반환해야 함', () async {
      // Arrange
      await CacheService.markPostAsRead('post1');
      await CacheService.markPostAsRead('post2');

      // Act
      final readPosts = await CacheService.getReadPostIds();

      // Assert
      expect(readPosts.length, 2);
      expect(readPosts, contains('post1'));
      expect(readPosts, contains('post2'));
    });

    test('getReadPostIds는 중복 게시글을 제거해야 함', () async {
      // Arrange
      await CacheService.markPostAsRead('post1');
      await CacheService.markPostAsRead('post1'); // 중복

      // Act
      final readPosts = await CacheService.getReadPostIds();

      // Assert
      expect(readPosts.length, 1);
      expect(readPosts, contains('post1'));
    });
  });
}

