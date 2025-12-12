import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/expandable_content_card.dart';

/// 기도 가이드 화면
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    // 기도 바치는 시기 가이드 데이터
    final prayerGuides = [
      _PrayerGuide(
        title: '朝の黙想',
        subtitle: 'Morning',
        icon: Icons.wb_sunny,
        content:
            '一日の始まりに、神様に感謝しながら新しい一日を神様の保護の下に委ねる時間です。朝起きて一日を始めるとき、一日中のお恵みと保護を願う時です。',
      ),
      _PrayerGuide(
        title: '食事の黙想',
        subtitle: 'Meal',
        icon: Icons.restaurant,
        content:
            '食事の前後に、食べ物を与えてくださった神様に感謝する時間です。食事の前には食べ物を与えてくださったことに感謝し、食事の後には満腹になったことに感謝する時です。',
      ),
      _PrayerGuide(
        title: '夜の黙想',
        subtitle: 'Evening',
        icon: Icons.bedtime,
        content:
            '一日を終えるにあたり、神様に感謝し、一日の罪を悔い改めて赦しを願う時間です。就寝前に一日を振り返り、明日のために祈る時です。',
      ),
      _PrayerGuide(
        title: '困難な時の黙想',
        subtitle: 'In Difficult Times',
        icon: Icons.shield,
        content: '困難な状況や苦しい時に、神様の助けと慰めを願う時間です。試練や苦難の中でも、神様の愛と保護を信じる時です。',
      ),
      _PrayerGuide(
        title: '感謝の黙想',
        subtitle: 'Thanksgiving',
        icon: Icons.favorite,
        content:
            '神様が与えてくださった恵みと祝福に感謝する時間です。日常の小さな喜びから大きな祝福まで、すべてのことに感謝の心を持つ時です。',
      ),
      _PrayerGuide(
        title: '黙想の時間',
        subtitle: 'Meditation Time',
        icon: Icons.self_improvement,
        content:
            '静かな時間を持ち、神様と対話しながら自分の心を見つめ直す時間です。み言葉を黙想し、神様の御心を求めながら平和な時間を過ごします。',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('黙想のガイド'),
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
                '※本コンテンツは個人の黙想のためのガイドです。\n聖書本文の提供は行っていません。',
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
