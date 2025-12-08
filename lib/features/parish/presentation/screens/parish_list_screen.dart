import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../core/data/services/parish_service.dart';

/// 교회 목록 화면
class ParishListScreen extends ConsumerStatefulWidget {
  const ParishListScreen({super.key});

  @override
  ConsumerState<ParishListScreen> createState() => _ParishListScreenState();
}

class _ParishListScreenState extends ConsumerState<ParishListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedPrefecture;
  String? _selectedDiocese;
  String? _selectedLanguage;
  String? _selectedTodayMass; // 'morning' or 'afternoon'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('教会検索'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 바
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '教会名・住所で検索',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // 전체 교회 수 표시
          Consumer(
            builder: (context, ref, child) {
              final allParishesAsync = ref.watch(allParishesProvider);
              return allParishesAsync.when(
                data: (allParishesMap) {
                  int totalCount = 0;
                  allParishesMap.forEach((dioceseId, parishes) {
                    totalCount += parishes.length;
                  });
                  
                  final filteredParishes = _getFilteredParishes(
                    allParishesMap.values.expand((p) => p).toList(),
                  );
                  
                  if (totalCount > 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '全${totalCount}件中 ${filteredParishes.length}件を表示',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),

          // 필터 칩
          if (_selectedPrefecture != null ||
              _selectedDiocese != null ||
              _selectedLanguage != null ||
              _selectedTodayMass != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedPrefecture != null)
                    Chip(
                      label: Text(
                        _selectedPrefecture!,
                        style: TextStyle(color: primaryColor),
                      ),
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      deleteIcon: Icon(Icons.close, size: 18, color: primaryColor),
                      onDeleted: () {
                        setState(() {
                          _selectedPrefecture = null;
                        });
                      },
                    ),
                  if (_selectedDiocese != null)
                    Chip(
                      label: Text(
                        _selectedDiocese!,
                        style: TextStyle(color: primaryColor),
                      ),
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      deleteIcon: Icon(Icons.close, size: 18, color: primaryColor),
                      onDeleted: () {
                        setState(() {
                          _selectedDiocese = null;
                        });
                      },
                    ),
                  if (_selectedLanguage != null)
                    Chip(
                      label: Text(
                        _selectedLanguage!,
                        style: TextStyle(color: primaryColor),
                      ),
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      deleteIcon: Icon(Icons.close, size: 18, color: primaryColor),
                      onDeleted: () {
                        setState(() {
                          _selectedLanguage = null;
                        });
                      },
                    ),
                  if (_selectedTodayMass != null)
                    Chip(
                      label: Text(
                        _selectedTodayMass == 'morning' ? '今日のミサ（午前）' : '今日のミサ（午後）',
                        style: TextStyle(color: primaryColor),
                      ),
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      deleteIcon: Icon(Icons.close, size: 18, color: primaryColor),
                      onDeleted: () {
                        setState(() {
                          _selectedTodayMass = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // 교회 목록 (검색 및 필터 적용)
          Expanded(child: _buildParishList(primaryColor)),
        ],
      ),
    );
  }

  /// 검색 및 필터링된 교회 목록 생성
  List<Map<String, dynamic>> _getFilteredParishes(
    List<Map<String, dynamic>> allParishes,
  ) {
    final searchQuery = _searchController.text.toLowerCase().trim();

    return allParishes.where((parish) {
      // 검색어 필터링
      if (searchQuery.isNotEmpty) {
        final name = (parish['name'] as String? ?? '').toLowerCase();
        final address = (parish['address'] as String? ?? '').toLowerCase();
        if (!name.contains(searchQuery) && !address.contains(searchQuery)) {
          return false;
        }
      }

      // 도도부현 필터링
      if (_selectedPrefecture != null) {
        final prefecture = parish['prefecture'] as String? ?? '';
        if (prefecture != _selectedPrefecture) {
          return false;
        }
      }

      // 교구 필터링
      if (_selectedDiocese != null) {
        final diocese = parish['diocese'] as String? ?? '';
        // 교구명 매핑 (예: "札幌教区" -> "sapporo")
        final dioceseId = _getDioceseIdFromName(_selectedDiocese!);
        if (diocese != dioceseId) {
          return false;
        }
      }

      // 미사 언어 필터링 (현재는 실제 데이터에 언어 정보가 없으므로 일단 통과)
      // TODO: 실제 데이터에 언어 정보가 추가되면 필터링 구현

      // 오늘의 미사 필터링
      if (_selectedTodayMass != null) {
        if (!_hasTodayMass(parish['massTime'] as String? ?? '', _selectedTodayMass!)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// 오늘의 미사가 있는지 확인
  bool _hasTodayMass(String massTime, String timeOfDay) {
    if (massTime.isEmpty) return false;

    final now = DateTime.now();
    final todayWeekday = now.weekday % 7; // 0=일요일, 1=월요일, ..., 6=토요일
    final weekOfMonth = ((now.day - 1) ~/ 7) + 1; // 이번 달의 몇 번째 주인지

    // 요일명 매핑
    final weekdayKeywords = {
      0: ['日', '主日', '日曜'],
      1: ['月', '月曜', '平日'],
      2: ['火', '火曜', '平日'],
      3: ['水', '水曜', '平日'],
      4: ['木', '木曜', '平日'],
      5: ['金', '金曜', '平日'],
      6: ['土', '土曜', '土曜日'],
    };

    final todayKeywords = weekdayKeywords[todayWeekday] ?? [];

    // 오늘 요일에 해당하는 미사 시간 찾기
    final parts = massTime.split(' / ');
    final todayMassTimes = <String>[];

    for (final part in parts) {
      final trimmed = part.trim();
      bool isToday = false;

      // 오늘 요일 키워드 확인
      for (final keyword in todayKeywords) {
        if (trimmed.contains(keyword)) {
          // "平日"는 특별 처리 (월~금 모두 포함)
          if (keyword == '平日' && todayWeekday >= 1 && todayWeekday <= 5) {
            isToday = true;
            break;
          } else if (keyword != '平日') {
            isToday = true;
            break;
          }
        }
      }

      // 특정 주일 미사 확인 (예: "第2・第4日曜")
      if (todayWeekday == 0 && trimmed.contains('日曜')) { // 일요일인 경우
        // "第1", "第2", "第3", "第4", "第5" 확인
        for (int week = 1; week <= 5; week++) {
          if (trimmed.contains('第$week') && weekOfMonth == week) {
            isToday = true;
            break;
          }
        }
        // "第1・第3" 같은 형식 처리
        if (trimmed.contains('第') && trimmed.contains('・')) {
          final weekMatches = RegExp(r'第(\d)').allMatches(trimmed);
          for (final match in weekMatches) {
            final week = int.parse(match.group(1)!);
            if (week == weekOfMonth) {
              isToday = true;
              break;
            }
          }
        }
      }

      if (isToday) {
        todayMassTimes.add(trimmed);
      }
    }

    // "主日"가 포함된 모든 부분도 확인 (일요일인 경우)
    if (todayWeekday == 0) {
      for (final part in parts) {
        final trimmed = part.trim();
        if (trimmed.contains('主日') && !todayMassTimes.contains(trimmed)) {
          todayMassTimes.add(trimmed);
        }
      }
    }

    if (todayMassTimes.isEmpty) return false;

    // 시간 추출 및 오전/오후 확인
    final timePattern = RegExp(r'(\d{1,2}):(\d{2})');
    bool hasMorning = false;
    bool hasAfternoon = false;

    for (final massTimeText in todayMassTimes) {
      final matches = timePattern.allMatches(massTimeText);
      for (final match in matches) {
        final hour = int.parse(match.group(1)!);
        if (hour < 12) {
          hasMorning = true;
        } else {
          hasAfternoon = true;
        }
      }
    }

    if (timeOfDay == 'morning') {
      return hasMorning;
    } else if (timeOfDay == 'afternoon') {
      return hasAfternoon;
    }

    return false;
  }

  /// 교구명에서 교구 ID 추출
  String _getDioceseIdFromName(String dioceseName) {
    final mapping = {
      '札幌教区': 'sapporo',
      '仙台教区': 'sendai',
      '新潟教区': 'niigata',
      'さいたま教区': 'saitama',
      '東京大司教区': 'tokyo',
      '横浜教区': 'yokohama',
      '名古屋教区': 'nagoya',
      '京都教区': 'kyoto',
      '大阪高松大司教区': 'osaka',
      '広島教区': 'hiroshima',
      '福岡教区': 'fukuoka',
      '長崎大司教区': 'nagasaki',
      '大分教区': 'oita',
      '鹿児島教区': 'kagoshima',
      '那覇教区': 'naha',
    };
    return mapping[dioceseName] ?? '';
  }

  Widget _buildParishList(Color primaryColor) {
    final allParishesAsync = ref.watch(allParishesProvider);

    return allParishesAsync.when(
      data: (allParishesMap) {
        // 모든 교구의 교회를 하나의 리스트로 합치기
        final allParishes = <Map<String, dynamic>>[];
        allParishesMap.forEach((dioceseId, parishes) {
          for (final parish in parishes) {
            allParishes.add(parish);
          }
        });

        // 데이터가 없으면 메시지 표시
        if (allParishes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.church_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '教会データが見つかりませんでした',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final filteredParishes = _getFilteredParishes(allParishes);

        // 검색어나 필터가 있을 때만 "검색 결과 없음" 메시지 표시
        final hasSearchOrFilter = _searchController.text.isNotEmpty ||
            _selectedPrefecture != null ||
            _selectedDiocese != null ||
            _selectedLanguage != null;

        if (filteredParishes.isEmpty && hasSearchOrFilter) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '検索結果が見つかりませんでした',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '別のキーワードで検索してください',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredParishes.length,
          itemBuilder: (context, index) {
            final parish = filteredParishes[index];
            final name = parish['name'] as String? ?? '';
            final address = parish['address'] as String? ?? '';
            final massTime = parish['massTime'] as String? ?? '';
            final isCathedral = parish['isCathedral'] as bool? ?? false;
            final diocese = parish['diocese'] as String? ?? '';
            
            // parishId 생성: "diocese-name"
            final parishId = '$diocese-$name';
            
            return _ParishCard(
              name: name,
              address: address,
              distance: '0.0km', // TODO: 실제 거리 계산
              massTime: massTime,
              isCathedral: isCathedral,
              primaryColor: primaryColor,
              onTap: () {
                context.push(AppRoutes.parishDetailPath(parishId));
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final primaryColor = ref.watch(liturgyPrimaryColorProvider);
            // 선택된 상태일 때 전례력 색상 사용 (더 진한 버전)
            final selectedColor = Color.fromRGBO(
              (primaryColor.red * 0.75).round().clamp(0, 255),
              (primaryColor.green * 0.75).round().clamp(0, 255),
              (primaryColor.blue * 0.75).round().clamp(0, 255),
              1.0,
            );
            
            return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Text('絞り込み', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),

              // 교구 선택
              Text('教区', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allDioceses
                    .map(
                      (diocese) {
                        final isSelected = _selectedDiocese == diocese;
                        return ChoiceChip(
                          label: Text(
                            diocese,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: selectedColor,
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.grey[200],
                          onSelected: (selected) {
                            setState(() {
                              _selectedDiocese = selected ? diocese : null;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    )
                    .toList(),
              ),

            const SizedBox(height: 24),

            // 도도부현 선택
            Text('都道府県', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allPrefectures
                  .map(
                    (pref) {
                      final isSelected = _selectedPrefecture == pref;
                      return ChoiceChip(
                        label: Text(
                          pref,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: selectedColor,
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.grey[200],
                        onSelected: (selected) {
                          setState(() {
                            _selectedPrefecture = selected ? pref : null;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  )
                  .toList(),
            ),

            const SizedBox(height: 24),

            // 오늘의 미사 선택
            Text('今日のミサ', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(
                    '午前',
                    style: TextStyle(
                      color: _selectedTodayMass == 'morning' ? Colors.white : Colors.black87,
                      fontWeight: _selectedTodayMass == 'morning' ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  selected: _selectedTodayMass == 'morning',
                  selectedColor: selectedColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.grey[200],
                  onSelected: (selected) {
                    setState(() {
                      _selectedTodayMass = selected ? 'morning' : null;
                    });
                    Navigator.pop(context);
                  },
                ),
                ChoiceChip(
                  label: Text(
                    '午後',
                    style: TextStyle(
                      color: _selectedTodayMass == 'afternoon' ? Colors.white : Colors.black87,
                      fontWeight: _selectedTodayMass == 'afternoon' ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  selected: _selectedTodayMass == 'afternoon',
                  selectedColor: selectedColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.grey[200],
                  onSelected: (selected) {
                    setState(() {
                      _selectedTodayMass = selected ? 'afternoon' : null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 미사 언어 선택
            Text('ミサ言語', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['日本語', 'English', 'Filipino', 'Português', '한국어']
                  .map(
                    (lang) {
                      final isSelected = _selectedLanguage == lang;
                      return ChoiceChip(
                        label: Text(
                          lang,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: selectedColor,
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.grey[200],
                        onSelected: (selected) {
                          setState(() {
                            _selectedLanguage = selected ? lang : null;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  )
                  .toList(),
            ),

            const SizedBox(height: 32),

            // 리셋 버튼
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedPrefecture = null;
                  _selectedDiocese = null;
                  _selectedLanguage = null;
                  _selectedTodayMass = null;
                });
                Navigator.pop(context);
              },
              child: const Text('条件をクリア'),
            ),
          ],
        ),
      );
          },
        );
      },
    );
  }
}

/// 교회 카드 위젯
class _ParishCard extends StatelessWidget {
  final String name;
  final String address;
  final String distance;
  final String massTime;
  final bool isCathedral;
  final Color primaryColor;
  final VoidCallback onTap;

  const _ParishCard({
    required this.name,
    required this.address,
    required this.distance,
    required this.massTime,
    this.isCathedral = false,
    required this.primaryColor,
    required this.onTap,
  });

  /// 외국어 미사가 있는지 확인
  bool _hasForeignLanguageMass() {
    final foreignLanguageKeywords = [
      '英語',
      'English',
      'english',
      'スペイン語',
      'Spanish',
      'spanish',
      '中国語',
      'Chinese',
      'chinese',
      '韓国語',
      'Korean',
      'korean',
      'フィリピン語',
      'Filipino',
      'filipino',
      'ポルトガル語',
      'Portuguese',
      'portuguese',
      '国際',
      'International',
      'international',
    ];
    
    return foreignLanguageKeywords.any(
      (keyword) => massTime.contains(keyword),
    );
  }

  /// 주일 미사 시간만 추출
  String _getSundayMassTime() {
    if (massTime.isEmpty) return '';
    
    // "主日" 또는 "日"으로 시작하는 부분 찾기
    final parts = massTime.split(' / ');
    final sundayParts = parts.where((part) {
      final trimmed = part.trim();
      return trimmed.startsWith('主日') || 
             trimmed.startsWith('日') ||
             trimmed.contains('主日');
    }).toList();
    
    if (sundayParts.isEmpty) {
      // 주일 미사가 명시되지 않은 경우 빈 문자열 반환
      return '';
    }
    
    return sundayParts.join(' / ');
  }

  /// 전체 미사 시간 다이얼로그 표시
  void _showFullMassTimeDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.access_time, color: primaryColor),
            const SizedBox(width: 8),
            const Text('ミサ時間'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            massTime.isEmpty ? 'ミサ時間情報がありません' : massTime,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '閉じる',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.church, color: primaryColor),
              ),
              const SizedBox(width: 12),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isCathedral)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.star,
                              size: 16,
                              color: primaryColor,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _getSundayMassTime().isEmpty 
                                ? 'ミサ時間情報がありません'
                                : _getSundayMassTime(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_hasForeignLanguageMass()) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.language,
                              size: 14,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                    // 더보기 버튼 (전체 미사 시간이 주일 미사와 다를 때만 표시)
                    if (massTime.isNotEmpty && 
                        _getSundayMassTime().isNotEmpty &&
                        massTime != _getSundayMassTime()) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _showFullMassTimeDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'もっと見る',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 거리
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    distance,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 일본의 모든 도도부현 (47개)
const _allPrefectures = [
  '北海道',
  '青森県',
  '岩手県',
  '宮城県',
  '秋田県',
  '山形県',
  '福島県',
  '茨城県',
  '栃木県',
  '群馬県',
  '埼玉県',
  '千葉県',
  '東京都',
  '神奈川県',
  '新潟県',
  '富山県',
  '石川県',
  '福井県',
  '山梨県',
  '長野県',
  '岐阜県',
  '静岡県',
  '愛知県',
  '三重県',
  '滋賀県',
  '京都府',
  '大阪府',
  '兵庫県',
  '奈良県',
  '和歌山県',
  '鳥取県',
  '島根県',
  '岡山県',
  '広島県',
  '山口県',
  '徳島県',
  '香川県',
  '愛媛県',
  '高知県',
  '福岡県',
  '佐賀県',
  '長崎県',
  '熊本県',
  '大分県',
  '宮崎県',
  '鹿児島県',
  '沖縄県',
];

// 일본의 모든 교구 (15개)
const _allDioceses = [
  '札幌教区',
  '仙台教区',
  '新潟教区',
  'さいたま教区',
  '東京大司教区',
  '横浜教区',
  '名古屋教区',
  '京都教区',
  '大阪高松大司教区',
  '広島教区',
  '福岡教区',
  '長崎大司教区',
  '大分教区',
  '鹿児島教区',
  '那覇教区',
];
