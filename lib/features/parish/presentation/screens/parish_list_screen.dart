import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/parish_service.dart';

// Figma 디자인에 맞춘 색상 상수
const _neutral50 = Color(0xFFFAFAFA);
const _neutral100 = Color(0xFFF5F5F5);
const _neutral200 = Color(0xFFE5E5E5);
const _neutral600 = Color(0xFF525252);
const _neutral700 = Color(0xFF404040);
const _neutral800 = Color(0xFF262626);
const _purple100 = Color(0xFFF3E8FF);
const _purple600 = Color(0xFF8200DB);
const _blue50 = Color(0xFFEFF6FF);
const _blue600 = Color(0xFF1447E6);

/// 교회 목록 화면
class ParishListScreen extends ConsumerStatefulWidget {
  const ParishListScreen({super.key});

  @override
  ConsumerState<ParishListScreen> createState() => _ParishListScreenState();
}

class _ParishListScreenState extends ConsumerState<ParishListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _sortByDistance = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 영역
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: _neutral200, width: 0.69),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 타이틀
                  const Text(
                    '教会を探す',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _neutral800,
                      letterSpacing: 0.07,
                      height: 32 / 24,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 검색 바
                  Container(
                    height: 49.361,
                    decoration: BoxDecoration(
                      color: _neutral50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _neutral200, width: 0.69),
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
                          child: Icon(
                            Icons.search,
                            size: 20,
                            color: Color(0x800A0A0A),
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 필터 & 정렬 버튼
                  Row(
                    children: [
                      // 필터 버튼
                      _FilterChip(
                        icon: Icons.tune,
                        label: 'フィルター',
                        onTap: _showFilterBottomSheet,
                      ),
                      const SizedBox(width: 8),
                      // 정렬 버튼
                      _FilterChip(
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
            ),

            // 교회 목록
            Expanded(child: _buildParishList()),
          ],
        ),
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

        if (filteredParishes.isEmpty && _searchController.text.isNotEmpty) {
          return _buildNoResultState();
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          itemCount: filteredParishes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final parish = filteredParishes[index];
            return _ParishCard(
              parish: parish,
              onTap: () {
                final diocese = parish['diocese'] as String? ?? '';
                final name = parish['name'] as String? ?? '';
                final parishId = '$diocese-$name';
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.church_outlined, size: 64, color: _neutral600),
          const SizedBox(height: 16),
          const Text(
            '教会データが見つかりませんでした',
            style: TextStyle(fontSize: 16, color: _neutral600),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: _neutral600),
          const SizedBox(height: 16),
          const Text(
            '検索結果が見つかりませんでした',
            style: TextStyle(fontSize: 16, color: _neutral600),
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
      if (searchQuery.isNotEmpty) {
        final name = (parish['name'] as String? ?? '').toLowerCase();
        final address = (parish['address'] as String? ?? '').toLowerCase();
        if (!name.contains(searchQuery) && !address.contains(searchQuery)) {
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
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'フィルター',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                '準備中...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 필터 칩 위젯
class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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
            color: _neutral100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: _neutral700),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: _neutral700,
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

/// 교회 카드 위젯
class _ParishCard extends StatelessWidget {
  final Map<String, dynamic> parish;
  final VoidCallback onTap;

  const _ParishCard({required this.parish, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = parish['name'] as String? ?? '';
    final address = parish['address'] as String? ?? '';
    final massTime = parish['massTime'] as String? ?? '';

    // 거리 (임시)
    final distance = '1.2km';

    // 오늘/내일 미사 시간 추출
    final nextMass = _getNextMassTime(massTime);

    // 지원 언어 추출
    final languages = _getSupportedLanguages(massTime);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(15.99),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _neutral200, width: 0.69),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 교회 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 교회 이름
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _neutral800,
                        letterSpacing: -0.31,
                        height: 24 / 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // 주소
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: _neutral600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: _neutral600,
                              letterSpacing: -0.15,
                              height: 20 / 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 거리, 미사 시간, 언어 태그 - 한 줄 가로 배치
                    Row(
                      children: [
                        // 거리 태그
                        _Tag(
                          text: distance,
                          backgroundColor: _purple100,
                          textColor: _purple600,
                        ),
                        const SizedBox(width: 8),
                        // 미사 시간 태그
                        if (nextMass.isNotEmpty) ...[
                          _Tag(
                            text: nextMass,
                            backgroundColor: _neutral100,
                            textColor: _neutral600,
                          ),
                          const SizedBox(width: 8),
                        ],
                        // 언어 태그들
                        ...languages.map(
                          (lang) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _OutlinedTag(
                              text: lang,
                              textColor: _blue600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 오른쪽: 화살표
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 20, color: _neutral600),
            ],
          ),
        ),
      ),
    );
  }

  String _getNextMassTime(String massTime) {
    if (massTime.isEmpty) return '';

    // 간단하게 주일 미사 시간 추출
    final parts = massTime.split(' / ');
    for (final part in parts) {
      if (part.contains('主日') || part.contains('日曜')) {
        // 시간만 추출
        final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(part);
        if (timeMatch != null) {
          return 'ミサ: 今日 ${timeMatch.group(1)}';
        }
      }
    }

    // 첫 번째 시간 반환
    final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(massTime);
    if (timeMatch != null) {
      return 'ミサ: 今日 ${timeMatch.group(1)}';
    }

    return '';
  }

  List<String> _getSupportedLanguages(String massTime) {
    final languages = <String>[];

    // 일본어는 기본
    if (massTime.isNotEmpty) {
      languages.add('JP');
    }

    // 영어
    if (massTime.contains('英語') || massTime.contains('English')) {
      languages.add('EN');
    }

    // 필리핀어
    if (massTime.contains('フィリピン') || massTime.contains('Filipino')) {
      languages.add('PH');
    }

    // 포르투갈어
    if (massTime.contains('ポルトガル') || massTime.contains('Português')) {
      languages.add('PT');
    }

    // 한국어
    if (massTime.contains('韓国語') || massTime.contains('Korean')) {
      languages.add('KR');
    }

    return languages;
  }
}

/// 태그 위젯 (배경색 있음)
class _Tag extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _Tag({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// 아웃라인 태그 위젯 (테두리만 있음)
class _OutlinedTag extends StatelessWidget {
  final String text;
  final Color textColor;

  const _OutlinedTag({
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
