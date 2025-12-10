import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/app_routes.dart';

/// 로그인 필요 다이얼로그
class LoginRequiredDialog extends StatelessWidget {
  final String message;
  final Color? primaryColor;

  const LoginRequiredDialog({
    super.key,
    this.message = 'この機能を使用するにはログインが必要です。ログインしますか？',
    this.primaryColor,
  });

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<void> show(
    BuildContext context, {
    String? message,
    Color? primaryColor,
  }) {
    return showDialog(
      context: context,
      builder: (context) => LoginRequiredDialog(
        message: message ?? 'この機能を使用するにはログインが必要です。ログインしますか？',
        primaryColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = primaryColor ?? theme.colorScheme.primary;

    return AlertDialog(
      title: const Text('ログインが必要です'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.signIn);
          },
          child: Text('ログイン', style: TextStyle(color: color)),
        ),
      ],
    );
  }
}
