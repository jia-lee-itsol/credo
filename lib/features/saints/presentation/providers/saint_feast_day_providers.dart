import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/data/services/saint_feast_day_service.dart';
import '../../../../core/data/services/saint_image_service.dart';
import '../../../../core/data/services/liturgical_reading_service.dart';
import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../core/services/logger_service.dart';

/// 오늘의 성인 축일 Provider (GPT 사용, 캐싱 포함)
/// 날짜가 바뀌면 자동으로 새로 로드됨
final todaySaintsProvider = FutureProvider<List<SaintFeastDayModel>>((
  ref,
) async {
  // 날짜 변경 감지를 위해 currentDateStringProvider를 watch
  // 날짜가 바뀌면 자동으로 재실행됨
  ref.watch(currentDateStringProvider);
  // 강제 새로고침 트리거
  ref.watch(saintsCacheRefreshTriggerProvider);
  // 테스트 날짜 오버라이드 감지
  final testDate = ref.watch(testDateOverrideProvider);
  final date = testDate ?? DateTime.now();
  final locale = ref.watch(localeProvider);
  return await SaintFeastDayService.getSaintsForDateFromChatGPT(
    date,
    locale.languageCode,
  );
});

/// 성인 캐시 강제 새로고침 트리거
final saintsCacheRefreshTriggerProvider = StateProvider<int>((ref) => 0);

/// 성인 캐시 삭제 및 새로고침
Future<void> refreshTodaySaints(WidgetRef ref) async {
  await SaintFeastDayService.clearTodaySaintsCache();
  // 트리거 값을 변경하여 provider 재실행
  ref.read(saintsCacheRefreshTriggerProvider.notifier).state++;
}

/// 사용자 세례명과 일치하는 오늘의 성인 Provider
final userBaptismalSaintProvider =
    FutureProvider.autoDispose<SaintFeastDayModel?>((ref) async {
      final currentUser = ref.watch(currentUserProvider);
      if (currentUser == null || currentUser.baptismalName == null) {
        return null;
      }

      final todaySaints = await ref.watch(todaySaintsProvider.future);
      final baptismalName = currentUser.baptismalName!.trim();

      // 오늘의 성인 중에서 세례명과 일치하는 성인 찾기
      for (final saint in todaySaints) {
        final locale = ref.watch(localeProvider);
        final saintName = saint.getName(locale.languageCode);

        // 정확히 일치하거나, 성인 이름에 세례명이 포함되거나, 세례명에 성인 이름이 포함되는 경우
        final normalizedSaint = saintName.toLowerCase().trim();
        final normalizedBaptism = baptismalName.toLowerCase().trim();

        if (normalizedSaint == normalizedBaptism ||
            normalizedSaint.contains(normalizedBaptism) ||
            normalizedBaptism.contains(normalizedSaint)) {
          // 이미지 URL이 없으면 검색
          if (saint.imageUrl == null || saint.imageUrl!.isEmpty) {
            final imageService = SaintImageService();
            final imageUrl = await imageService.searchSaintImage(
              saint,
              locale.languageCode,
            );
            if (imageUrl != null) {
              // 이미지 URL이 있는 새로운 모델 반환
              return SaintFeastDayModel(
                month: saint.month,
                day: saint.day,
                name: saint.name,
                nameEn: saint.nameEn,
                nameKo: saint.nameKo,
                nameZh: saint.nameZh,
                nameVi: saint.nameVi,
                nameEs: saint.nameEs,
                namePt: saint.namePt,
                type: saint.type,
                isJapanese: saint.isJapanese,
                greeting: saint.greeting,
                description: saint.description,
                imageUrl: imageUrl,
              );
            }
          }
          return saint;
        }
      }

      return null;
    });

/// 실패한 이미지 URL 추적 (404 등) - 전역 상태로 유지
final failedImageUrlsProvider = StateProvider<Set<String>>((ref) {
  return <String>{};
});

/// 성인 이미지 URL Provider
final saintImageUrlProvider = FutureProvider.autoDispose.family<String?, SaintFeastDayModel>((
  ref,
  saint,
) async {
  AppLogger.debug(
    '[saintImageUrlProvider] 호출됨: ${saint.name} (${saint.nameEn ?? saint.name}), 기존 imageUrl: ${saint.imageUrl ?? "null"}',
  );

  // SharedPreferences에서 실패한 URL 목록 가져오기
  final prefs = await SharedPreferences.getInstance();
  final failedUrlsKey = 'failed_saint_image_urls';
  final failedUrlsJson = prefs.getString(failedUrlsKey);
  final failedUrls = failedUrlsJson != null
      ? (jsonDecode(failedUrlsJson) as List<dynamic>)
            .map((e) => e as String)
            .toSet()
      : <String>{};

  AppLogger.debug(
    '[saintImageUrlProvider] 실패한 URL 목록 (SharedPreferences): $failedUrls',
  );

  // 기존 imageUrl이 있고, 실패한 URL 목록에 없으면 반환
  if (saint.imageUrl != null && saint.imageUrl!.isNotEmpty) {
    if (failedUrls.contains(saint.imageUrl)) {
      AppLogger.debug(
        '[saintImageUrlProvider] 실패한 URL 무시하고 재검색: ${saint.name}\n실패한 URL: ${saint.imageUrl}',
      );
      // 실패한 URL이면 재검색 계속 진행
    } else {
      AppLogger.debug('[saintImageUrlProvider] 기존 imageUrl 반환: ${saint.name}');
      return saint.imageUrl;
    }
  }

  final locale = ref.watch(localeProvider);
  AppLogger.debug(
    '[saintImageUrlProvider] 이미지 검색 시작: ${saint.name} (언어: ${locale.languageCode})',
  );

  final imageService = SaintImageService();
  final imageUrl = await imageService.searchSaintImage(
    saint,
    locale.languageCode,
  );

  AppLogger.debug(
    '[saintImageUrlProvider] 이미지 검색 완료: ${saint.name}, 결과: ${imageUrl ?? "null"}',
  );

  return imageUrl;
});
