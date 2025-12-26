import 'package:flutter/material.dart';

/// 정보 표시용 공통 위젯
/// 아이콘 + 타이틀 + 콘텐츠 형태 (탭 가능)
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color primaryColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.primaryColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: onTap != null ? primaryColor : null,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
