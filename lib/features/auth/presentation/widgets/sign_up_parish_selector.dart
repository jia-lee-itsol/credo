import 'package:flutter/material.dart';
import '../../../../core/utils/app_localizations.dart';

/// 회원가입 성당 선택 필드 위젯
class SignUpParishSelector extends StatelessWidget {
  final String? selectedParishName;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const SignUpParishSelector({
    super.key,
    this.selectedParishName,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.auth.parish,
          suffixIcon: const Icon(Icons.chevron_right),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          selectedParishName ?? l10n.auth.selectParish,
          style: TextStyle(
            color: selectedParishName != null
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

