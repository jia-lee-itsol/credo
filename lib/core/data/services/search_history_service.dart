import 'package:shared_preferences/shared_preferences.dart';

/// 검색 히스토리 서비스
class SearchHistoryService {
  static const String _postSearchHistoryKey = 'post_search_history';
  static const String _parishSearchHistoryKey = 'parish_search_history';
  static const int _maxHistoryCount = 10; // 최대 히스토리 개수

  /// 게시글 검색 히스토리 저장
  static Future<void> savePostSearchHistory(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_postSearchHistoryKey) ?? [];

      // 중복 제거 (같은 검색어가 있으면 제거)
      history.remove(query.trim());

      // 맨 앞에 추가
      history.insert(0, query.trim());

      // 최대 개수 제한
      if (history.length > _maxHistoryCount) {
        history.removeRange(_maxHistoryCount, history.length);
      }

      await prefs.setStringList(_postSearchHistoryKey, history);
    } catch (e) {
      // 에러 무시
    }
  }

  /// 게시글 검색 히스토리 조회
  static Future<List<String>> getPostSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_postSearchHistoryKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// 게시글 검색 히스토리 삭제
  static Future<void> clearPostSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_postSearchHistoryKey);
    } catch (e) {
      // 에러 무시
    }
  }

  /// 특정 검색어 삭제
  static Future<void> removePostSearchHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_postSearchHistoryKey) ?? [];
      history.remove(query.trim());
      await prefs.setStringList(_postSearchHistoryKey, history);
    } catch (e) {
      // 에러 무시
    }
  }

  /// 성당 검색 히스토리 저장
  static Future<void> saveParishSearchHistory(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_parishSearchHistoryKey) ?? [];

      // 중복 제거
      history.remove(query.trim());

      // 맨 앞에 추가
      history.insert(0, query.trim());

      // 최대 개수 제한
      if (history.length > _maxHistoryCount) {
        history.removeRange(_maxHistoryCount, history.length);
      }

      await prefs.setStringList(_parishSearchHistoryKey, history);
    } catch (e) {
      // 에러 무시
    }
  }

  /// 성당 검색 히스토리 조회
  static Future<List<String>> getParishSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_parishSearchHistoryKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// 성당 검색 히스토리 삭제
  static Future<void> clearParishSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_parishSearchHistoryKey);
    } catch (e) {
      // 에러 무시
    }
  }

  /// 특정 검색어 삭제
  static Future<void> removeParishSearchHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_parishSearchHistoryKey) ?? [];
      history.remove(query.trim());
      await prefs.setStringList(_parishSearchHistoryKey, history);
    } catch (e) {
      // 에러 무시
    }
  }
}
