import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/app_localizations.dart';
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
    final l10n = ref.watch(appLocalizationsSyncProvider);
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
            appBar: AppBar(title: Text(l10n.parish.detail)),
            body: Center(child: Text(l10n.parish.notFound)),
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
                child: _buildBasicInfo(
                  context,
                  ref,
                  parish,
                  primaryColor,
                  parishId,
                  l10n,
                ),
              ),

              // 미사 시간
              SliverToBoxAdapter(
                child: _buildMassTimeSection(
                  context,
                  theme,
                  primaryColor,
                  parish,
                  l10n,
                ),
              ),

              // 하단 여백
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.parish.detail)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.parish.detail)),
        body: Center(child: Text('${l10n.community.errorOccurred}: $error')),
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
    final parishName = parish['name'] as String? ?? '';

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          parishName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
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
    final l10n = ref.read(appLocalizationsSyncProvider);
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.auth.loginRequired),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 소속 성당은 즐겨찾기에서 제거할 수 없음
    if (isCurrentlyFavorite && parishId == currentUser.mainParishId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.parish.cannotRemoveParish),
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
              isCurrentlyFavorite
                  ? l10n.common.favoriteRemoved
                  : l10n.common.favoriteAdded,
            ),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Widget _buildBasicInfo(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> parish,
    Color primaryColor,
    String parishId,
    AppLocalizations l10n,
  ) {
    // 웹사이트 (website 또는 officialSite 또는 official_site 필드 확인)
    final website =
        parish['website'] as String? ??
        parish['officialSite'] as String? ??
        parish['official_site'] as String?;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주소
          if (parish['address'] != null) ...[
            InfoRow(
              icon: Icons.location_on,
              title: l10n.parish.detailSection.address,
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
              title: l10n.parish.detailSection.phone,
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
              title: l10n.parish.detailSection.fax,
              content: parish['fax'] as String,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 16),
          ],

          // 웹사이트
          if (website != null && website.isNotEmpty) ...[
            InfoRow(
              icon: Icons.language,
              title: l10n.parish.detailSection.website,
              content: website,
              primaryColor: primaryColor,
              onTap: () => _launchUrl(website),
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
                    label: Text(l10n.parish.openInMap),
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
                    label: Text(l10n.parish.community),
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
    AppLocalizations l10n,
  ) {
    final massTime = parish['massTime'] as String?;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.parish.detailSection.massTime,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          // 경고 문구 (항상 표시, 위에 표시)
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.parish.detailSection.massTimeNotice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          massTime == null || massTime.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.parish.detailSection.noMassTimeInfo,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : _buildMassTimeCards(context, theme, massTime, parish, l10n),
        ],
      ),
    );
  }

  Widget _buildMassTimeCards(
    BuildContext context,
    ThemeData theme,
    String massTime,
    Map<String, dynamic> parish,
    AppLocalizations l10n,
  ) {
    final separated = _separateMassTimeByLanguage(massTime, parish);
    final japaneseGroups = separated['japanese'] as List<Map<String, String>>;
    final foreignGroups = separated['foreign'] as List<Map<String, String>>;

    final hasForeign = foreignGroups.isNotEmpty;

    if (!hasForeign) {
      // 외국어 미사가 없으면 단일 카드
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildMassTimeByWeekday(context, theme, japaneseGroups, l10n),
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
            child: _buildMassTimeByWeekday(
              context,
              theme,
              japaneseGroups,
              l10n,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 아래: 외국어 미사
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMassTimeByWeekday(context, theme, foreignGroups, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildMassTimeByWeekday(
    BuildContext context,
    ThemeData theme,
    List<Map<String, String>> weekdayGroups,
    AppLocalizations l10n,
  ) {
    if (weekdayGroups.isEmpty) {
      return Text(
        l10n.parish.detailSection.noMassTimeInfoInList,
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

        // 요일 표시 변환
        String displayWeekday;
        if (weekday == '日') {
          displayWeekday = l10n.parish.detailSection.weekdays.sunday;
        } else if (weekday == '土') {
          displayWeekday = l10n.parish.detailSection.weekdays.saturday;
        } else if (weekday == '月-金') {
          displayWeekday = l10n.parish.detailSection.weekdays.mondayToFriday;
        } else if (weekday == '月') {
          displayWeekday = l10n.parish.detailSection.weekdays.monday;
        } else if (weekday == '火') {
          displayWeekday = l10n.parish.detailSection.weekdays.tuesday;
        } else if (weekday == '水') {
          displayWeekday = l10n.parish.detailSection.weekdays.wednesday;
        } else if (weekday == '木') {
          displayWeekday = l10n.parish.detailSection.weekdays.thursday;
        } else if (weekday == '金') {
          displayWeekday = l10n.parish.detailSection.weekdays.friday;
        } else if (weekday == 'その他') {
          displayWeekday = l10n.parish.detailSection.other;
        } else {
          displayWeekday = weekday;
        }

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
                String displayText;
                if (languageCode != null) {
                  displayText = _reorderForeignMassText(
                    time,
                    languageCode,
                    l10n,
                  );
                } else {
                  // 일반 미사 시간에서 일본어 표현 번역 처리
                  displayText = _translateJapaneseExpressions(
                    context,
                    time,
                    l10n,
                  );
                }

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
    Map<String, dynamic> parish,
  ) {
    final japaneseGroups = <Map<String, String>>[];
    final foreignGroups = <Map<String, String>>[];

    // massTimes 구조화된 데이터 우선 사용
    final massTimes = parish['massTimes'] as Map<String, dynamic>?;
    final massTimesMap = <String, List<String>>{};
    if (massTimes != null) {
      final weekdayMap = {
        'saturday': '土',
        'sunday': '日',
        'monday': '月',
        'tuesday': '火',
        'wednesday': '水',
        'thursday': '木',
        'friday': '金',
      };

      massTimes.forEach((weekdayKey, timesList) {
        if (timesList is List && timesList.isNotEmpty) {
          final weekday = weekdayMap[weekdayKey] ?? weekdayKey;
          final times = timesList
              .where((t) => t is String && t.isNotEmpty)
              .map((t) => t.toString())
              .toList();
          if (times.isNotEmpty) {
            massTimesMap[weekday] = times;
          }
        }
      });
    }

    // foreignMassTimes 데이터 처리
    final foreignMassTimesMap = <String, List<String>>{};
    final foreignMassTimes =
        parish['foreignMassTimes'] as Map<String, dynamic>?;
    if (foreignMassTimes != null) {
      // 요일별로 foreignMassTimes 데이터 변환
      final weekdayMap = {
        'saturday': '土',
        'sunday': '日',
        'monday': '月-金',
        'tuesday': '月-金',
        'wednesday': '月-金',
        'thursday': '月-金',
        'friday': '月-金',
      };

      foreignMassTimes.forEach((weekdayKey, massTimesList) {
        if (massTimesList is List) {
          final weekday = weekdayMap[weekdayKey] ?? weekdayKey;
          final times = <String>[];

          for (final mt in massTimesList) {
            if (mt is Map<String, dynamic>) {
              final time = mt['time'] as String? ?? '';
              final language = mt['language'] as String? ?? '';
              final note = mt['note'] as String? ?? '';

              // 언어 이름 매핑
              final languageNames = {
                'EN': '英語',
                'ES': 'スペイン語',
                'CN': '中国語',
                'PH': 'フィリピン語',
                'PT': 'ポルトガル語',
                'KR': '韓国語',
                'VI': 'ベトナム語',
                'ID': 'インドネシア語',
                'PL': 'ポーランド語',
                'FR': 'フランス語',
                'DE': 'ドイツ語',
                'IT': 'イタリア語',
              };

              final languageName = languageNames[language] ?? language;
              String timeStr = '$time($languageName)';
              if (note.isNotEmpty) {
                timeStr = '$timeStr($note)';
              }
              times.add(timeStr);
            }
          }

          if (times.isNotEmpty) {
            if (foreignMassTimesMap.containsKey(weekday)) {
              foreignMassTimesMap[weekday]!.addAll(times);
            } else {
              foreignMassTimesMap[weekday] = times;
            }
          }
        }
      });
    }

    // massTimes 구조화된 데이터가 있으면 우선 사용
    if (massTimesMap.isNotEmpty) {
      massTimesMap.forEach((weekday, times) {
        if (times.isNotEmpty) {
          japaneseGroups.add({'weekday': weekday, 'times': times.join('\n')});
        }
      });
    }

    // foreignMassTimes 데이터 추가
    // note가 있는 미사와 없는 미사를 분리하여 표시
    foreignMassTimesMap.forEach((weekday, times) {
      if (times.isNotEmpty) {
        // note가 있는 미사와 없는 미사 분리
        final withNote = <String>[];
        final withoutNote = <String>[];

        for (final time in times) {
          // note가 있는지 확인 (예: "15:00(スペイン語)(第2日曜)")
          if (RegExp(r'\(第\d+[・]?第?\d*日曜\)').hasMatch(time)) {
            withNote.add(time);
          } else {
            withoutNote.add(time);
          }
        }

        // note가 있는 미사는 "主日" 섹션에
        if (withNote.isNotEmpty) {
          foreignGroups.add({'weekday': weekday, 'times': withNote.join('\n')});
        }

        // note가 없는 미사는 "その他" 섹션에
        if (withoutNote.isNotEmpty) {
          foreignGroups.add({
            'weekday': 'その他',
            'times': withoutNote.join('\n'),
          });
        }
      }
    });

    // massTimes와 foreignMassTimes가 없으면 massTime 문자열 파싱 사용 (fallback)
    if (massTimesMap.isEmpty && foreignMassTimesMap.isEmpty) {
      final fallbackGroups = _parseMassTimeByWeekday(massTime);
      for (final group in fallbackGroups) {
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
      'VI': [r'ベトナム語', r'Vietnamese'],
      'ID': [r'インドネシア語', r'Indonesian'],
      'PL': [r'ポーランド語', r'Polish'],
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
      'VI': '🇻🇳',
      'ID': '🇮🇩',
      'PL': '🇵🇱',
      'FR': '🇫🇷',
      'DE': '🇩🇪',
      'IT': '🇮🇹',
    };
    return flagMap[languageCode] ?? '🌐';
  }

  /// 외국어 미사 텍스트를 "언어 시간 주일정보" 순서로 재정렬
  String _reorderForeignMassText(
    String time,
    String languageCode,
    AppLocalizations l10n,
  ) {
    // 언어 이름 추출
    final languageNames = {
      'EN': l10n.parish.detailSection.languages.english,
      'ES': l10n.parish.detailSection.languages.spanish,
      'CN': l10n.parish.detailSection.languages.chinese,
      'PH': l10n.parish.detailSection.languages.filipino,
      'PT': l10n.parish.detailSection.languages.portuguese,
      'KR': l10n.parish.detailSection.languages.korean,
      'VI': l10n.parish.detailSection.languages.vietnamese,
      'ID': l10n.parish.detailSection.languages.indonesian,
      'PL': l10n.parish.detailSection.languages.polish,
      'FR': l10n.parish.detailSection.languages.french,
      'DE': l10n.parish.detailSection.languages.german,
      'IT': l10n.parish.detailSection.languages.italian,
    };
    final languageName = languageNames[languageCode] ?? '';

    // 시간 추출 (예: "14:00")
    final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(time);
    final timeStr = timeMatch?.group(1) ?? '';

    // 특정 주일 정보 추출 및 번역 (예: "第1・第3日曜")
    final noteMatch = RegExp(r'(第\d+[・・]?第\d+日曜|第\d+日曜)').firstMatch(time);
    String noteStr = '';
    if (noteMatch != null) {
      final originalNote = noteMatch.group(1)!;
      // 주일 표기를 번역 키로 변환
      noteStr = _translateSundayNote(originalNote, l10n);
    }

    // 수화 포함 표기 처리
    String signLanguageNote = '';
    if (time.contains('手話付き')) {
      signLanguageNote = '(${l10n.parish.detailSection.withSignLanguage})';
    }

    // 순서: 언어명 + 시간 + (수화 포함) + (특정 주일 정보)
    // 형식: "언어 시간 (수화 포함) 주일정보"
    final parts = <String>[];
    if (languageName.isNotEmpty) parts.add(languageName);
    if (timeStr.isNotEmpty) parts.add(timeStr);
    if (signLanguageNote.isNotEmpty) parts.add(signLanguageNote);
    if (noteStr.isNotEmpty) parts.add(noteStr);

    return parts.join(' ');
  }

  /// 미사 시간 텍스트 내의 일본어 표현들을 번역 처리
  String _translateJapaneseExpressions(
    BuildContext context,
    String time,
    AppLocalizations l10n,
  ) {
    String result = time;

    // "手話付き" 번역 처리
    result = result.replaceAll(
      '手話付き',
      l10n.parish.detailSection.withSignLanguage,
    );

    // "日から土曜日" -> "일요일부터 토요일" 형식 번역
    // 한국어: "일요일부터 토요일", 일본어: "主日から土", 영어: "Sunday to Saturday" 등
    result = result.replaceAllMapped(RegExp(r'日から土曜日'), (match) {
      // 언어별로 적절한 연결어 사용
      final locale = Localizations.localeOf(context);
      if (locale.languageCode == 'ko') {
        return '${l10n.parish.detailSection.weekdays.sunday}부터 ${l10n.parish.detailSection.weekdays.saturday}';
      } else if (locale.languageCode == 'ja') {
        return '${l10n.parish.detailSection.weekdays.sunday}から${l10n.parish.detailSection.weekdays.saturday}';
      } else {
        return '${l10n.parish.detailSection.weekdays.sunday} to ${l10n.parish.detailSection.weekdays.saturday}';
      }
    });

    // "第\d+金曜日" -> 특정 주일 금요일 번역
    result = result.replaceAllMapped(RegExp(r'第(\d+)金曜日'), (match) {
      final weekNumber = match.group(1);
      if (weekNumber == '1') {
        return l10n.parish.detailSection.sundayNote.first.replaceAll(
          '주일',
          '금요일',
        );
      } else if (weekNumber == '2') {
        return l10n.parish.detailSection.sundayNote.second.replaceAll(
          '주일',
          '금요일',
        );
      } else if (weekNumber == '3') {
        return l10n.parish.detailSection.sundayNote.third.replaceAll(
          '주일',
          '금요일',
        );
      } else if (weekNumber == '4') {
        return l10n.parish.detailSection.sundayNote.fourth.replaceAll(
          '주일',
          '금요일',
        );
      }
      return match.group(0) ?? '';
    });

    // 주일 표기도 번역
    result = result.replaceAllMapped(RegExp(r'第\d+[・・]?第\d+日曜|第\d+日曜'), (
      match,
    ) {
      final original = match.group(0);
      if (original != null) {
        return _translateSundayNote(original, l10n);
      }
      return match.group(0) ?? '';
    });

    return result;
  }

  /// 주일 표기를 번역 키로 변환
  String _translateSundayNote(String note, AppLocalizations l10n) {
    if (note.contains('第1') && note.contains('第3')) {
      return l10n.parish.detailSection.sundayNote.firstAndThird;
    } else if (note.contains('第2') && note.contains('第4')) {
      return l10n.parish.detailSection.sundayNote.secondAndFourth;
    } else if (note.contains('第1')) {
      return l10n.parish.detailSection.sundayNote.first;
    } else if (note.contains('第2')) {
      return l10n.parish.detailSection.sundayNote.second;
    } else if (note.contains('第3')) {
      return l10n.parish.detailSection.sundayNote.third;
    } else if (note.contains('第4')) {
      return l10n.parish.detailSection.sundayNote.fourth;
    }
    return note; // 번역할 수 없으면 원본 반환
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
      // 외국어 미사 처리 (예: "ベトナム語：土19:30、日15:00", "英語ミサ：12:00", "インドネシア語：16:30(第2・第4日曜)")
      else if ((trimmed.contains('語') || trimmed.contains('ミサ')) &&
          trimmed.contains('：')) {
        // "언어語：土19:30、日15:00" 또는 "언어語：16:30(第2・第4日曜)" 또는 "언어ミサ：12:00" 형식 파싱
        final langMatch = RegExp(r'^(.+[語ミサ])[：:]\s*(.+)$').firstMatch(trimmed);
        if (langMatch != null) {
          final languagePart = langMatch.group(1)!;
          final timesPart = langMatch.group(2)!;

          // "土19:30、日15:00" 형식에서 각 요일과 시간 추출
          final timeMatches = RegExp(
            r'([土日])(\d{1,2}:\d{2})',
          ).allMatches(timesPart);

          if (timeMatches.isNotEmpty) {
            // 각 요일에 시간 추가
            for (final match in timeMatches) {
              final weekdayJa = match.group(1)!;
              final time = match.group(2)!;
              final weekday = weekdayJa == '土' ? '土' : '日';
              final timeWithLang = '$time($languagePart)';
              _addToWeekdayMap(weekday, timeWithLang, weekdayMap);
            }
          } else {
            // "16:30(第2・第4日曜)" 또는 "12:00" 형식 처리
            // 시간과 주일 정보 추출
            final timeWithNoteMatch = RegExp(
              r'(\d{1,2}:\d{2})\s*(\(第\d+[・]?第?\d*日曜\))?',
            ).firstMatch(timesPart);

            if (timeWithNoteMatch != null) {
              final time = timeWithNoteMatch.group(1)!;
              final notePart = timeWithNoteMatch.group(2) ?? '';
              // 언어 정보를 시간 뒤에 추가 (예: "16:30(インドネシア語) (第2・第4日曜)")
              final timeWithLang = notePart.isNotEmpty
                  ? '$time($languagePart) $notePart'
                  : '$time($languagePart)';
              _addToWeekdayMap('日', timeWithLang, weekdayMap);
            } else {
              // 형식이 맞지 않으면 기타로
              _addToWeekdayMap('その他', trimmed, weekdayMap);
            }
          }
        } else {
          _addToWeekdayMap('その他', trimmed, weekdayMap);
        }
      }
      // 기타
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

      // 개별 요일 패턴 확인 (예: "水曜 10:00" 또는 "火、木、土曜 6:30" 또는 "火曜日07:00")
      // 토요일(土)도 포함 가능
      // "火曜日" 형식도 처리하기 위해 "曜日?" 패턴 사용
      final singleWeekdayPattern = RegExp(r'^([月火水木金土]曜日?)[：:]?\s*(.+)$');
      final multipleWeekdayPattern = RegExp(r'^([月火水木金土]、?)+曜日?[：:]?\s*(.+)$');

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
      '月曜日': '月',
      '火曜日': '火',
      '水曜日': '水',
      '木曜日': '木',
      '金曜日': '金',
      '土曜日': '土',
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
    // URL에 프로토콜이 없으면 https:// 추가
    String urlWithProtocol = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      urlWithProtocol = 'https://$url';
    }

    final uri = Uri.parse(urlWithProtocol);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
