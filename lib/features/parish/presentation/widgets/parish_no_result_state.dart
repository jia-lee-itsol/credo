import 'package:flutter/material.dart';
import '../constants/parish_colors.dart';

/// 검색 결과가 없을 때 표시되는 위젯
class ParishNoResultState extends StatelessWidget {
  const ParishNoResultState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: ParishColors.neutral600),
          SizedBox(height: 16),
          Text(
            '検索結果が見つかりませんでした',
            style: TextStyle(fontSize: 16, color: ParishColors.neutral600),
          ),
        ],
      ),
    );
  }
}
