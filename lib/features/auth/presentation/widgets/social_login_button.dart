import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';

/// 소셜 로그인 버튼 타입
enum SocialLoginType { google, apple }

/// 소셜 로그인 버튼 위젯
class SocialLoginButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final (icon, label) = _getIconAndLabel(l10n);

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  (IconData, String) _getIconAndLabel(AppLocalizations l10n) {
    switch (type) {
      case SocialLoginType.google:
        return (Icons.g_mobiledata, 'Google ${l10n.auth.signIn}');
      case SocialLoginType.apple:
        return (Icons.apple, 'Apple ${l10n.auth.signIn}');
    }
  }
}
