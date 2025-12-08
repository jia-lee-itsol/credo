import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/liturgy_constants.dart';
import '../../../../core/data/services/saint_feast_day_service.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../config/routes/app_routes.dart';

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
              padding: const EdgeInsets.all(16),
              child: _buildNearbyParishButton(context, theme, primaryColor),
            ),
          ),

          // 섹션 타이틀: よく行く教会
          SliverToBoxAdapter(child: _buildSectionTitle(context, 'よく行く教会')),

          // よく行く教会 리스트 (임시)
          SliverToBoxAdapter(
            child: _buildFavoriteParishesPlaceholder(context, theme),
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
    final dateFormat = DateFormat('yyyy年M月d日 (E)', 'ja');
    final todaySaintsAsync = ref.watch(todaySaintsProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [backgroundColor, theme.colorScheme.surface],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 로그인 버튼 (상단 우측)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),
                  TextButton.icon(
                    onPressed: () {
                      context.push(AppRoutes.signIn);
                    },
                    icon: Icon(Icons.login, size: 18, color: primaryColor),
                    label: Text(
                      'ログイン',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 날짜
              Text(
                dateFormat.format(now),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // 오늘의 성인 축일
              todaySaintsAsync.when(
                data: (saints) {
                  if (saints.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...saints.map(
                        (saint) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 16, color: primaryColor),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  saint.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 전례 시즌
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    seasonName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // 앱 이름
              Text(
                'Credo',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
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
    return Card(
      elevation: 0,
      color: primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.parishList);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('現在地から近い教会を検索', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: primaryColor, size: 20),
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

  Widget _buildFavoriteParishesPlaceholder(
    BuildContext context,
    ThemeData theme,
  ) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.church_outlined,
              size: 40,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'よく行く教会を登録しましょう',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
