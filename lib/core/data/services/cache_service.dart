import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/logger_service.dart';

/// 오프라인 캐시 서비스
/// SharedPreferences를 사용하여 데이터를 로컬에 저장하고 관리합니다.
class CacheService {
  static const String _prefix = 'cache_';
  static const String _timestampPrefix = 'cache_timestamp_';
  
  // 캐시 만료 시간 (기본값: 7일)
  static const Duration defaultExpiration = Duration(days: 7);
  
  // 일일 미사 독서 캐시 키
  static const String _dailyMassReadingKey = 'daily_mass_reading';
  
  // 교회 정보 캐시 키
  static const String _parishInfoKey = 'parish_info';
  
  // 게시글 캐시 키
  static const String _postKey = 'post';
  static const String _postListKey = 'post_list';

  /// 데이터를 캐시에 저장
  /// 
  /// [key] 캐시 키
  /// [data] 저장할 데이터 (JSON 직렬화 가능한 객체)
  /// [expiration] 캐시 만료 시간 (기본값: 7일)
  static Future<void> setCache<T>(
    String key,
    T data, {
    Duration expiration = defaultExpiration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_prefix$key';
      final timestampKey = '$_timestampPrefix$key';
      
      // JSON으로 직렬화
      final jsonString = jsonEncode(data);
      
      // 데이터와 타임스탬프 저장
      await prefs.setString(cacheKey, jsonString);
      await prefs.setInt(
        timestampKey,
        DateTime.now().add(expiration).millisecondsSinceEpoch,
      );
      
      AppLogger.debug('캐시 저장 완료: $key');
    } catch (e, stackTrace) {
      AppLogger.error('캐시 저장 실패: $key', e, stackTrace);
    }
  }

  /// 캐시에서 데이터 가져오기
  /// 
  /// [key] 캐시 키
  /// [fromJson] JSON에서 객체로 변환하는 함수
  /// 
  /// 반환: 캐시된 데이터 또는 null (만료되었거나 없을 경우)
  static Future<T?> getCache<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_prefix$key';
      final timestampKey = '$_timestampPrefix$key';
      
