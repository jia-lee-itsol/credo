import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saint_feast_day_model.dart';

/// 성인 축일 데이터 서비스
class SaintFeastDayService {
  static SaintsFeastDaysModel? _cachedData;

  /// 성인 축일 데이터 로드
  static Future<SaintsFeastDaysModel> loadSaintsFeastDays() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/saints_feast_days.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _cachedData = SaintsFeastDaysModel.fromJson(json);
      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load saints feast days data: $e');
    }
  }

  /// 특정 날짜의 성인 축일 가져오기
  static Future<List<SaintFeastDayModel>> getSaintsForDate(
    DateTime date,
  ) async {
    final data = await loadSaintsFeastDays();
    final month = date.month;
    final day = date.day;

    // 모든 성인 목록에서 해당 날짜 찾기
    final allSaints = [...data.saints, ...data.japaneseSaints];

    return allSaints
        .where((saint) => saint.month == month && saint.day == day)
        .toList();
  }

  /// 오늘의 성인 축일 가져오기
  static Future<List<SaintFeastDayModel>> getTodaySaints() async {
    return getSaintsForDate(DateTime.now());
  }
}

/// 오늘의 성인 축일 Provider
final todaySaintsProvider = FutureProvider<List<SaintFeastDayModel>>((ref) {
  return SaintFeastDayService.getTodaySaints();
});
