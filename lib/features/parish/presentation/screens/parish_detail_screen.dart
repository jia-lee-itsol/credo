import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/parish_service.dart' as core;

/// 교회 상세 화면
class ParishDetailScreen extends ConsumerWidget {
  final String parishId;

  const ParishDetailScreen({super.key, required this.parishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    // 실제 데이터 조회
    final parishAsync = ref.watch(core.parishByIdProvider(parishId));

    // 즐겨찾기 여부 확인
    final isFavorite =
        currentUser?.favoriteParishIds.contains(parishId) ?? false;

    return parishAsync.when(
      data: (parish) {
        if (parish == null || parish.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('教会詳細')),
            body: const Center(child: Text('教会情報が見つかりませんでした')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 앱바
              _buildSliverAppBar(
                context,
                ref,
                parish,
                primaryColor,
                isFavorite,
              ),

              // 기본 정보
              SliverToBoxAdapter(
                child: _buildBasicInfo(context, parish, primaryColor, parishId),
              ),

              // 미사 시간
              SliverToBoxAdapter(
                child: _buildMassTimeSection(
                  context,
                  theme,
                  primaryColor,
                  parish,
                ),
              ),

              // 하단 여백
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('教会詳細')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('教会詳細')),
        body: Center(child: Text('エラーが発生しました: $error')),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> parish,
    Color primaryColor,
    bool isFavorite,
  ) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          parish['name'] as String? ?? '',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withValues(alpha: 0.3),
                primaryColor.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.church,
              size: 80,
              color: primaryColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: () => _toggleFavorite(context, ref, isFavorite),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    bool isCurrentlyFavorite,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ログインが必要です'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 소속 성당은 즐겨찾기에서 제거할 수 없음
    if (isCurrentlyFavorite && parishId == currentUser.mainParishId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('所属教会はお気に入りから削除できません'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final repository = ref.read(authRepositoryProvider);
    final updatedFavorites = List<String>.from(currentUser.favoriteParishIds);

    if (isCurrentlyFavorite) {
      updatedFavorites.remove(parishId);
    } else {
      updatedFavorites.add(parishId);
    }

    final result = await repository.updateProfile(
      favoriteParishIds: updatedFavorites,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (updatedUser) {
        // authStateProvider를 직접 업데이트하여 즉시 UI 반영
        ref.read(authStateProvider.notifier).state = updatedUser;
        // StreamProvider도 무효화하여 다음 스트림 업데이트 시 최신 데이터 유지
        ref.invalidate(authStateStreamProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyFavorite ? 'お気に入りから削除しました' : 'お気に入りに追加しました',
            ),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Widget _buildBasicInfo(
    BuildContext context,
    Map<String, dynamic> parish,
    Color primaryColor,
    String parishId,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주소
          if (parish['address'] != null) ...[
            InfoRow(
              icon: Icons.location_on,
              title: '住所',
              content:
                  '${parish['prefecture'] as String? ?? ''} ${parish['address'] as String? ?? ''}',
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 16),
          ],

          // 전화번호
          if (parish['phone'] != null &&
              (parish['phone'] as String).isNotEmpty) ...[
            InfoRow(
              icon: Icons.phone,
              title: '電話',
              content: parish['phone'] as String,
              primaryColor: primaryColor,
              onTap: () => _launchPhone(parish['phone'] as String),
            ),
            const SizedBox(height: 16),
          ],

          // 팩스
          if (parish['fax'] != null &&
              (parish['fax'] as String).isNotEmpty) ...[
            InfoRow(
              icon: Icons.fax,
              title: 'FAX',
              content: parish['fax'] as String,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 16),
          ],

          // 웹사이트
          if (parish['website'] != null &&
              (parish['website'] as String).isNotEmpty) ...[
            InfoRow(
              icon: Icons.language,
              title: 'ウェブサイト',
              content: parish['website'] as String,
              primaryColor: primaryColor,
              onTap: () => _launchUrl(parish['website'] as String),
            ),
            const SizedBox(height: 16),
          ],

          // 지도 버튼과 커뮤니티 버튼 (주소가 있으면 표시)
          if (parish['address'] != null)
            Row(
              children: [
                // 지도 버튼
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // 주소를 검색어로 사용하여 Google Maps에서 검색
                      final address =
                          '${parish['prefecture'] as String? ?? ''} ${parish['address'] as String? ?? ''}';
                      _launchMapByAddress(address);
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('地図アプリで開く'),
                  ),
                ),
                const SizedBox(width: 12),
                // 커뮤니티 버튼
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // parishId를 명시적으로 사용하여 올바른 교회로 이동
                      // 클로저에서 최신 값을 사용하도록 보장
                      final targetParishId = parishId;

                      // 현재 경로가 myPage 내부인 경우 go 사용, 아니면 push 사용
                      final currentLocation = GoRouterState.of(
                        context,
                      ).matchedLocation;

                      if (currentLocation.startsWith('/my-page')) {
                        // myPage 내부에서 접근한 경우 go 사용 (StatefulShellRoute 브랜치로 이동)
                        // 전체 경로를 명시적으로 지정하여 올바른 parishId 전달
                        // GoRouter는 자동으로 URL 인코딩/디코딩을 처리함
                        context.go('/community/$targetParishId');
                      } else {
                        // parish 브랜치에서 접근한 경우 push 사용
                        context.push(
                          AppRoutes.communityParishPath(targetParishId),
                        );
                      }
                    },
                    icon: const Icon(Icons.forum),
                    label: const Text('コミュニティ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMassTimeSection(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    Map<String, dynamic> parish,
  ) {
    final massTime = parish['massTime'] as String?;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ミサ時間',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          massTime == null || massTime.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'ミサ時間情報がありません',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : _buildMassTimeCards(theme, massTime),
        ],
      ),
    );
  }

  Widget _buildMassTimeCards(ThemeData theme, String massTime) {
    final separated = _separateMassTimeByLanguage(massTime);
    final japaneseGroups = separated['japanese'] as List<Map<String, String>>;
    final foreignGroups = separated['foreign'] as List<Map<String, String>>;

    final hasForeign = foreignGroups.isNotEmpty;

    if (!hasForeign) {
      // 외국어 미사가 없으면 단일 카드
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildMassTimeByWeekday(theme, japaneseGroups),
        ),
      );
    }

    // 외국어 미사가 있으면 두 개의 카드를 세로로 표시
    return Column(
      children: [
        // 위: 일본어 미사
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMassTimeByWeekday(theme, japaneseGroups),
          ),
        ),
        const SizedBox(height: 12),
        // 아래: 외국어 미사
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMassTimeByWeekday(theme, foreignGroups),
          ),
        ),
      ],
    );
  }

  Widget _buildMassTimeByWeekday(
    ThemeData theme,
    List<Map<String, String>> weekdayGroups,
  ) {
    if (weekdayGroups.isEmpty) {
      return Text(
        'ミサ時間情報がありません',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weekdayGroups.map((group) {
        final weekday = group['weekday'] as String;
        final times = group['times'] as String;
        final timesList = times.split('\n');

        // 일요일을 "主日"로 표시
        final displayWeekday = weekday == '日' ? '主日' : weekday;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 요일 제목
              Text(
                displayWeekday,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              // 미사 시간들
              ...timesList.map((time) {
                final languageCode = _detectLanguageCode(time);

                // 외국어 미사인 경우 순서를 "언어 시간"으로 변경
                final displayText = languageCode != null
                    ? _reorderForeignMassText(time, languageCode)
                    : time;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (languageCode != null) ...[
                        // 국기 이모지
                        Text(
                          _getFlagEmoji(languageCode),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                      ],
                      // 미사 시간 텍스트
                      Expanded(
                        child: Text(
                          displayText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 미사 시간을 일본어와 외국어로 분리
  Map<String, List<Map<String, String>>> _separateMassTimeByLanguage(
    String massTime,
  ) {
    final allGroups = _parseMassTimeByWeekday(massTime);
    final japaneseGroups = <Map<String, String>>[];
    final foreignGroups = <Map<String, String>>[];

    for (final group in allGroups) {
      final weekday = group['weekday'] as String;
      final times = group['times'] as String;
      final timesList = times.split('\n');

      final japaneseTimes = <String>[];
      final foreignTimes = <String>[];

      for (final time in timesList) {
        if (_isForeignLanguageMass(time)) {
          foreignTimes.add(time);
        } else {
          japaneseTimes.add(time);
        }
      }

      if (japaneseTimes.isNotEmpty) {
        japaneseGroups.add({
          'weekday': weekday,
          'times': japaneseTimes.join('\n'),
        });
      }

      if (foreignTimes.isNotEmpty) {
        foreignGroups.add({
          'weekday': weekday,
          'times': foreignTimes.join('\n'),
        });
      }
    }

    return {'japanese': japaneseGroups, 'foreign': foreignGroups};
  }

  /// 외국어 미사인지 확인
  bool _isForeignLanguageMass(String time) {
    return _detectLanguageCode(time) != null;
  }

  /// 언어 코드 감지
  String? _detectLanguageCode(String time) {
    final languagePatterns = {
      'EN': [r'英語', r'English'],
      'ES': [r'スペイン語', r'Spanish', r'Español'],
      'CN': [r'中国語', r'Chinese', r'中文'],
      'PH': [r'フィリピン', r'Filipino'],
      'PT': [r'ポルトガル', r'Português'],
      'KR': [r'韓国語', r'Korean'],
      'FR': [r'フランス語', r'French', r'Français'],
      'DE': [r'ドイツ語', r'German', r'Deutsch'],
      'IT': [r'イタリア語', r'Italian', r'Italiano'],
    };

    for (final entry in languagePatterns.entries) {
      for (final pattern in entry.value) {
        if (RegExp(pattern, caseSensitive: false).hasMatch(time)) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// 언어 코드에 해당하는 국기 이모지 반환
  String _getFlagEmoji(String languageCode) {
    const flagMap = {
      'EN': '🇺🇸',
      'ES': '🇪🇸',
      'CN': '🇨🇳',
      'PH': '🇵🇭',
      'PT': '🇵🇹',
      'KR': '🇰🇷',
      'FR': '🇫🇷',
      'DE': '🇩🇪',
      'IT': '🇮🇹',
    };
    return flagMap[languageCode] ?? '🌐';
  }

  /// 외국어 미사 텍스트를 "언어 시간 주일정보" 순서로 재정렬
  String _reorderForeignMassText(String time, String languageCode) {
    // 언어 이름 추출
    final languageNames = {
      'EN': '英語',
      'ES': 'スペイン語',
      'CN': '中国語',
      'PH': 'フィリピン語',
      'PT': 'ポルトガル語',
      'KR': '韓国語',
      'FR': 'フランス語',
      'DE': 'ドイツ語',
      'IT': 'イタリア語',
    };
    final languageName = languageNames[languageCode] ?? '';

    // 시간 추출 (예: "14:00")
    final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(time);
    final timeStr = timeMatch?.group(1) ?? '';

    // 특정 주일 정보 추출 (예: "第1・第3日曜")
    final noteMatch = RegExp(r'(第\d+[・・]?第\d+日曜|第\d+日曜)').firstMatch(time);
    final noteStr = noteMatch?.group(1) ?? '';

    // 순서: 언어명 + 시간 + (특정 주일 정보)
    // 형식: "언어 시간 주일정보"
    if (noteStr.isNotEmpty) {
      return '$languageName $timeStr $noteStr';
    } else {
      return '$languageName $timeStr';
    }
  }

  List<Map<String, String>> _parseMassTimeByWeekday(String massTime) {
    final weekdayMap = <String, List<String>>{};

    // " / "로 분리
    final parts = massTime.split(' / ');

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;

      // 평일 처리 (개별 요일 포함)
      if (trimmed.startsWith('平日：') || trimmed.startsWith('平日:')) {
        final content = trimmed.replaceFirst(RegExp(r'^平日[：:]'), '').trim();
        _parseWeekdayContent(content, weekdayMap);
      }
      // 토요일 처리
      else if (trimmed.startsWith('土曜日：') ||
          trimmed.startsWith('土曜日:') ||
          trimmed.startsWith('土曜：') ||
          trimmed.startsWith('土曜:')) {
        final times = trimmed.replaceFirst(RegExp(r'^土曜日?[：:]'), '').trim();
        _addToWeekdayMap('土', times, weekdayMap);
      }
      // 일요일 처리
      else if (trimmed.startsWith('主日：') ||
          trimmed.startsWith('主日:') ||
          trimmed.startsWith('日曜：') ||
          trimmed.startsWith('日曜:')) {
        final times = trimmed.replaceFirst(RegExp(r'^(主日|日曜)[：:]'), '').trim();
        _addToWeekdayMap('日', times, weekdayMap);
      }
      // 특정 주일 처리 (예: 第2・第4日曜14:00)
      else if (trimmed.contains('日曜') && RegExp(r'第\d+').hasMatch(trimmed)) {
        _addToWeekdayMap('日', trimmed, weekdayMap);
      }
      // 개별 요일 처리 (月曜, 火曜, 水曜, 木曜, 金曜)
      else if (RegExp(r'^[月火水木金]曜').hasMatch(trimmed)) {
        final match = RegExp(r'^([月火水木金]曜)[：:]?(.*)$').firstMatch(trimmed);
        if (match != null) {
          final weekdayJa = match.group(1)!;
          final times = match.group(2)?.trim() ?? '';
          final weekday = _convertWeekdayJaToDisplay(weekdayJa);
          _addToWeekdayMap(weekday, times, weekdayMap);
        }
      }
      // 기타 (언어 표시가 포함된 경우 등)
      else {
        _addToWeekdayMap('その他', trimmed, weekdayMap);
      }
    }

    // 요일별로 그룹화하여 리스트 생성
    final groups = <Map<String, String>>[];
    final weekdayOrder = {
      '月': 0,
      '火': 1,
      '水': 2,
      '木': 3,
      '金': 4,
      '月-金': 5,
      '土': 6,
      '日': 7,
      'その他': 8,
    };

    // 월-금이 모두 있고 시간이 같으면 "月-金"으로 합치기
    final weekdayKeys = ['月', '火', '水', '木', '金'];
    final hasAllWeekdays = weekdayKeys.every(
      (key) => weekdayMap.containsKey(key),
    );

    if (hasAllWeekdays) {
      // 모든 평일의 시간이 같은지 확인
      final firstTimes = weekdayMap['月']!;
      final allSame = weekdayKeys.every((key) {
        final times = weekdayMap[key]!;
        return times.length == firstTimes.length &&
            times.every((time) => firstTimes.contains(time));
      });

      if (allSame) {
        // 월-금을 "月-金"으로 합치기
        for (final key in weekdayKeys) {
          weekdayMap.remove(key);
        }
        weekdayMap['月-金'] = firstTimes;
      }
    }

    // 정렬된 요일 목록 생성
    final sortedWeekdays = weekdayMap.keys.toList()
      ..sort((a, b) {
        final orderA = weekdayOrder[a] ?? 8;
        final orderB = weekdayOrder[b] ?? 8;
        return orderA.compareTo(orderB);
      });

    for (final weekday in sortedWeekdays) {
      final timesList = weekdayMap[weekday]!;
      // 같은 요일의 여러 항목을 줄바꿈으로 구분하여 표시
      groups.add({'weekday': weekday, 'times': timesList.join('\n')});
    }

    return groups;
  }

  /// 평일 내용을 파싱하여 개별 요일로 분리
  void _parseWeekdayContent(
    String content,
    Map<String, List<String>> weekdayMap,
  ) {
    // "火、木、土曜 6:30、水曜 10:00、金曜 18:30" 형식 처리
    // "、"로 분리하여 각 항목 처리
    final items = content.split('、');
    bool hasIndividualWeekday = false;

    for (final item in items) {
      final trimmed = item.trim();
      if (trimmed.isEmpty) continue;

      // 개별 요일 패턴 확인 (예: "水曜 10:00" 또는 "火、木、土曜 6:30")
      // 토요일(土)도 포함 가능
      final singleWeekdayPattern = RegExp(r'^([月火水木金土]曜)[：:]?\s*(.+)$');
      final multipleWeekdayPattern = RegExp(r'^([月火水木金土]、?)+曜[：:]?\s*(.+)$');

      final singleMatch = singleWeekdayPattern.firstMatch(trimmed);
      final multipleMatch = multipleWeekdayPattern.firstMatch(trimmed);

      if (singleMatch != null) {
        // 단일 요일 (예: "水曜 10:00")
        final weekdayJa = singleMatch.group(1)!;
        final times = singleMatch.group(2)?.trim() ?? '';
        final weekday = _convertWeekdayJaToDisplay(weekdayJa);
        _addToWeekdayMap(weekday, times, weekdayMap);
        hasIndividualWeekday = true;
      } else if (multipleMatch != null) {
        // 복수 요일 (예: "火、木、土曜 6:30")
        final weekdaysStr = multipleMatch.group(1)!;
        final times = multipleMatch.group(2)?.trim() ?? '';
        // "火、木、土"를 개별 요일로 분리
        final weekdayMatches = RegExp(r'[月火水木金土]').allMatches(weekdaysStr);
        for (final wdMatch in weekdayMatches) {
          final weekdayJa = '${wdMatch.group(0)}曜';
          final weekday = _convertWeekdayJaToDisplay(weekdayJa);
          _addToWeekdayMap(weekday, times, weekdayMap);
        }
        hasIndividualWeekday = true;
      }
    }

    // 개별 요일이 없으면 모든 평일(月~金)에 동일한 시간 적용
    if (!hasIndividualWeekday && content.isNotEmpty) {
      // 시간 추출
      final times = RegExp(r'\d{1,2}:\d{2}').allMatches(content);
      if (times.isNotEmpty) {
        // 월~금요일 각각에 시간 추가
        for (final weekdayJa in ['月曜', '火曜', '水曜', '木曜', '金曜']) {
          final weekday = _convertWeekdayJaToDisplay(weekdayJa);
          for (final timeMatch in times) {
            _addToWeekdayMap(weekday, timeMatch.group(0)!, weekdayMap);
          }
        }
      } else {
        // 시간 형식이 아닌 경우 원본 내용을 유지
        _addToWeekdayMap('月-金', content, weekdayMap);
      }
    }
  }

  /// 일본어 요일을 표시 형식으로 변환
  String _convertWeekdayJaToDisplay(String weekdayJa) {
    const weekdayMap = {
      '月曜': '月',
      '火曜': '火',
      '水曜': '水',
      '木曜': '木',
      '金曜': '金',
      '土曜': '土',
    };
    return weekdayMap[weekdayJa] ?? weekdayJa;
  }

  /// 요일 맵에 항목 추가
  void _addToWeekdayMap(
    String weekday,
    String times,
    Map<String, List<String>> weekdayMap,
  ) {
    if (times.isEmpty) return;
    if (!weekdayMap.containsKey(weekday)) {
      weekdayMap[weekday] = [];
    }
    weekdayMap[weekday]!.add(times);
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// 좌표를 사용하여 Google Maps 열기
  Future<void> _launchMapByCoordinates(double lat, double lon) async {
    final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// 주소를 사용하여 Google Maps 열기
  Future<void> _launchMapByAddress(String address) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
