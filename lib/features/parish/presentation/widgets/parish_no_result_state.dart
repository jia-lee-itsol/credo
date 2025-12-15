import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';
import '../constants/parish_colors.dart';

/// 검색 결과가 없을 때 표시되는 위젯
class ParishNoResultState extends ConsumerWidget {
  const ParishNoResultState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: ParishColors.neutral600,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.search.noResults,
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
