import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/liturgy_constants.dart';
import '../../../../core/data/services/saint_feast_day_service.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../config/routes/app_routes.dart' show AppRoutes;

/// 홈 화면
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final seasonAsync = ref.watch(currentLiturgySeasonProvider);
    final season =
        seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync();
    final seasonName = LiturgySeasonUtil.getSeasonName(season, locale: 'ja');
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final backgroundColor = ref.watch(liturgyBackgroundColorProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 헤더
          SliverToBoxAdapter(
            child: _buildHeader(
              context,
              theme,
              season,
              seasonName,
              primaryColor,
              backgroundColor,
              ref,
            ),
          ),

          // 근처 교회 찾기 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildNearbyParishButton(context, theme, primaryColor),
            ),
          ),

          // 오늘의 미사 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _buildTodayMassButton(context, theme, primaryColor),
            ),
          ),

          // 섹션 타이틀: 最近のお知らせ
          SliverToBoxAdapter(child: _buildSectionTitle(context, '最近のお知らせ')),

          // お知らせ 리스트 (임시)
          SliverToBoxAdapter(child: _buildNoticesPlaceholder(context, theme)),

          // 하단 여백
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    LiturgySeason season,
    String seasonName,
    Color primaryColor,
    Color backgroundColor,
    WidgetRef ref,
  ) {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy年M月d日（E）', 'ja');
    final todaySaintsAsync = ref.watch(todaySaintsProvider);

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

                    // 오늘의 성인 축일
                    todaySaintsAsync.when(
                      data: (saints) {
                        if (saints.isEmpty) {
                          return const SizedBox(height: 4);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
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
                                  saints.first.name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox(height: 4),
                      error: (_, __) => const SizedBox(height: 4),
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

              // 오른쪽: 마이페이지 아이콘
              GestureDetector(
                onTap: () {
                  context.push(AppRoutes.myPage);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyParishButton(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.parishList);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: LiturgyColors.adventLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '近くの教会を探す',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF262626),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '現在地から教会を検索',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF737373),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF737373),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayMassButton(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.go(AppRoutes.dailyMass);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: LiturgyColors.adventLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_stories, color: primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日のミサ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF262626),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '今日の聖書朗読と祈り',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF737373),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF737373),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNoticesPlaceholder(BuildContext context, ThemeData theme) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 40,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'お知らせはありません',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
