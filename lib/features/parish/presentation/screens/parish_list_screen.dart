import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/parish_service.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../constants/parish_colors.dart';
import '../widgets/parish_card.dart';
import '../widgets/parish_filter_chip.dart';

/// 교회 목록 화면
class ParishListScreen extends ConsumerStatefulWidget {
  const ParishListScreen({super.key});

  @override
  ConsumerState<ParishListScreen> createState() => _ParishListScreenState();
}

class _ParishListScreenState extends ConsumerState<ParishListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _sortByDistance = true;

  // 필터 상태
  Set<String> _selectedPrefectures = {};
  bool _onlyCathedrals = false;
  bool _onlyWithMassTime = false;
  bool _onlyTodayMass = false;
  bool _onlyForeignLanguageMass = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('教会を探す'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.myPage);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                backgroundImage: currentUser?.profileImageUrl != null
                    ? NetworkImage(currentUser!.profileImageUrl!)
                    : null,
                child: currentUser?.profileImageUrl == null
                    ? Icon(Icons.person, size: 20, color: primaryColor)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 영역 (검색바와 필터)
            _buildHeader(),

            // 교회 목록
            Expanded(child: _buildParishList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: ParishColors.neutral200, width: 0.69),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색 바
          _buildSearchBar(),

          const SizedBox(height: 16),

          // 필터 & 정렬 버튼
          Row(
            children: [
              // 필터 버튼
              ParishFilterChip(
                icon: Icons.tune,
                label: 'フィルター',
                isSelected: _hasActiveFilters,
                onTap: _showFilterBottomSheet,
              ),
              const SizedBox(width: 8),
              // 정렬 버튼
              ParishFilterChip(
                icon: Icons.swap_vert,
                label: '距離順',
                isSelected: _sortByDistance,
                onTap: () {
                  setState(() {
                    _sortByDistance = !_sortByDistance;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 49.361,
      decoration: BoxDecoration(
        color: ParishColors.neutral50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ParishColors.neutral200, width: 0.69),
      ),
      child: TextField(
        controller: _searchController,
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
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildParishList() {
    final allParishesAsync = ref.watch(allParishesProvider);

    return allParishesAsync.when(
      data: (allParishesMap) {
        final allParishes = <Map<String, dynamic>>[];
        allParishesMap.forEach((dioceseId, parishes) {
          for (final parish in parishes) {
            allParishes.add(parish);
          }
        });

        if (allParishes.isEmpty) {
          return _buildEmptyState();
        }

        final filteredParishes = _getFilteredParishes(allParishes);

        if (filteredParishes.isEmpty &&
            (_searchController.text.isNotEmpty || _hasActiveFilters)) {
          return _buildNoResultState();
        }

        return ListView.separated(
          key: const PageStorageKey('parishList'),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          itemCount: filteredParishes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final parish = filteredParishes[index];
            final diocese = parish['diocese'] as String? ?? '';
            final name = parish['name'] as String? ?? '';
            final parishId = '$diocese-$name';
            return ParishCard(
              key: ValueKey('parishCard_$parishId'),
              parish: parish,
              onTap: () {
                context.push(AppRoutes.parishDetailPath(parishId));
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('エラーが発生しました: $error')),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildNoResultState() {
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

  List<Map<String, dynamic>> _getFilteredParishes(
    List<Map<String, dynamic>> allParishes,
  ) {
    final searchQuery = _searchController.text.toLowerCase().trim();

    return allParishes.where((parish) {
      // 검색어 필터
      if (searchQuery.isNotEmpty) {
        final name = (parish['name'] as String? ?? '').toLowerCase();
        final address = (parish['address'] as String? ?? '').toLowerCase();
        final prefecture = (parish['prefecture'] as String? ?? '')
            .toLowerCase();
        if (!name.contains(searchQuery) &&
            !address.contains(searchQuery) &&
            !prefecture.contains(searchQuery)) {
          return false;
        }
      }

      // 도도부현 필터
      if (_selectedPrefectures.isNotEmpty) {
        final prefecture = parish['prefecture'] as String? ?? '';
        if (!_selectedPrefectures.contains(prefecture)) {
          return false;
        }
      }

      // 주교좌 성당만 보기
      if (_onlyCathedrals) {
        final isCathedral = parish['isCathedral'] as bool? ?? false;
        if (!isCathedral) {
          return false;
        }
      }

      // 미사 시간이 있는 성당만 보기
      if (_onlyWithMassTime) {
        final massTime = parish['massTime'] as String?;
        if (massTime == null || massTime.trim().isEmpty) {
          return false;
        }
      }

      // 오늘 미사가 있는 성당만 보기
      if (_onlyTodayMass) {
        final massTime = parish['massTime'] as String?;
        if (massTime == null || massTime.trim().isEmpty) {
          return false;
        }
        if (!_hasMassToday(massTime)) {
          return false;
        }
      }

      // 외국어 미사가 있는 성당만 보기
      if (_onlyForeignLanguageMass) {
        final massTime = parish['massTime'] as String?;
        if (massTime == null || massTime.trim().isEmpty) {
          return false;
        }
        if (!_hasForeignLanguageMass(massTime)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _FilterBottomSheet(
          selectedPrefectures: _selectedPrefectures,
          onlyCathedrals: _onlyCathedrals,
          onlyWithMassTime: _onlyWithMassTime,
          onlyTodayMass: _onlyTodayMass,
          onlyForeignLanguageMass: _onlyForeignLanguageMass,
          onApply: (prefectures, cathedrals, massTime, todayMass, foreignMass) {
            setState(() {
              _selectedPrefectures = prefectures;
              _onlyCathedrals = cathedrals;
              _onlyWithMassTime = massTime;
              _onlyTodayMass = todayMass;
              _onlyForeignLanguageMass = foreignMass;
            });
            Navigator.of(context).pop();
          },
          onReset: () {
            setState(() {
              _selectedPrefectures = {};
              _onlyCathedrals = false;
              _onlyWithMassTime = false;
              _onlyTodayMass = false;
              _onlyForeignLanguageMass = false;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  bool get _hasActiveFilters {
    return _selectedPrefectures.isNotEmpty ||
        _onlyCathedrals ||
        _onlyWithMassTime ||
        _onlyTodayMass ||
        _onlyForeignLanguageMass;
  }

  /// 오늘 미사가 있는지 확인
  bool _hasMassToday(String massTime) {
    final today = DateTime.now();
    final weekday = today.weekday; // 1 = 월요일, 7 = 일요일

    // 일요일 (主日)
    if (weekday == 7) {
      return massTime.contains('主日') || massTime.contains('日曜');
    }
    // 토요일
    if (weekday == 6) {
      return massTime.contains('土曜日') || massTime.contains('土曜');
    }
    // 평일 (월~금)
    if (weekday >= 1 && weekday <= 5) {
      return massTime.contains('平日');
    }

    return false;
  }

  /// 외국어 미사가 있는지 확인
  bool _hasForeignLanguageMass(String massTime) {
    // 영어, 스페인어, 한국어, 중국어 등 외국어 미사 키워드 확인
    return massTime.contains('英語') ||
        massTime.contains('English') ||
        massTime.contains('スペイン語') ||
        massTime.contains('Spanish') ||
        massTime.contains('韓国語') ||
        massTime.contains('Korean') ||
        massTime.contains('中国語') ||
        massTime.contains('Chinese') ||
        massTime.contains('フィリピン語') ||
        massTime.contains('Portuguese') ||
        massTime.contains('ポルトガル語');
  }
}

/// 필터 바텀시트 위젯
class _FilterBottomSheet extends StatefulWidget {
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

  const _FilterBottomSheet({
    required this.selectedPrefectures,
    required this.onlyCathedrals,
    required this.onlyWithMassTime,
    required this.onlyTodayMass,
    required this.onlyForeignLanguageMass,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
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
      final allParishesMap = await ParishService.loadAllParishes();
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
