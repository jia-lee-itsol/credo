import 'package:flutter/material.dart';

/// 소셜 로그인 버튼 타입
enum SocialLoginType {
  google,
  apple,
}

/// 소셜 로그인 버튼 위젯
class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _getIconAndLabel();

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  (IconData, String) _getIconAndLabel() {
    switch (type) {
      case SocialLoginType.google:
        return (Icons.g_mobiledata, 'Googleでログイン');
      case SocialLoginType.apple:
        return (Icons.apple, 'Appleでログイン');
    }
  }
}

