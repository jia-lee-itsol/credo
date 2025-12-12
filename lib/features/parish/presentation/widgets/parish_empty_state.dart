import 'package:flutter/material.dart';
import '../constants/parish_colors.dart';

/// 교회 목록이 비어있을 때 표시되는 위젯
class ParishEmptyState extends StatelessWidget {
  const ParishEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.church_outlined, size: 64, color: ParishColors.neutral600),
          SizedBox(height: 16),
          Text(
            '教会データが見つかりませんでした',
            style: TextStyle(fontSize: 16, color: ParishColors.neutral600),
          ),
        ],
      ),
    );
  }
}
