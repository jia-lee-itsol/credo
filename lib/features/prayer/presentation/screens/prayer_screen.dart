import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/expandable_content_card.dart';

/// 기도 가이드 화면
class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _noticeFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _noticeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10nAsync = ref.watch(appLocalizationsProvider);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    return l10nAsync.when(
      data: (l10n) {
        // 기도 바치는 시기 가이드 데이터
        final morningGuide = l10n.mass.prayer.morning;
        final mealGuide = l10n.mass.prayer.meal;
        final eveningGuide = l10n.mass.prayer.evening;
        final difficultGuide = l10n.mass.prayer.difficult;
        final thanksgivingGuide = l10n.mass.prayer.thanksgiving;
        final meditationGuide = l10n.mass.prayer.meditation;
        final repentanceGuide = l10n.mass.prayer.repentance;
        final peaceGuide = l10n.mass.prayer.peace;
        final forgivenessGuide = l10n.mass.prayer.forgiveness;
        final loveGuide = l10n.mass.prayer.love;
        final patienceGuide = l10n.mass.prayer.patience;
        final waitingGuide = l10n.mass.prayer.waiting;

        final prayerGuides = [
          _PrayerGuide(
            title: morningGuide.title,
            subtitle: morningGuide.subtitle,
            icon: Icons.wb_sunny,
            content: morningGuide.content,
          ),
          _PrayerGuide(
            title: mealGuide.title,
            subtitle: mealGuide.subtitle,
            icon: Icons.restaurant,
            content: mealGuide.content,
          ),
          _PrayerGuide(
            title: eveningGuide.title,
            subtitle: eveningGuide.subtitle,
            icon: Icons.bedtime,
            content: eveningGuide.content,
          ),
          _PrayerGuide(
            title: difficultGuide.title,
            subtitle: difficultGuide.subtitle,
            icon: Icons.shield,
            content: difficultGuide.content,
          ),
          _PrayerGuide(
            title: thanksgivingGuide.title,
            subtitle: thanksgivingGuide.subtitle,
            icon: Icons.favorite,
            content: thanksgivingGuide.content,
          ),
          _PrayerGuide(
            title: meditationGuide.title,
            subtitle: meditationGuide.subtitle,
            icon: Icons.self_improvement,
            content: meditationGuide.content,
          ),
          _PrayerGuide(
            title: repentanceGuide.title,
            subtitle: repentanceGuide.subtitle,
            icon: Icons.refresh,
            content: repentanceGuide.content,
          ),
          _PrayerGuide(
            title: peaceGuide.title,
            subtitle: peaceGuide.subtitle,
            icon: Icons.spa,
            content: peaceGuide.content,
          ),
          _PrayerGuide(
            title: forgivenessGuide.title,
            subtitle: forgivenessGuide.subtitle,
            icon: Icons.favorite_outline,
            content: forgivenessGuide.content,
          ),
          _PrayerGuide(
            title: loveGuide.title,
            subtitle: loveGuide.subtitle,
            icon: Icons.favorite,
            content: loveGuide.content,
          ),
          _PrayerGuide(
            title: patienceGuide.title,
            subtitle: patienceGuide.subtitle,
            icon: Icons.timer_outlined,
            content: patienceGuide.content,
          ),
          _PrayerGuide(
            title: waitingGuide.title,
            subtitle: waitingGuide.subtitle,
            icon: Icons.hourglass_empty,
            content: waitingGuide.content,
          ),
        ];

        return _buildContent(
          context,
          l10n,
          primaryColor,
          currentUser,
          prayerGuides,
          _controller,
          _noticeFadeAnimation,
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    Color primaryColor,
    dynamic currentUser,
    List<_PrayerGuide> prayerGuides,
    AnimationController controller,
    Animation<double> noticeFadeAnimation,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.mass.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.myPage);
              },
              child: CircleAvatar(
                key: ValueKey(currentUser?.profileImageUrl ?? 'no-image'),
                radius: 22,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                backgroundImage: currentUser?.profileImageUrl != null
                    ? NetworkImage(currentUser!.profileImageUrl!)
                    : null,
                child: currentUser?.profileImageUrl == null
                    ? Icon(Icons.person, size: 24, color: primaryColor)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 면책 조항 (애니메이션 적용)
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: noticeFadeAnimation,
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
          ),
          // 기도 가이드 목록 (staggered 애니메이션)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final guide = prayerGuides[index];
                // 각 카드에 딜레이된 애니메이션 적용
                final delay = 0.1 + (index * 0.05);
                final endDelay = (delay + 0.3).clamp(0.0, 1.0);

                return AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final animValue = Curves.easeOutCubic.transform(
                      ((controller.value - delay) / (endDelay - delay)).clamp(0.0, 1.0),
                    );
                    return Opacity(
                      opacity: animValue,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - animValue)),
                        child: child,
                      ),
                    );
                  },
                  child: ExpandableContentCard(
                    title: guide.title,
                    subtitle: guide.subtitle,
                    icon: guide.icon,
                    primaryColor: primaryColor,
                    content: guide.content,
                  ),
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
