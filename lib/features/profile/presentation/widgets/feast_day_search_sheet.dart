import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../data/providers/saint_feast_day_providers.dart';

/// 축일 검색 시트
class FeastDaySearchSheet extends ConsumerStatefulWidget {
  final Color primaryColor;
  final String? selectedFeastDayId;
  final void Function(SaintFeastDayModel) onFeastDaySelected;
  final void Function(String name, int month, int day)? onDirectInput;

  const FeastDaySearchSheet({
    super.key,
    required this.primaryColor,
    this.selectedFeastDayId,
    required this.onFeastDaySelected,
    this.onDirectInput,
  });

  @override
  ConsumerState<FeastDaySearchSheet> createState() =>
      _FeastDaySearchSheetState();
}

class _FeastDaySearchSheetState extends ConsumerState<FeastDaySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDirectInputDialog(BuildContext context, AppLocalizations l10n) {
    final nameController = TextEditingController();
    int selectedMonth = 1;
    int selectedDay = 1;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.profile.directInputDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 세례명 입력
                    Text(
                      l10n.auth.selectFeastDayTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'ペトロ、マリア、ヨハネ...',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 축일 선택
                    Text(
                      l10n.profile.directInputTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: selectedMonth,
                            decoration: InputDecoration(
                              labelText: l10n.profile.month,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: List.generate(12, (i) => i + 1)
                                .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text('$m'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedMonth = value ?? 1;
                                final maxDay = _getDaysInMonth(selectedMonth);
                                if (selectedDay > maxDay) {
                                  selectedDay = maxDay;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: selectedDay,
                            decoration: InputDecoration(
                              labelText: l10n.profile.day,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: List.generate(
                                    _getDaysInMonth(selectedMonth), (i) => i + 1)
                                .map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text('$d'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedDay = value ?? 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.common.cancel),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    // 직접 입력한 성인 모델 생성
                    final saint = SaintFeastDayModel(
                      month: selectedMonth,
                      day: selectedDay,
                      name: name,
                      nameEn: name,
                      type: 'custom',
                      isJapanese: false,
                      greeting: '',
                    );

                    Navigator.pop(dialogContext);
                    widget.onFeastDaySelected(saint);
                  },
                  child: Text(
                    l10n.common.confirm,
                    style: TextStyle(color: widget.primaryColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _getDaysInMonth(int month) {
    const daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final allSaintsAsync = ref.watch(_allSaintsProvider);

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
            l10n.auth.selectFeastDayTitle,
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
              hintText: l10n.search.saintSearchHint,
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

        const SizedBox(height: 8),

        // 직접 입력 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () => _showDirectInputDialog(context, l10n),
            icon: Icon(Icons.edit, color: widget.primaryColor),
            label: Text(
              l10n.profile.directInput,
              style: TextStyle(color: widget.primaryColor),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: widget.primaryColor),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 성인 목록
        Expanded(
          child: allSaintsAsync.when(
            data: (allSaints) {
              // 검색 필터링
              final filteredSaints = _searchQuery.isEmpty
                  ? allSaints
                  : allSaints.where((saint) {
                      final name = saint.name.toLowerCase();
                      final nameEn = saint.nameEn?.toLowerCase() ?? '';
                      final query = _searchQuery.toLowerCase();
                      return name.contains(query) || nameEn.contains(query);
                    }).toList();

              if (filteredSaints.isEmpty) {
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
                itemCount: filteredSaints.length,
                itemBuilder: (context, index) {
                  final saint = filteredSaints[index];
                  final feastDayId = '${saint.month}-${saint.day}';
                  final isSelected = widget.selectedFeastDayId == feastDayId;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: widget.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.celebration,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      saint.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${saint.month}月${saint.day}日',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: widget.primaryColor)
                        : null,
                    onTap: () => widget.onFeastDaySelected(saint),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) {
              final l10n = ref.read(appLocalizationsSyncProvider);
              return Center(child: Text('${l10n.common.error}: $error'));
            },
          ),
        ),
      ],
    );
  }
}

/// 모든 성인 목록 Provider
final _allSaintsProvider = FutureProvider<List<SaintFeastDayModel>>((
  ref,
) async {
  final repository = ref.read(saintFeastDayRepositoryProvider);
  final result = await repository.loadSaintsFeastDays();
  return result.fold(
    (_) => <SaintFeastDayModel>[],
    (saints) => saints
        .map(
          (saint) => SaintFeastDayModel(
            month: saint.month,
            day: saint.day,
            name: saint.name,
            nameEn: saint.nameEnglish,
            type: saint.type,
            isJapanese: saint.isJapanese,
            greeting: saint.greeting,
            description: saint.description,
          ),
        )
        .toList(),
  );
});