      // 타임스탬프 확인
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) {
        AppLogger.debug('캐시 없음: $key');
        return null;
      }
      
      // 만료 확인
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().isAfter(expirationTime)) {
        AppLogger.debug('캐시 만료됨: $key (만료: $expirationTime)');
        // 만료된 캐시 삭제
        await prefs.remove(cacheKey);
        await prefs.remove(timestampKey);
        return null;
      }
      
      // 데이터 가져오기
      final jsonString = prefs.getString(cacheKey);
      if (jsonString == null) {
        AppLogger.debug('캐시 데이터 없음: $key');
        return null;
      }
      
      // JSON 파싱
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = fromJson(json);
      
      AppLogger.debug('캐시에서 로드: $key');
      return data;
    } catch (e, stackTrace) {
      AppLogger.error('캐시 로드 실패: $key', e, stackTrace);
      return null;
    }
  }

  /// 캐시 삭제
  static Future<void> removeCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_prefix$key';
      final timestampKey = '$_timestampPrefix$key';
      
      await prefs.remove(cacheKey);
      await prefs.remove(timestampKey);
      
      AppLogger.debug('캐시 삭제 완료: $key');
    } catch (e, stackTrace) {
      AppLogger.error('캐시 삭제 실패: $key', e, stackTrace);
    }
  }

  /// 모든 캐시 삭제
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_prefix) || key.startsWith(_timestampPrefix)) {
          await prefs.remove(key);
        }
      }
      
      AppLogger.debug('모든 캐시 삭제 완료');
    } catch (e, stackTrace) {
      AppLogger.error('캐시 전체 삭제 실패', e, stackTrace);
    }
  }

  // === 일일 미사 독서 캐싱 ===

  /// 일일 미사 독서 캐시 저장
  static Future<void> cacheDailyMassReading(
    String dateKey,
    Map<String, dynamic> readingData,
  ) async {
    await setCache(
      '$_dailyMassReadingKey$dateKey',
      readingData,
      expiration: const Duration(days: 1), // 하루만 유효
    );
  }

  /// 일일 미사 독서 캐시 가져오기
  static Future<Map<String, dynamic>?> getCachedDailyMassReading(
    String dateKey,
  ) async {
    return await getCache<Map<String, dynamic>>(
      '$_dailyMassReadingKey$dateKey',
      (json) => json,
    );
  }

  // === 교회 정보 캐싱 ===

  /// 교회 정보 캐시 저장
  static Future<void> cacheParishInfo(
    String parishId,
    Map<String, dynamic> parishData,
  ) async {
    await setCache(
      '$_parishInfoKey$parishId',
      parishData,
      expiration: const Duration(days: 30), // 30일 유효
    );
  }

  /// 교회 정보 캐시 가져오기
  static Future<Map<String, dynamic>?> getCachedParishInfo(
    String parishId,
  ) async {
    return await getCache<Map<String, dynamic>>(
      '$_parishInfoKey$parishId',
      (json) => json,
    );
  }

  /// 모든 교회 정보 캐시 저장
  static Future<void> cacheAllParishes(
    Map<String, List<Map<String, dynamic>>> parishesData,
  ) async {
    await setCache(
      '${_parishInfoKey}all',
      parishesData,
      expiration: const Duration(days: 30),
    );
  }

  /// 모든 교회 정보 캐시 가져오기
  static Future<Map<String, List<Map<String, dynamic>>>?> getCachedAllParishes() async {
    return await getCache<Map<String, List<Map<String, dynamic>>>>(
      '${_parishInfoKey}all',
      (json) {
        final result = <String, List<Map<String, dynamic>>>{};
        json.forEach((key, value) {
          result[key] = List<Map<String, dynamic>>.from(
            (value as List).map((e) => Map<String, dynamic>.from(e)),
          );
        });
        return result;
      },
    );
  }

  // === 게시글 캐싱 ===

  /// 게시글 캐시 저장
  static Future<void> cachePost(
    String postId,
    Map<String, dynamic> postData,
  ) async {
    await setCache(
      '$_postKey$postId',
      postData,
      expiration: const Duration(days: 7),
    );
  }

  /// 게시글 캐시 가져오기
  static Future<Map<String, dynamic>?> getCachedPost(String postId) async {
    return await getCache<Map<String, dynamic>>(
      '$_postKey$postId',
      (json) => json,
    );
  }

  /// 게시글 목록 캐시 저장
  static Future<void> cachePostList(
    String listKey, // 예: 'parish_123' 또는 'community'
    List<Map<String, dynamic>> postsData,
  ) async {
    await setCache(
      '$_postListKey$listKey',
      {'posts': postsData},
      expiration: const Duration(hours: 1), // 1시간 유효
    );
  }

  /// 게시글 목록 캐시 가져오기
  static Future<List<Map<String, dynamic>>?> getCachedPostList(
    String listKey,
  ) async {
    final cached = await getCache<Map<String, dynamic>>(
      '$_postListKey$listKey',
      (json) => json,
    );
    
    if (cached == null) return null;
    
    final posts = cached['posts'] as List<dynamic>?;
    if (posts == null) return null;
    
    return posts
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// 읽은 게시글 ID 목록 저장 (오프라인 읽기용)
  static Future<void> markPostAsRead(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readPostsKey = 'read_posts';
      
      final readPostsJson = prefs.getString(readPostsKey);
      final readPosts = readPostsJson != null
          ? (jsonDecode(readPostsJson) as List<dynamic>)
              .map((e) => e as String)
              .toSet()
          : <String>{};
      
      readPosts.add(postId);
      
      await prefs.setString(
        readPostsKey,
        jsonEncode(readPosts.toList()),
      );
    } catch (e, stackTrace) {
      AppLogger.error('읽은 게시글 저장 실패: $postId', e, stackTrace);
    }
  }

  /// 읽은 게시글 ID 목록 가져오기
  static Future<Set<String>> getReadPostIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readPostsKey = 'read_posts';
      
      final readPostsJson = prefs.getString(readPostsKey);
      if (readPostsJson == null) return <String>{};
      
      final readPosts = (jsonDecode(readPostsJson) as List<dynamic>)
          .map((e) => e as String)
          .toSet();
      
      return readPosts;
    } catch (e, stackTrace) {
      AppLogger.error('읽은 게시글 목록 로드 실패', e, stackTrace);
      return <String>{};
    }
  }
}

