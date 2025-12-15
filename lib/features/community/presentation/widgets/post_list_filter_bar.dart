import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';

/// 게시글 목록 필터 타입
enum PostListFilterType { latest, popular, myPosts }

/// 게시글 목록 필터 바 위젯
class PostListFilterBar extends ConsumerWidget {
  final PostListFilterType filterType;
  final ValueChanged<PostListFilterType> onFilterChanged;
  final Color primaryColor;

  const PostListFilterBar({
    super.key,
    required this.filterType,
    required this.onFilterChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.read(appLocalizationsSyncProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: l10n.community.filter.latest,
            isSelected: filterType == PostListFilterType.latest,
            onTap: () => onFilterChanged(PostListFilterType.latest),
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.community.filter.popular,
            isSelected: filterType == PostListFilterType.popular,
            onTap: () => onFilterChanged(PostListFilterType.popular),
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.community.filter.myPosts,
            isSelected: filterType == PostListFilterType.myPosts,
            onTap: () => onFilterChanged(PostListFilterType.myPosts),
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
