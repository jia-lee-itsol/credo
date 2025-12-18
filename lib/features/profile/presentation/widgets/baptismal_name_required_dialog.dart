import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../config/routes/app_routes.dart';

/// 세례명 등록 권유 다이얼로그
class BaptismalNameRequiredDialog extends ConsumerWidget {
  const BaptismalNameRequiredDialog({super.key});

  /// 다이얼로그 표시
  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BaptismalNameRequiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.profile.baptismalNameRequired.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profile.baptismalNameRequired.message,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.profile.baptismalNameRequired.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.common.cancel,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.editProfile);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.profile.baptismalNameRequired.goToProfile),
        ),
      ],
    );
  }
}

