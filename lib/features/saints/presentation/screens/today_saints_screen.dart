import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../providers/saint_feast_day_providers.dart';

/// 오늘의 성인 목록 화면
class TodaySaintsScreen extends ConsumerWidget {
  const TodaySaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final todaySaintsAsync = ref.watch(todaySaintsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.saints.todaySaints),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () async {
              // 캐시 삭제 및 새로고침
              await refreshTodaySaints(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('성인 데이터를 새로고침합니다...')),
                );
              }
            },
          ),
        ],
      ),
      body: todaySaintsAsync.when(
        data: (saints) {
          if (saints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_outline,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.saints.noSaintsToday,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await refreshTodaySaints(ref);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: saints.length + 1, // +1 for header
              itemBuilder: (context, index) {
                if (index == 0) {
                  // 출처 안내 문구
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      l10n.saints.sourceNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                final saint = saints[index - 1];
                return _buildSaintCard(context, ref, theme, l10n, saint);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            l10n.saints.loadFailed,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaintCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    SaintFeastDayModel saint,
  ) {
    final locale = ref.watch(localeProvider);
    final saintName = saint.getName(locale.languageCode);
    final saintId = '${saint.month}-${saint.day}-${saint.name.hashCode}';
    final imageUrlAsync = ref.watch(saintImageUrlProvider(saint));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push(AppRoutes.saintDetailPath(saintId)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 성인 이미지 또는 로고
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                ),
                child: ClipOval(
                  child: imageUrlAsync.when(
                    data: (imageUrl) {
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            // 에러 로깅
                            debugPrint(
                              '❌ [CachedNetworkImage] 이미지 로드 실패: $url',
                            );
                            debugPrint('❌ [CachedNetworkImage] 에러: $error');

                            // 404 에러인 경우 캐시 무효화
                            if (error.toString().contains('404')) {
                              debugPrint(
                                '🔄 [TodaySaintsScreen] 404 에러 감지, 캐시 무효화: $url',
                              );
                              _invalidateImageCache(saint, url);
                            }

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/icons/logo.png',
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                          httpHeaders: const {
                            'User-Agent':
                                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                          },
                        );
                      }
                      // 이미지가 없으면 앱 로고 표시
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/icons/logo.png',
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                    loading: () => Container(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/icons/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 성인 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saintName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(
                              saint.type,
                              theme,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getTypeLabel(saint.type, l10n),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getTypeColor(saint.type, theme),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(saint.month, saint.day, locale.languageCode),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 화살표 아이콘
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 축일 타입에 따른 색상 반환
  Color _getTypeColor(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'solemnity':
        return Colors.red;
      case 'feast':
        return Colors.orange;
      case 'memorial':
      default:
        return theme.colorScheme.primary;
    }
  }

  /// 축일 타입에 따른 라벨 반환
  String _getTypeLabel(String type, AppLocalizations l10n) {
    switch (type.toLowerCase()) {
      case 'solemnity':
        return l10n.saints.solemnity;
      case 'feast':
        return l10n.saints.feast;
      case 'memorial':
      default:
        return l10n.saints.memorial;
    }
  }

  /// 날짜 포맷 (다국어)
  String _formatDate(int month, int day, String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '$month月$day日';
      case 'ko':
        return '$month월 $day일';
      case 'en':
        return '${_getEnglishMonth(month)} $day';
      case 'zh':
        return '$month月$day日';
      case 'vi':
        return 'Ngày $day tháng $month';
      case 'es':
        return '$day de ${_getSpanishMonth(month)}';
      case 'pt':
        return '$day de ${_getPortugueseMonth(month)}';
      default:
        return '$month月$day日';
    }
  }

  String _getEnglishMonth(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getSpanishMonth(int month) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return months[month - 1];
  }

  String _getPortugueseMonth(int month) {
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return months[month - 1];
  }

  /// 이미지 캐시 무효화 및 실패한 URL 저장
  Future<void> _invalidateImageCache(
    SaintFeastDayModel saint,
    String? url,
  ) async {
    try {
      final cacheKey =
          'saint_image_${saint.month}_${saint.day}_${saint.name.hashCode}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cacheKey);

      // 실패한 URL을 SharedPreferences에 저장
      if (url != null && url.isNotEmpty) {
        final failedUrlsKey = 'failed_saint_image_urls';
        final failedUrlsJson = prefs.getString(failedUrlsKey);
        final failedUrls = failedUrlsJson != null
            ? (jsonDecode(failedUrlsJson) as List<dynamic>)
                  .map((e) => e as String)
                  .toSet()
            : <String>{};

        failedUrls.add(url);
        await prefs.setString(failedUrlsKey, jsonEncode(failedUrls.toList()));
        debugPrint(
          '🗑️ [TodaySaintsScreen] 이미지 캐시 무효화 및 실패한 URL 저장: ${saint.name}\n실패한 URL: $url\n총 실패한 URL: ${failedUrls.length}개',
        );
      } else {
        debugPrint('🗑️ [TodaySaintsScreen] 이미지 캐시 무효화: ${saint.name}');
      }
    } catch (e) {
      debugPrint('❌ [TodaySaintsScreen] 캐시 무효화 실패: $e');
    }
  }
}
