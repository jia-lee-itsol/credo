import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/liturgy_constants.dart';
import '../../core/theme/app_theme.dart';

/// 현재 전례 시즌 Provider (비동기)
final currentLiturgySeasonProvider = FutureProvider<LiturgySeason>((ref) async {
  return await LiturgySeasonUtil.getCurrentSeason();
});

/// 현재 전례 시즌 Provider (동기 - 하위 호환성)
final currentLiturgySeasonSyncProvider = Provider<LiturgySeason>((ref) {
  return LiturgySeasonUtil.getCurrentSeasonSync();
});

/// 전례 시즌 이름 Provider
final liturgySeasonNameProvider = Provider.family<String, String>((
  ref,
  locale,
) {
  final seasonAsync = ref.watch(currentLiturgySeasonProvider);
  final season = seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync();
  return LiturgySeasonUtil.getSeasonName(season, locale: locale);
});

/// 앱 테마 Provider
final appThemeProvider = Provider<ThemeData>((ref) {
  final season = ref.watch(currentLiturgySeasonSyncProvider);
  return AppTheme.lightTheme(season);
});

/// 전례 기본 색상 Provider
final liturgyPrimaryColorProvider = Provider<Color>((ref) {
  final seasonAsync = ref.watch(currentLiturgySeasonProvider);
  final season = seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync();
  return LiturgyColors.getPrimaryColor(season);
});

/// 전례 배경 색상 Provider
final liturgyBackgroundColorProvider = Provider<Color>((ref) {
  final season = ref.watch(currentLiturgySeasonSyncProvider);
  return LiturgyColors.getBackgroundColor(season);
});

/// 전례 시즌 정보 Notifier (수동 업데이트 필요 시 사용)
class LiturgySeasonNotifier extends StateNotifier<LiturgySeason> {
  LiturgySeasonNotifier() : super(LiturgySeasonUtil.getCurrentSeasonSync());

  /// 시즌 새로고침
  Future<void> refresh() async {
    state = await LiturgySeasonUtil.getCurrentSeason();
  }

  /// 특정 날짜로 시즌 설정 (테스트/미리보기용)
  Future<void> setDate(DateTime date) async {
    state = await LiturgySeasonUtil.getCurrentSeason(date);
  }
}

/// 전례 시즌 Notifier Provider
final liturgySeasonNotifierProvider =
    StateNotifierProvider<LiturgySeasonNotifier, LiturgySeason>((ref) {
      return LiturgySeasonNotifier();
    });
