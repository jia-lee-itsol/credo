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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: primaryColor.withValues(alpha: 0.08),
        highlightColor: primaryColor.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 아이콘 컨테이너
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 14),
              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onTap != null ? primaryColor : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // 트레일링
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
