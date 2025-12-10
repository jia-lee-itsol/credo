import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/liturgy_constants.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../config/routes/app_routes.dart';
import '../widgets/home_header.dart';
import '../widgets/home_action_button.dart';

/// 홈 화면
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final seasonAsync = ref.watch(currentLiturgySeasonProvider);
    final testDate = ref.watch(testDateOverrideProvider);
    final season =
        seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync(testDate);
    final seasonName = LiturgySeasonUtil.getSeasonName(season, locale: 'ja');
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final backgroundColor = ref.watch(liturgyBackgroundColorProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 헤더
          SliverToBoxAdapter(
            child: HomeHeader(
              season: season,
              seasonName: seasonName,
              primaryColor: primaryColor,
              backgroundColor: backgroundColor,
            ),
          ),

          // 근처 교회 찾기 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: HomeActionButton(
                icon: Icons.location_on_outlined,
                title: '近くの教会を探す',
                subtitle: '現在地から教会を検索',
                primaryColor: primaryColor,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                onTap: () => context.go(AppRoutes.parishList),
              ),
            ),
          ),

          // 오늘의 미사 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: HomeActionButton(
                icon: Icons.auto_stories,
                title: '今日のミサ',
                subtitle: '今日の聖書朗読と祈り',
                primaryColor: primaryColor,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                onTap: () => context.go(AppRoutes.dailyMass),
              ),
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
