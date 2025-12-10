import 'package:flutter/material.dart';

/// 비밀번호 재설정 다이얼로그
class PasswordResetDialog extends StatefulWidget {
  const PasswordResetDialog({super.key});

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();

  /// 다이얼로그를 표시하고 이메일을 반환
  static Future<String?> show(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => const PasswordResetDialog(),
    );
  }
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('パスワードリセット'),
      content: TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: 'メールアドレス',
          hintText: 'メールアドレスを入力してください',
        ),
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_emailController.text.trim()),
          child: const Text('送信'),
        ),
      ],
    );
  }
}

