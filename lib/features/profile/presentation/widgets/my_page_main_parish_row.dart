import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/services/parish_service.dart' as core;
import '../../../../core/utils/app_localizations.dart';

/// 마이페이지 메인 성당 행 위젯
class MyPageMainParishRow extends ConsumerWidget {
  final ThemeData theme;
  final Color primaryColor;
  final String? mainParishId;

  const MyPageMainParishRow({
    super.key,
    required this.theme,
    required this.primaryColor,
    this.mainParishId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    if (mainParishId == null) {
      return Row(
        children: [
          Icon(Icons.church, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.common.notSet,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    final parishAsync = ref.watch(core.parishByIdProvider(mainParishId!));

    return parishAsync.when(
      data: (parish) {
        final parishName = parish?['name'] as String? ?? '未設定';
        return Row(
          children: [
            Icon(Icons.church, size: 20, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                parishName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Icon(Icons.church, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          const Expanded(child: Text('読み込み中...')),
        ],
      ),
      error: (_, _) => Row(
        children: [
          Icon(Icons.church, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'エラー',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

