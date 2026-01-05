import 'package:flutter/material.dart';
import '../../../../core/utils/app_localizations.dart';
import '../utils/mass_time_parser.dart';

/// 성당 미사 시간 섹션 위젯
class ParishDetailMassTimes extends StatefulWidget {
  final Map<String, dynamic> parish;
  final Color primaryColor;
  final AppLocalizations l10n;

  const ParishDetailMassTimes({
    super.key,
    required this.parish,
    required this.primaryColor,
    required this.l10n,
  });

  @override
  State<ParishDetailMassTimes> createState() => _ParishDetailMassTimesState();
}

class _ParishDetailMassTimesState extends State<ParishDetailMassTimes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _noticeFadeAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _noticeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
      ),
    );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
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
    final theme = Theme.of(context);
    final massTime = widget.parish['massTime'] as String?;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _titleFadeAnimation,
            child: Text(
              widget.l10n.parish.detailSection.massTime,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 경고 문구 (항상 표시, 위에 표시)
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _noticeFadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.l10n.parish.detailSection.massTimeNotice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _cardFadeAnimation,
            child: SlideTransition(
              position: _cardSlideAnimation,
              child: massTime == null || massTime.isEmpty
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.l10n.parish.detailSection.noMassTimeInfo,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : _MassTimeCards(
                      context: context,
                      theme: theme,
                      massTime: massTime,
                      parish: widget.parish,
                      l10n: widget.l10n,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 미사 시간 카드 위젯
class _MassTimeCards extends StatelessWidget {
  final BuildContext context;
  final ThemeData theme;
  final String massTime;
  final Map<String, dynamic> parish;
  final AppLocalizations l10n;

  const _MassTimeCards({
    required this.context,
    required this.theme,
    required this.massTime,
    required this.parish,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final separated = MassTimeParser.separateMassTimeByLanguage(
      massTime,
      parish,
    );
    final japaneseGroups = separated['japanese'] as List<Map<String, String>>;
    final foreignGroups = separated['foreign'] as List<Map<String, String>>;

    final hasForeign = foreignGroups.isNotEmpty;

    if (!hasForeign) {
      // 외국어 미사가 없으면 단일 카드
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _MassTimeByWeekday(
            context: context,
            theme: theme,
            weekdayGroups: japaneseGroups,
            l10n: l10n,
          ),
        ),
      );
    }

    // 외국어 미사가 있으면 두 개의 카드를 세로로 표시
    return Column(
      children: [
        // 위: 일본어 미사
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _MassTimeByWeekday(
              context: context,
              theme: theme,
              weekdayGroups: japaneseGroups,
              l10n: l10n,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 아래: 외국어 미사
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _MassTimeByWeekday(
              context: context,
              theme: theme,
              weekdayGroups: foreignGroups,
              l10n: l10n,
            ),
          ),
        ),
      ],
    );
  }
}

/// 요일별 미사 시간 위젯
class _MassTimeByWeekday extends StatelessWidget {
  final BuildContext context;
  final ThemeData theme;
  final List<Map<String, String>> weekdayGroups;
  final AppLocalizations l10n;

  const _MassTimeByWeekday({
    required this.context,
    required this.theme,
    required this.weekdayGroups,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (weekdayGroups.isEmpty) {
      return Text(
        l10n.parish.detailSection.noMassTimeInfoInList,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weekdayGroups.map((group) {
        final weekday = group['weekday'] as String;
        final times = group['times'] as String;
        final timesList = times.split('\n');

        // 요일 표시 변환
        String displayWeekday;
        if (weekday == '日') {
          displayWeekday = l10n.parish.detailSection.weekdays.sunday;
        } else if (weekday == '土') {
          displayWeekday = l10n.parish.detailSection.weekdays.saturday;
        } else if (weekday == '月-金') {
          displayWeekday = l10n.parish.detailSection.weekdays.mondayToFriday;
        } else if (weekday == '月') {
          displayWeekday = l10n.parish.detailSection.weekdays.monday;
        } else if (weekday == '火') {
          displayWeekday = l10n.parish.detailSection.weekdays.tuesday;
        } else if (weekday == '水') {
          displayWeekday = l10n.parish.detailSection.weekdays.wednesday;
        } else if (weekday == '木') {
          displayWeekday = l10n.parish.detailSection.weekdays.thursday;
        } else if (weekday == '金') {
          displayWeekday = l10n.parish.detailSection.weekdays.friday;
        } else if (weekday == 'その他') {
          displayWeekday = l10n.parish.detailSection.other;
        } else {
          displayWeekday = weekday;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 요일 제목
              Text(
                displayWeekday,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              // 미사 시간들
              ...timesList.map((time) {
                final languageCode = MassTimeParser.detectLanguageCode(time);

                // 외국어 미사인 경우 순서를 "언어 시간"으로 변경
                String displayText;
                if (languageCode != null) {
                  displayText = MassTimeParser.reorderForeignMassText(
                    time,
                    languageCode,
                    l10n,
                  );
                } else {
                  // 일반 미사 시간에서 일본어 표현 번역 처리
                  displayText = MassTimeParser.translateJapaneseExpressions(
                    context,
                    time,
                    l10n,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (languageCode != null) ...[
                        // 국기 이모지
                        Text(
                          MassTimeParser.getFlagEmoji(languageCode),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                      ],
                      // 미사 시간 텍스트
                      Expanded(
                        child: Text(
                          displayText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }
}

