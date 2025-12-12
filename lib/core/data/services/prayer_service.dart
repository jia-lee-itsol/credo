import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../error/failures.dart';
import '../../services/logger_service.dart';

/// 기도문 모델
class Prayer {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String content;

  const Prayer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.content,
  });

  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      icon: json['icon'] as String,
      content: json['content'] as String,
    );
  }
}

/// 기도문 데이터 서비스
class PrayerService {
  static List<Prayer>? _cachedPrayers;

  /// 기도문 목록 로드
  static Future<List<Prayer>> loadPrayers({String locale = 'ja'}) async {
    if (_cachedPrayers != null) {
      return _cachedPrayers!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/prayers/prayers_$locale.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final prayersList = json['prayers'] as List<dynamic>;

      _cachedPrayers = prayersList
          .map((p) => Prayer.fromJson(p as Map<String, dynamic>))
          .toList();

      return _cachedPrayers!;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load prayers data', e, stackTrace);
      throw CacheFailure(message: '기도문 데이터를 불러오는데 실패했습니다: $e');
    }
  }

  /// 캐시 초기화 (언어 변경 시 사용)
  static void clearCache() {
    _cachedPrayers = null;
  }
}

/// 기도문 목록 Provider
final prayersProvider = FutureProvider<List<Prayer>>((ref) {
  return PrayerService.loadPrayers();
});
