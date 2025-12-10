import 'package:flutter/material.dart';

import '../constants/parish_colors.dart';

/// 필터 칩 위젯
class ParishFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ParishFilterChip({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 35.986,
          padding: const EdgeInsets.only(left: 16, right: 16),
          decoration: BoxDecoration(
            color: ParishColors.neutral100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: ParishColors.neutral700),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: ParishColors.neutral700,
                  letterSpacing: -0.15,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
