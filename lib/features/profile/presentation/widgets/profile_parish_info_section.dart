import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';

/// 프로필 교회 정보 섹션
class ProfileParishInfoSection extends ConsumerWidget {
  final String? selectedParishName;
  final VoidCallback onParishTap;

  const ProfileParishInfoSection({
    super.key,
    this.selectedParishName,
    required this.onParishTap,
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
              l10n.profile.parishInfo.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 소속 본당 선택
            InkWell(
              onTap: onParishTap,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.auth.parish,
                  suffixIcon: const Icon(Icons.chevron_right),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  selectedParishName ?? l10n.common.select,
                  style: TextStyle(
                    color: selectedParishName != null
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
