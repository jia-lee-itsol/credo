import 'package:flutter/material.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/expandable_content_card.dart';

/// 매일미사 묵상 팁 섹션 위젯
class DailyMassMeditationTips extends StatelessWidget {
  final ThemeData theme;
  final Color primaryColor;
  final AppLocalizations l10n;

  const DailyMassMeditationTips({
    super.key,
    required this.theme,
    required this.primaryColor,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final meditationTips = l10n.mass.prayer.meditationTips;
      final practicalTips = l10n.mass.prayer.practicalTips;
      final meditationJournal = l10n.mass.prayer.meditationJournal;
      final prayerAfterMeditation = l10n.mass.prayer.prayerAfterMeditation;

      // 모든 카드 리스트 생성
      final List<Widget> cards = [];

      // 묵상 방법 안내 카드
      if (meditationTips.hasData) {
        cards.add(
          ExpandableContentCard(
            title: meditationTips.title,
            subtitle: meditationTips.subtitle,
            icon: Icons.self_improvement,
            primaryColor: primaryColor,
            content: meditationTips.content,
          ),
        );
      }

      // 실용적인 묵상 팁 카드
      if (practicalTips.hasData) {
        if (cards.isNotEmpty) cards.add(const SizedBox(height: 12));
        cards.add(
          ExpandableContentCard(
            title: practicalTips.title,
            subtitle: practicalTips.subtitle,
            icon: Icons.lightbulb_outline,
            primaryColor: primaryColor,
            content: practicalTips.content,
          ),
        );
      }

      // 묵상 일기 작성 가이드 카드
      if (meditationJournal.hasData) {
        if (cards.isNotEmpty) cards.add(const SizedBox(height: 12));
        cards.add(
          ExpandableContentCard(
            title: meditationJournal.title,
            subtitle: meditationJournal.subtitle,
            icon: Icons.edit_note,
            primaryColor: primaryColor,
            content: meditationJournal.content,
          ),
        );
      }

      // 묵상 후 기도 카드
      if (prayerAfterMeditation.hasData) {
        if (cards.isNotEmpty) cards.add(const SizedBox(height: 12));
        cards.add(
          ExpandableContentCard(
            title: prayerAfterMeditation.title,
            subtitle: prayerAfterMeditation.subtitle,
            icon: Icons.favorite_outline,
            primaryColor: primaryColor,
            content: prayerAfterMeditation.content,
          ),
        );
      }

      // 카드가 없으면 빈 위젯 반환
      if (cards.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cards,
      );
    } catch (e, stackTrace) {
      AppLogger.error('[DailyMassScreen] 묵상 팁 섹션 로드 실패', e, stackTrace);
      return const SizedBox.shrink();
    }
  }
}

