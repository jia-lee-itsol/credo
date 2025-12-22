import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/liturgy_constants.dart';
import '../../../../core/data/services/saint_feast_day_service.dart' as core;
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/locale_provider.dart';

/// 홈 화면 헤더 위젯
class HomeHeader extends ConsumerWidget {
  final LiturgySeason season;
  final String seasonName;
  final Color primaryColor;
  final Color backgroundColor;

  const HomeHeader({
    super.key,
    required this.season,
    required this.seasonName,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);
    final testDate = ref.watch(testDateOverrideProvider);
    final now = testDate ?? DateTime.now();
    final currentUser = ref.watch(currentUserProvider);

    // 현재 로케일에 맞는 날짜 포맷 생성
    final dateFormat = HomeHeader._getDateFormatForLocale(currentLocale);
    final todaySaintsAsync = ref.watch(core.todaySaintsProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 날짜, 성인, 전례시즌
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 날짜
                    Text(
                      dateFormat.format(now),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),

                    // 오늘의 성인 축일 (리스트) - 탭하면 전체 목록으로 이동
                    todaySaintsAsync.when(
                      data: (saints) {
                        if (saints.isEmpty) {
                          return const SizedBox(height: 4);
                        }
                        return GestureDetector(
                          onTap: () => context.go(AppRoutes.todaySaints),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...saints.map((saint) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            saint.getName(
                                              currentLocale.languageCode,
                                            ),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                // 성인이 2인 이상이면 "전체 보기" 표시
                                if (saints.length >= 2)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 12,
                                          color: Colors.white.withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getViewAllText(currentLocale.languageCode, saints.length),
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(height: 4),
                      error: (_, _) => const SizedBox(height: 4),
                    ),

                    const SizedBox(height: 8),

                    // 전례 시즌
                    Text(
                      seasonName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 오른쪽: 마이페이지 프로필 이미지
              GestureDetector(
                onTap: () {
                  context.push(AppRoutes.myPage);
                },
                child: CircleAvatar(
                  key: ValueKey(
                    currentUser?.profileImageUrl ?? 'no-image',
                  ), // 이미지 URL이 변경되면 위젯 재생성
                  radius: 22,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: currentUser?.profileImageUrl != null
                      ? NetworkImage(currentUser!.profileImageUrl!)
                      : null,
                  child: currentUser?.profileImageUrl == null
                      ? const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 로케일에 맞는 날짜 포맷 생성
  static DateFormat _getDateFormatForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return DateFormat('yyyy年M月d日（E）', 'ja');
      case 'ko':
        return DateFormat('yyyy년 M월 d일 (E)', 'ko');
      case 'en':
        return DateFormat('MMMM d, yyyy (EEE)', 'en');
      case 'zh':
        return DateFormat('yyyy年M月d日 (E)', 'zh');
      case 'vi':
        return DateFormat("d 'tháng' M, yyyy (EEE)", 'vi');
      case 'es':
        return DateFormat("d 'de' MMMM, yyyy (EEE)", 'es');
      case 'pt':
        return DateFormat("d 'de' MMMM, yyyy (EEE)", 'pt');
      default:
        return DateFormat('yyyy年M月d日（E）', 'ja');
    }
  }

  /// 전체 보기 텍스트 (다국어)
  static String _getViewAllText(String languageCode, int count) {
    switch (languageCode) {
      case 'ja':
        return '全$count人の聖人を見る →';
      case 'ko':
        return '전체 $count명의 성인 보기 →';
      case 'en':
        return 'View all $count saints →';
      case 'zh':
        return '查看全部$count位圣人 →';
      case 'vi':
        return 'Xem tất cả $count vị thánh →';
      case 'es':
        return 'Ver todos los $count santos →';
      case 'pt':
        return 'Ver todos os $count santos →';
      default:
        return '全$count人の聖人を見る →';
    }
  }
}
