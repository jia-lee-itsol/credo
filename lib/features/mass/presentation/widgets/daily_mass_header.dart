import 'package:flutter/material.dart';

/// 매일미사 날짜 헤더 위젯
class DailyMassHeader extends StatelessWidget {
  final String date;
  final Color primaryColor;
  final VoidCallback onDateTap;

  const DailyMassHeader({
    super.key,
    required this.date,
    required this.primaryColor,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              date,
              style: theme.textTheme.titleMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_month, color: primaryColor),
            onPressed: onDateTap,
            tooltip: '날짜 선택',
          ),
        ],
      ),
    );
  }
}

