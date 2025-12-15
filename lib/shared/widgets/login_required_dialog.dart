import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/app_routes.dart';
import '../../core/utils/app_localizations.dart';

/// 로그인 필요 다이얼로그
class LoginRequiredDialog extends ConsumerWidget {
  final String? message;
  final Color? primaryColor;

  const LoginRequiredDialog({super.key, this.message, this.primaryColor});

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<void> show(
    BuildContext context, {
    String? message,
    Color? primaryColor,
  }) {
    return showDialog(
      context: context,
      builder: (context) =>
          LoginRequiredDialog(message: message, primaryColor: primaryColor),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final color = primaryColor ?? theme.colorScheme.primary;

    return AlertDialog(
      title: Text(l10n.auth.loginRequired),
      content: Text(message ?? l10n.auth.loginRequiredQuestion),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.signIn);
          },
          child: Text(l10n.auth.signIn, style: TextStyle(color: color)),
        ),
      ],
    );
  }
}
