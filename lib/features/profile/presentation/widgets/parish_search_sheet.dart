import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../core/data/services/parish_service.dart' as core;

/// 교회 검색 시트 (프로필 편집용)
class ParishSearchSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final Color primaryColor;
  final String? selectedParishId;
  final void Function(String parishId, String parishName) onParishSelected;

  const ParishSearchSheet({
    super.key,
    required this.scrollController,
    required this.primaryColor,
    this.selectedParishId,
    required this.onParishSelected,
  });

  @override
  ConsumerState<ParishSearchSheet> createState() => _ParishSearchSheetState();
}

class _ParishSearchSheetState extends ConsumerState<ParishSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final allParishesAsync = ref.watch(core.allParishesProvider);

    return Column(
      children: [
        // 핸들
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),

        // 타이틀
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.auth.selectParishTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 검색바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.search.parishSearchHint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        const SizedBox(height: 16),

        // 교회 목록
        Expanded(
          child: allParishesAsync.when(
            data: (allParishesMap) {
              final allParishes = <Map<String, dynamic>>[];
              allParishesMap.forEach((dioceseId, parishes) {
                for (final parish in parishes) {
                  final parishId = '$dioceseId-${parish['name']}';
                  allParishes.add({...parish, 'parishId': parishId});
                }
              });

              // 검색 필터링
              final filteredParishes = _searchQuery.isEmpty
                  ? allParishes
                  : allParishes.where((parish) {
                      final name = (parish['name'] as String? ?? '')
                          .toLowerCase();
                      final address = (parish['address'] as String? ?? '')
                          .toLowerCase();
                      final query = _searchQuery.toLowerCase();
                      return name.contains(query) || address.contains(query);
                    }).toList();

              if (filteredParishes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.search.noResults,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: widget.scrollController,
                itemCount: filteredParishes.length,
                itemBuilder: (context, index) {
                  final parish = filteredParishes[index];
                  final name = parish['name'] as String? ?? '';
                  final address = parish['address'] as String? ?? '';
                  final parishId = parish['parishId'] as String? ?? '';
                  final isSelected = widget.selectedParishId == parishId;

                  return ListTile(
                    key: ValueKey(parishId),
                    leading: CircleAvatar(
                      backgroundColor: widget.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.church,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: widget.primaryColor)
                        : Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                    onTap: () => widget.onParishSelected(parishId, name),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('${l10n.common.error}: $error')),
          ),
        ),
      ],
    );
  }
}
