import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_localizations.dart';

/// 프로필 성사 날짜 섹션
class ProfileSacramentDatesSection extends ConsumerWidget {
  final DateTime? baptismDate;
  final DateTime? confirmationDate;
  final VoidCallback onBaptismDateTap;
  final VoidCallback onConfirmationDateTap;

  const ProfileSacramentDatesSection({
    super.key,
    this.baptismDate,
    this.confirmationDate,
    required this.onBaptismDateTap,
    required this.onConfirmationDateTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '聖事の日付',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 세례 날짜
            InkWell(
              onTap: onBaptismDateTap,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '洗礼日',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  baptismDate != null
                      ? DateFormat('yyyy年MM月dd日', 'ja').format(baptismDate!)
                      : l10n.common.select,
                  style: TextStyle(
                    color: baptismDate != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 견진 날짜
            InkWell(
              onTap: onConfirmationDateTap,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '堅信日',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  confirmationDate != null
                      ? DateFormat(
                          'yyyy年MM月dd日',
                          'ja',
                        ).format(confirmationDate!)
                      : l10n.common.select,
                  style: TextStyle(
                    color: confirmationDate != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
