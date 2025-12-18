import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../error/failures.dart';
import '../../services/logger_service.dart';

/// 교회 데이터 서비스
class ParishService {
  static Map<String, dynamic>? _cachedData;

  /// 모든 교구 데이터 로드
  static Future<Map<String, List<Map<String, dynamic>>>>
  loadAllParishes() async {
    if (_cachedData != null) {
      return _cachedData! as Map<String, List<Map<String, dynamic>>>;
    }

    try {
      final dioceses = [
        'tokyo',
        'yokohama',
        'saitama',
        'sapporo',
        'sendai',
        'niigata',
        'osaka',
        'nagoya',
        'kyoto',
        'fukuoka',
        'nagasaki',
      ];

      final Map<String, List<Map<String, dynamic>>> allParishes = {};

      for (final diocese in dioceses) {
        try {
          final jsonString = await rootBundle.loadString(
            'assets/data/parishes/$diocese.json',
          );
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final parishes = json['parishes'] as List<dynamic>;
          allParishes[diocese] = parishes
              .map((p) => p as Map<String, dynamic>)
              .toList();
        } catch (e) {
          // 파일이 없거나 에러가 발생하면 빈 리스트
          // 디버깅을 위해 에러 로그 출력 (개발 중에만)
          AppLogger.parish('Failed to load $diocese.json: $e');
          allParishes[diocese] = [];
        }
      }

      _cachedData = allParishes;
      return allParishes;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load parishes data', e, stackTrace);
      throw CacheFailure(message: '교회 데이터를 불러오는데 실패했습니다: $e');
    }
  }

  /// 특정 교구의 교회 목록 가져오기
  static Future<List<Map<String, dynamic>>> getParishesByDiocese(
    String dioceseId,
  ) async {
    final allParishes = await loadAllParishes();
    return allParishes[dioceseId] ?? [];
  }

  /// parishId로 교회 찾기
  /// parishId 형식: "diocese-name" (예: "sapporo-삿포로대성당")
  static Future<Map<String, dynamic>?> getParishById(String parishId) async {
    try {
      // parishId에서 diocese와 name 추출
      final firstDashIndex = parishId.indexOf('-');
      if (firstDashIndex == -1 || firstDashIndex == parishId.length - 1) {
        return null;
      }

      final dioceseId = parishId.substring(0, firstDashIndex);
      final name = parishId.substring(firstDashIndex + 1);

      final parishes = await getParishesByDiocese(dioceseId);

      // 이름으로 교회 찾기
      try {
        return parishes.firstWhere((parish) => parish['name'] == name);
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// 이름으로 교회 검색 (개선된 버전)
  ///
  /// 검색 범위:
  /// - 교회 이름
  /// - 주소 (전체 주소)
  /// - 도도부현 (prefecture)
  /// - 교구 (diocese)
  /// - 지역 (deanery, city 등)
  static Future<List<Map<String, dynamic>>> searchParishes(String query) async {
    final allParishes = await loadAllParishes();
    final queryLower = query.toLowerCase().trim();

    if (queryLower.isEmpty) {
      return [];
    }

    final results = <Map<String, dynamic>>[];

    for (final dioceseParishes in allParishes.values) {
      for (final parish in dioceseParishes) {
        final name = (parish['name'] as String? ?? '').toLowerCase();
        final address = (parish['address'] as String? ?? '').toLowerCase();
        final prefecture = (parish['prefecture'] as String? ?? '')
            .toLowerCase();
        final diocese = (parish['diocese'] as String? ?? '').toLowerCase();
        final deanery = (parish['deanery'] as String? ?? '').toLowerCase();
        final city = (parish['city'] as String? ?? '').toLowerCase();

        // 검색어가 이름, 주소, 도도부현, 교구, 지역 중 하나라도 포함되면 결과에 추가
        if (name.contains(queryLower) ||
            address.contains(queryLower) ||
            prefecture.contains(queryLower) ||
            diocese.contains(queryLower) ||
            deanery.contains(queryLower) ||
            city.contains(queryLower)) {
          results.add(parish);
        }
      }
    }

    // 검색 결과 정렬: 이름 매칭 우선, 그 다음 주소 매칭
    results.sort((a, b) {
      final aName = (a['name'] as String? ?? '').toLowerCase();
      final bName = (b['name'] as String? ?? '').toLowerCase();
      final aAddress = (a['address'] as String? ?? '').toLowerCase();
      final bAddress = (b['address'] as String? ?? '').toLowerCase();

      // 이름이 정확히 일치하거나 시작하는 경우 우선순위 높음
      final aNameStarts = aName.startsWith(queryLower);
      final bNameStarts = bName.startsWith(queryLower);
      if (aNameStarts && !bNameStarts) return -1;
      if (!aNameStarts && bNameStarts) return 1;

      // 이름이 정확히 일치하는 경우 우선순위 높음
      if (aName == queryLower && bName != queryLower) return -1;
      if (aName != queryLower && bName == queryLower) return 1;

      // 주소 매칭 우선순위
      final aAddressContains = aAddress.contains(queryLower);
      final bAddressContains = bAddress.contains(queryLower);
      if (aAddressContains && !bAddressContains) return -1;
      if (!aAddressContains && bAddressContains) return 1;

      // 그 외에는 이름 순으로 정렬
      return aName.compareTo(bName);
    });

    return results;
  }
}

/// 모든 교회 데이터 Provider
final allParishesProvider =
    FutureProvider<Map<String, List<Map<String, dynamic>>>>((ref) {
      return ParishService.loadAllParishes();
    });

/// 특정 교구의 교회 목록 Provider
final parishesByDioceseProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, dioceseId) {
      return ParishService.getParishesByDiocese(dioceseId);
    });

/// 특정 교회 데이터 Provider
final parishByIdProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, parishId) {
    return ParishService.getParishById(parishId);
  },
);
