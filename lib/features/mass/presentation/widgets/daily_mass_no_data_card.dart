import 'package:flutter/material.dart';
import '../../../../core/utils/app_localizations.dart';

/// 매일미사 데이터 없음 카드 위젯
class DailyMassNoDataCard extends StatelessWidget {
  final ThemeData theme;
  final Color primaryColor;
  final AppLocalizations l10n;

  const DailyMassNoDataCard({
    super.key,
    required this.theme,
    required this.primaryColor,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            l10n.mass.noDataToday,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.mass.noDataWeekday,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

