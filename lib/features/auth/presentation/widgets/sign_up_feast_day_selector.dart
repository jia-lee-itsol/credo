import 'package:flutter/material.dart';
import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../../../core/utils/app_localizations.dart';

/// 회원가입 축일 선택 필드 위젯
class SignUpFeastDaySelector extends StatelessWidget {
  final SaintFeastDayModel? selectedFeastDay;
  final String? customBaptismalName;
  final int? customFeastMonth;
  final int? customFeastDay;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const SignUpFeastDaySelector({
    super.key,
    this.selectedFeastDay,
    this.customBaptismalName,
    this.customFeastMonth,
    this.customFeastDay,
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
          labelText: '守護聖人の祝日（任意）',
          suffixIcon: const Icon(Icons.chevron_right),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          selectedFeastDay != null
              ? '${selectedFeastDay?.name ?? ''} (${selectedFeastDay?.month ?? 0}${l10n.profile.month}${selectedFeastDay?.day ?? 0}${l10n.profile.day})'
              : customBaptismalName != null &&
                      customFeastMonth != null &&
                      customFeastDay != null
                  ? '$customBaptismalName ($customFeastMonth${l10n.profile.month}$customFeastDay${l10n.profile.day})'
                  : l10n.auth.selectFeastDay,
          style: TextStyle(
            color: selectedFeastDay != null
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

