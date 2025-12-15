import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/expandable_content_card.dart';

/// 기도 가이드 화면
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    // 기도 바치는 시기 가이드 데이터
    final prayerGuides = [
      _PrayerGuide(
        title: l10n.mass.prayer.morning.title,
        subtitle: l10n.mass.prayer.morning.subtitle,
        icon: Icons.wb_sunny,
        content: l10n.mass.prayer.morning.content,
      ),
      _PrayerGuide(
        title: l10n.mass.prayer.meal.title,
        subtitle: l10n.mass.prayer.meal.subtitle,
        icon: Icons.restaurant,
        content: l10n.mass.prayer.meal.content,
      ),
      _PrayerGuide(
        title: l10n.mass.prayer.evening.title,
        subtitle: l10n.mass.prayer.evening.subtitle,
        icon: Icons.bedtime,
        content: l10n.mass.prayer.evening.content,
      ),
      _PrayerGuide(
        title: l10n.mass.prayer.difficult.title,
        subtitle: l10n.mass.prayer.difficult.subtitle,
        icon: Icons.shield,
        content: l10n.mass.prayer.difficult.content,
      ),
      _PrayerGuide(
        title: l10n.mass.prayer.thanksgiving.title,
        subtitle: l10n.mass.prayer.thanksgiving.subtitle,
        icon: Icons.favorite,
        content: l10n.mass.prayer.thanksgiving.content,
      ),
      _PrayerGuide(
        title: l10n.mass.prayer.meditation.title,
        subtitle: l10n.mass.prayer.meditation.subtitle,
        icon: Icons.self_improvement,
        content: l10n.mass.prayer.meditation.content,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.mass.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.myPage);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                backgroundImage: currentUser?.profileImageUrl != null
                    ? NetworkImage(currentUser!.profileImageUrl!)
                    : null,
                child: currentUser?.profileImageUrl == null
                    ? Icon(Icons.person, size: 20, color: primaryColor)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 면책 조항
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Text(
                l10n.mass.bibleNotice,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // 기도 가이드 목록
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final guide = prayerGuides[index];
                return ExpandableContentCard(
                  title: guide.title,
                  subtitle: guide.subtitle,
                  icon: guide.icon,
                  primaryColor: primaryColor,
                  content: guide.content,
                );
              }, childCount: prayerGuides.length),
            ),
          ),
        ],
      ),
    );
  }
}

/// 기도 가이드 데이터 모델
class _PrayerGuide {
  final String title;
  final String subtitle;
  final IconData icon;
  final String content;

  const _PrayerGuide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.content,
  });
}
