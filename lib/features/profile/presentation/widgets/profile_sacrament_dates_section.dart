import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/locale_provider.dart';

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
    final locale = ref.watch(localeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.profile.sacramentDates.title,
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
                  labelText: l10n.profile.sacramentDates.baptismDate,
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  baptismDate != null
                      ? DateFormat.yMMMd(locale.languageCode).format(baptismDate!)
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
                  labelText: l10n.profile.sacramentDates.confirmationDate,
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  confirmationDate != null
                      ? DateFormat.yMMMd(locale.languageCode).format(confirmationDate!)
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
