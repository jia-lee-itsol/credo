import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/parish_colors.dart';

/// 교회 검색바 위젯
class ParishSearchBar extends ConsumerWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const ParishSearchBar({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 49.361,
      decoration: BoxDecoration(
        color: ParishColors.neutral50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ParishColors.neutral200, width: 0.69),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          letterSpacing: -0.31,
        ),
        decoration: InputDecoration(
          hintText: '教会名、地域で検索',
          hintStyle: const TextStyle(
            color: Color(0x800A0A0A),
            fontSize: 16,
            letterSpacing: -0.31,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Icon(Icons.search, size: 20, color: Color(0x800A0A0A)),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
