import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';
import '../constants/parish_colors.dart';

/// 교회 목록이 비어있을 때 표시되는 위젯
class ParishEmptyState extends ConsumerWidget {
  const ParishEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.church_outlined,
            size: 64,
            color: ParishColors.neutral600,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.parish.empty.notFound,
            style: const TextStyle(
              fontSize: 16,
              color: ParishColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}
