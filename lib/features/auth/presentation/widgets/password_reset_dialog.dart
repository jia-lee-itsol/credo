import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';

/// 비밀번호 재설정 다이얼로그
class PasswordResetDialog extends ConsumerStatefulWidget {
  const PasswordResetDialog({super.key});

  @override
  _PasswordResetDialogState createState() => _PasswordResetDialogState();

  /// 다이얼로그를 표시하고 이메일을 반환
  static Future<String?> show(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => const PasswordResetDialog(),
    );
  }
}

class _PasswordResetDialogState extends ConsumerState<PasswordResetDialog> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    return AlertDialog(
      title: Text(l10n.auth.passwordReset),
      content: TextField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: l10n.auth.email,
          hintText: l10n.auth.emailHint,
        ),
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common.cancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_emailController.text.trim()),
          child: Text(l10n.common.send),
        ),
      ],
    );
  }
}
