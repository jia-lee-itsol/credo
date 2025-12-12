import 'package:flutter/material.dart';
import '../../../../core/data/services/parish_service.dart' as core;
import '../constants/parish_colors.dart';

/// 교회 필터 바텀시트 위젯
class ParishFilterBottomSheet extends StatefulWidget {
  final Set<String> selectedPrefectures;
  final bool onlyCathedrals;
  final bool onlyWithMassTime;
  final bool onlyTodayMass;
  final bool onlyForeignLanguageMass;
  final void Function(
    Set<String> prefectures,
    bool cathedrals,
    bool massTime,
    bool todayMass,
    bool foreignMass,
  )
  onApply;
  final VoidCallback onReset;

  const ParishFilterBottomSheet({
    super.key,
    required this.selectedPrefectures,
    required this.onlyCathedrals,
    required this.onlyWithMassTime,
    required this.onlyTodayMass,
    required this.onlyForeignLanguageMass,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ParishFilterBottomSheet> createState() =>
      _ParishFilterBottomSheetState();
}

class _ParishFilterBottomSheetState extends State<ParishFilterBottomSheet> {
  late Set<String> _tempSelectedPrefectures;
  late bool _tempOnlyCathedrals;
  late bool _tempOnlyWithMassTime;
  late bool _tempOnlyTodayMass;
  late bool _tempOnlyForeignLanguageMass;

  List<String> _prefectures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tempSelectedPrefectures = Set.from(widget.selectedPrefectures);
    _tempOnlyCathedrals = widget.onlyCathedrals;
    _tempOnlyWithMassTime = widget.onlyWithMassTime;
    _tempOnlyTodayMass = widget.onlyTodayMass;
    _tempOnlyForeignLanguageMass = widget.onlyForeignLanguageMass;
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    try {
      // 도도부현 목록 추출
      final allParishesMap = await core.ParishService.loadAllParishes();
      final prefectureSet = <String>{};
      for (final parishes in allParishesMap.values) {
        for (final parish in parishes) {
          final prefecture = parish['prefecture'] as String?;
          if (prefecture != null && prefecture.isNotEmpty) {
            prefectureSet.add(prefecture);
          }
        }
      }
      _prefectures = prefectureSet.toList()..sort();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 핸들 바
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'フィルター',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_hasChanges)
                    TextButton(
                      onPressed: widget.onReset,
                      child: const Text('リセット'),
                    ),
                ],
              ),
            ),

            // 필터 내용
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // 도도부현 필터
                        _buildSectionTitle('都道府県'),
                        const SizedBox(height: 12),
                        _buildPrefectureFilter(),
                        const SizedBox(height: 24),

                        // 미사 필터 칩
                        _buildSectionTitle('ミサ'),
                        const SizedBox(height: 12),
                        _buildMassFilterChips(),
                        const SizedBox(height: 24),

                        // 옵션 필터
                        _buildSectionTitle('オプション'),
                        const SizedBox(height: 12),
                        _buildOptionFilter(),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),

            // 하단 버튼
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onReset,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('リセット'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: ParishColors.purple600,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('適用'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: ParishColors.neutral800,
      ),
    );
  }

  Widget _buildPrefectureFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _prefectures.map((prefecture) {
        final isSelected = _tempSelectedPrefectures.contains(prefecture);

        return FilterChip(
          label: Text(prefecture),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _tempSelectedPrefectures.add(prefecture);
              } else {
                _tempSelectedPrefectures.remove(prefecture);
              }
            });
          },
          selectedColor: ParishColors.purple100,
          checkmarkColor: ParishColors.purple600,
          labelStyle: TextStyle(
            color: isSelected
                ? ParishColors.purple600
                : ParishColors.neutral700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMassFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('今日のミサあり'),
          selected: _tempOnlyTodayMass,
          onSelected: (selected) {
            setState(() {
              _tempOnlyTodayMass = selected;
            });
          },
          selectedColor: ParishColors.purple100,
          checkmarkColor: ParishColors.purple600,
          labelStyle: TextStyle(
            color: _tempOnlyTodayMass
                ? ParishColors.purple600
                : ParishColors.neutral700,
            fontWeight: _tempOnlyTodayMass
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        FilterChip(
          label: const Text('外国語ミサあり'),
          selected: _tempOnlyForeignLanguageMass,
          onSelected: (selected) {
            setState(() {
              _tempOnlyForeignLanguageMass = selected;
            });
          },
          selectedColor: ParishColors.purple100,
          checkmarkColor: ParishColors.purple600,
          labelStyle: TextStyle(
            color: _tempOnlyForeignLanguageMass
                ? ParishColors.purple600
                : ParishColors.neutral700,
            fontWeight: _tempOnlyForeignLanguageMass
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionFilter() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('大聖堂のみ'),
          subtitle: const Text('大聖堂のみを表示'),
          value: _tempOnlyCathedrals,
          onChanged: (value) {
            setState(() {
              _tempOnlyCathedrals = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('ミサ時間あり'),
          subtitle: const Text('ミサ時間情報がある教会のみを表示'),
          value: _tempOnlyWithMassTime,
          onChanged: (value) {
            setState(() {
              _tempOnlyWithMassTime = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  bool get _hasChanges {
    return _tempSelectedPrefectures.length !=
            widget.selectedPrefectures.length ||
        !_tempSelectedPrefectures.containsAll(widget.selectedPrefectures) ||
        !widget.selectedPrefectures.containsAll(_tempSelectedPrefectures) ||
        _tempOnlyCathedrals != widget.onlyCathedrals ||
        _tempOnlyWithMassTime != widget.onlyWithMassTime ||
        _tempOnlyTodayMass != widget.onlyTodayMass ||
        _tempOnlyForeignLanguageMass != widget.onlyForeignLanguageMass;
  }

  void _applyFilters() {
    widget.onApply(
      _tempSelectedPrefectures,
      _tempOnlyCathedrals,
      _tempOnlyWithMassTime,
      _tempOnlyTodayMass,
      _tempOnlyForeignLanguageMass,
    );
  }
}
