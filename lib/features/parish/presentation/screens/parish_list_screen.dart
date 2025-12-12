import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../core/data/services/parish_service.dart' as core;
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/location_provider.dart';
import '../../../../core/utils/location_utils.dart';
import '../constants/parish_colors.dart';
import '../widgets/parish_card.dart';
import '../widgets/parish_filter_chip.dart';
import '../widgets/parish_search_bar.dart';
import '../widgets/parish_empty_state.dart';
import '../widgets/parish_no_result_state.dart';
import '../widgets/parish_filter_bottom_sheet.dart';

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
  void initState() {
    super.initState();
    // 화면이 로드될 때 위치 권한 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationPermission();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 위치 권한 확인 및 요청
  Future<void> _checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();

    // 권한이 이미 허용된 경우
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return;
    }

    // 권한이 거부된 경우 다이얼로그 표시
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      await _showLocationPermissionDialog();
    }
  }

  /// 위치 권한 요청 다이얼로그 표시
  Future<void> _showLocationPermissionDialog() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      // 영구적으로 거부된 경우 설정으로 이동 안내
      if (!mounted) return;
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('位置情報の許可が必要です'),
          content: const Text(
            '近くの教会を探すために位置情報の許可が必要です。\n設定から位置情報の許可を有効にしてください。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('設定を開く'),
            ),
          ],
        ),
      );

      if (shouldOpen == true && mounted) {
        await Geolocator.openAppSettings();
      }
      return;
    }

    // 권한 요청 다이얼로그
    if (!mounted) return;
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('位置情報の利用'),
        content: const Text('近くの教会を探すために位置情報の利用を許可してください。\n教会までの距離表示にも使用されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('今はしない'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('許可する'),
          ),
        ],
      ),
    );

    if (shouldRequest == true && mounted) {
      await _requestLocationPermission();
    }
  }

  /// 위치 권한 요청
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (!mounted) return;

    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('位置情報の許可が必要です。')));
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('位置情報の許可が必要です'),
          content: const Text('設定から位置情報の許可を有効にしてください。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('設定を開く'),
            ),
          ],
        ),
      );

      if (shouldOpen == true && mounted) {
        await Geolocator.openAppSettings();
      }
      return;
    }

    // 권한이 허용된 경우 위치 정보 새로고침
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Provider 새로고침
      ref.invalidate(currentLocationProvider);
      // 위치를 가져오면 캐시에 저장
      final locationAsync = ref.read(currentLocationProvider);
      locationAsync.whenData((position) {
        if (position != null) {
          ref.read(cachedLocationProvider.notifier).state = position;
        }
      });
    }
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
          ParishSearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
          ),

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
                onTap: () async {
                  if (!_sortByDistance) {
                    // 거리순 정렬을 활성화하려면 위치 권한 확인
                    final permission = await Geolocator.checkPermission();
                    if (permission != LocationPermission.whileInUse &&
                        permission != LocationPermission.always) {
                      // 권한이 없으면 권한 요청 다이얼로그 표시
                      await _showLocationPermissionDialog();
                      return;
                    }
                  }
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

  Widget _buildParishList() {
    final allParishesAsync = ref.watch(core.allParishesProvider);

    return allParishesAsync.when(
      data: (allParishesMap) {
        final allParishes = <Map<String, dynamic>>[];
        allParishesMap.forEach((dioceseId, parishes) {
          for (final parish in parishes) {
            allParishes.add(parish);
          }
        });

        if (allParishes.isEmpty) {
          return const ParishEmptyState();
        }

        var filteredParishes = _getFilteredParishes(allParishes);

        // 거리순 정렬
        if (_sortByDistance) {
          filteredParishes = _sortParishesByDistance(filteredParishes);
        }

        if (filteredParishes.isEmpty &&
            (_searchController.text.isNotEmpty || _hasActiveFilters)) {
          return const ParishNoResultState();
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
        return ParishFilterBottomSheet(
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

  /// 거리순으로 교회 정렬
  List<Map<String, dynamic>> _sortParishesByDistance(
    List<Map<String, dynamic>> parishes,
  ) {
    // 거리 정보가 있는 교회와 없는 교회를 분리
    final parishesWithDistance =
        <({Map<String, dynamic> parish, double distance})>[];
    final parishesWithoutDistance = <Map<String, dynamic>>[];

    final locationAsync = ref.read(currentLocationProvider);
    final cachedLocation = ref.read(cachedLocationProvider);
    final userPosition = cachedLocation ?? locationAsync.valueOrNull;

    if (userPosition == null) {
      // 사용자 위치가 없으면 정렬하지 않음
      return parishes;
    }

    for (final parish in parishes) {
      // 좌표가 있으면 직접 계산
      final lat = parish['latitude'] as double?;
      final lon = parish['longitude'] as double?;

      if (lat != null && lon != null) {
        // 좌표가 있으면 직접 계산
        final distance = LocationUtils.calculateDistance(
          userPosition.latitude,
          userPosition.longitude,
          lat,
          lon,
        );
        parishesWithDistance.add((parish: parish, distance: distance));
      } else {
        // 좌표가 없으면 거리 계산 불가 (나중에 Provider를 통해 계산되지만 정렬에는 사용하지 않음)
        parishesWithoutDistance.add(parish);
      }
    }

    // 거리순 정렬
    parishesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    // 거리가 있는 교회를 먼저, 거리가 없는 교회를 나중에 배치
    return [
      ...parishesWithDistance.map((p) => p.parish),
      ...parishesWithoutDistance,
    ];
  }
}
