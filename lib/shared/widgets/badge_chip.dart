import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_localizations.dart';

/// 배지 타입
enum BadgeType {
  official, // 공식
  pinned, // 고정
  custom, // 커스텀
}

/// 배지 칩 위젯
/// 공식, 고정 등의 배지 표시용
class BadgeChip extends ConsumerWidget {
  final BadgeType type;
  final String? customLabel;
  final IconData? customIcon;
  final Color? customColor;

  BadgeChip({
    super.key,
    required this.type,
    this.customLabel,
    this.customIcon,
    this.customColor,
  });

  /// 공식 배지 생성
  const BadgeChip.official({super.key})
    : type = BadgeType.official,
      customLabel = null,
      customIcon = null,
      customColor = null;

  /// 고정 배지 생성
  const BadgeChip.pinned({super.key})
    : type = BadgeType.pinned,
      customLabel = null,
      customIcon = null,
      customColor = null;

  /// 커스텀 배지 생성
  const BadgeChip.custom({
    super.key,
    required String label,
    required IconData icon,
    required Color color,
  }) : type = BadgeType.custom,
       customLabel = label,
       customIcon = icon,
       customColor = color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.read(appLocalizationsSyncProvider);
    final (label, icon, bgColor, fgColor) = _getBadgeStyle(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fgColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: fgColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  (String, IconData, Color, Color) _getBadgeStyle(AppLocalizations l10n) {
    switch (type) {
      case BadgeType.official:
        return (
          l10n.community.official,
          Icons.verified,
          Colors.amber.shade100,
          Colors.amber.shade700,
        );
      case BadgeType.pinned:
        return (
          l10n.community.pinned,
          Icons.push_pin,
          Colors.orange.shade100,
          Colors.orange.shade700,
        );
      case BadgeType.custom:
        return (
          customLabel ?? '',
          customIcon ?? Icons.label,
          customColor?.withValues(alpha: 0.2) ?? Colors.grey.shade100,
          customColor ?? Colors.grey.shade700,
        );
    }
  }
}
