import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'liturgical_calendar_service.dart';
import '../../../core/services/logger_service.dart';

/// 독서 모델
class Reading {
  final String reference;
  final String title;
  final String text;

  const Reading({
    required this.reference,
    required this.title,
    required this.text,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      reference: json['reference'] as String? ?? '',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

/// 화답송 모델
class PsalmReading extends Reading {
  final String response;

  const PsalmReading({
    required super.reference,
    required super.title,
    required super.text,
    required this.response,
  });

  factory PsalmReading.fromJson(Map<String, dynamic> json) {
    return PsalmReading(
      reference: json['reference'] as String? ?? '',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      response: json['response'] as String? ?? '',
    );
  }
}

/// 미사 독서 세트 모델
class MassReadings {
  final Reading first;
  final PsalmReading? psalm; // 평일에는 없을 수 있음
  final Reading? second; // 평일에는 없을 수 있음
  final Reading gospel;

  const MassReadings({
    required this.first,
    this.psalm,
    this.second,
    required this.gospel,
  });

  factory MassReadings.fromJson(Map<String, dynamic> json) {
    return MassReadings(
      first: Reading.fromJson(json['first'] as Map<String, dynamic>),
      psalm: json['psalm'] != null
          ? PsalmReading.fromJson(json['psalm'] as Map<String, dynamic>)
          : null,
      second: json['second'] != null
          ? Reading.fromJson(json['second'] as Map<String, dynamic>)
          : null,
      gospel: Reading.fromJson(json['gospel'] as Map<String, dynamic>),
    );
  }
}

/// 전례일 모델
class LiturgicalDay {
  final String id;
  final String name;
  final String season;
  final String color;
  final MassReadings readings;
  final String? optional; // 선택 기념일
  final bool isSunday;
  final bool isSolemnity;
  final bool isFeast;

  const LiturgicalDay({
    required this.id,
    required this.name,
    required this.season,
    required this.color,
    required this.readings,
    this.optional,
    this.isSunday = false,
    this.isSolemnity = false,
    this.isFeast = false,
  });

  factory LiturgicalDay.fromJson(String id, Map<String, dynamic> json) {
    return LiturgicalDay(
      id: id,
      name: json['name'] as String? ?? '',
      season: json['season'] as String? ?? '',
      color: json['color'] as String? ?? 'green',
      readings: MassReadings.fromJson(json['readings'] as Map<String, dynamic>),
      optional: json['optional'] as String?,
      isSunday: json['isSunday'] as bool? ?? false,
      isSolemnity: json['solemnity'] as bool? ?? false,
      isFeast: json['feast'] as bool? ?? false,
    );
  }
}

/// 전례 독서 서비스
class LiturgicalReadingService {
  static Map<String, dynamic>? _cachedYearA;
  static Map<String, dynamic>? _cachedYearB;
  static Map<String, dynamic>? _cachedYearC;
  // 당일 데이터 캐시 (날짜 -> LiturgicalDay)
  static final Map<String, LiturgicalDay> _cachedDays = {};

  /// 현재 전례년도 주기 계산 (A/B/C)
  static String getLiturgicalCycle(DateTime date) {
    // 전례년도는 대림 제1주일부터 시작
    // 2025-2026: A년 (가해)
    // 2026-2027: B년 (나해)
    // 2027-2028: C년 (다해)
    final year = date.month >= 12 ? date.year + 1 : date.year;
    final cycleIndex = year % 3;
    switch (cycleIndex) {
      case 0:
        return 'C';
      case 1:
        return 'A';
      case 2:
        return 'B';
      default:
        return 'A';
    }
  }

  /// 전례 독서 데이터 로드
  static Future<Map<String, dynamic>> loadReadings(String cycle) async {
    switch (cycle) {
      case 'A':
        if (_cachedYearA != null) return _cachedYearA!;
        break;
      case 'B':
        if (_cachedYearB != null) return _cachedYearB!;
        break;
      case 'C':
        if (_cachedYearC != null) return _cachedYearC!;
        break;
    }

    try {
      // B, C년도 파일이 없으면 A년도 사용 (fallback)
      String fileCycle = cycle;
      final filePath =
          'assets/data/liturgical/readings/readings_year_${cycle.toLowerCase()}.json';

      if (cycle != 'A') {
        try {
          await rootBundle.loadString(filePath);
        } catch (e) {
          // B, C년도 파일이 없으면 A년도 사용
          AppLogger.warning(
            'readings_year_${cycle.toLowerCase()}.json not found, using A: $e',
          );
          fileCycle = 'A';
        }
      }

      final finalPath =
          'assets/data/liturgical/readings/readings_year_${fileCycle.toLowerCase()}.json';
      AppLogger.debug('Loading readings from: $finalPath');

      final jsonString = await rootBundle.loadString(finalPath);
      AppLogger.debug('File loaded, string length: ${jsonString.length}');

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      AppLogger.debug('JSON decoded successfully');
      AppLogger.debug('JSON top-level keys: ${json.keys.toList()}');

      // dailyReadings 확인
      if (json.containsKey('dailyReadings')) {
        final dailyReadings = json['dailyReadings'] as Map<String, dynamic>?;
        AppLogger.debug('dailyReadings exists: ${dailyReadings != null}');
        if (dailyReadings != null) {
          AppLogger.debug('dailyReadings count: ${dailyReadings.length}');
          if (dailyReadings.isNotEmpty) {
            final firstKey = dailyReadings.keys.first;
            final lastKey = dailyReadings.keys.last;
            AppLogger.debug('dailyReadings date range: $firstKey ~ $lastKey');

            // 첫 번째 항목 샘플 출력
            final firstEntry = dailyReadings[firstKey] as Map<String, dynamic>?;
            if (firstEntry != null) {
              AppLogger.debug('Sample entry ($firstKey):');
              AppLogger.debug('   - keys: ${firstEntry.keys.toList()}');
              AppLogger.debug('   - name: "${firstEntry['name']}"');
              AppLogger.debug('   - season: "${firstEntry['season']}"');
              AppLogger.debug('   - color: "${firstEntry['color']}"');
              AppLogger.debug(
                '   - has readings: ${firstEntry.containsKey('readings')}',
              );
              if (firstEntry.containsKey('readings')) {
                final readings =
                    firstEntry['readings'] as Map<String, dynamic>?;
                if (readings != null) {
                  AppLogger.debug(
                    '   - readings keys: ${readings.keys.toList()}',
                  );
                }
              }
            }
          }
        }
      } else {
        AppLogger.warning('dailyReadings key not found in JSON!');
      }

      // sundays 확인
      if (json.containsKey('sundays')) {
        final sundays = json['sundays'] as Map<String, dynamic>?;
        AppLogger.debug('sundays count: ${sundays?.length ?? 0}');
      }

      // solemnities 확인
      if (json.containsKey('solemnities')) {
        final solemnities = json['solemnities'] as Map<String, dynamic>?;
        AppLogger.debug('solemnities count: ${solemnities?.length ?? 0}');
      }

      AppLogger.debug('Successfully loaded readings for cycle $cycle');

      switch (cycle) {
        case 'A':
          _cachedYearA = json;
          break;
        case 'B':
          _cachedYearB = json;
          break;
        case 'C':
          _cachedYearC = json;
          break;
      }

      return json;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error loading readings for cycle $cycle: $e',
        e,
        stackTrace,
      );
      throw Exception('Failed to load readings for cycle $cycle: $e');
    }
  }

  /// 특정 날짜의 전례일 정보 가져오기 (최적화: 당일 데이터만)
  /// 매일 0시에 자동으로 새로 로드됨 (Provider에서 날짜 변경 감지)
  static Future<LiturgicalDay?> getLiturgicalDayForDate(DateTime date) async {
    try {
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // 캐시 확인 (당일 데이터가 이미 로드되었으면 즉시 반환)
      // 캐시된 데이터는 로그 출력하지 않음 (너무 많이 호출됨)
      if (_cachedDays.containsKey(dateString)) {
        return _cachedDays[dateString];
      }

      AppLogger.debug('Loading data for $dateString...');

      final cycle = getLiturgicalCycle(date);
      AppLogger.debug('Cycle: $cycle for $dateString');

      // 1. dailyReadings에서 날짜로 직접 조회 (가장 빠름)
      final readings = await loadReadings(cycle);
      final dailyReadings = readings['dailyReadings'] as Map<String, dynamic>?;

      if (dailyReadings != null && dailyReadings.containsKey(dateString)) {
        final dayData = dailyReadings[dateString] as Map<String, dynamic>;
        AppLogger.debug('Found $dateString in dailyReadings');
        // JSON 데이터 구조 확인 로그
        AppLogger.debug('JSON data for $dateString:');
        AppLogger.debug(
          '  - name: "${dayData['name']}" (empty: ${(dayData['name'] as String? ?? '').isEmpty})',
        );
        AppLogger.debug('  - season: "${dayData['season']}"');
        AppLogger.debug('  - color: "${dayData['color']}"');

        // readings 구조 확인
        if (dayData.containsKey('readings')) {
          final readings = dayData['readings'] as Map<String, dynamic>?;
          if (readings != null) {
            if (readings.containsKey('first')) {
              final first = readings['first'] as Map<String, dynamic>?;
              AppLogger.debug('  - first reading: "${first?['reference']}"');
            }
            if (readings.containsKey('gospel')) {
              final gospel = readings['gospel'] as Map<String, dynamic>?;
              AppLogger.debug('  - gospel: "${gospel?['reference']}"');
            }
          }
        }

        try {
          final liturgicalDay = LiturgicalDay.fromJson(dateString, dayData);

          _cachedDays[dateString] = liturgicalDay; // 캐싱
          AppLogger.debug('Parsed successfully');
          AppLogger.debug(
            '  - name: "${liturgicalDay.name}" (empty: ${liturgicalDay.name.isEmpty})',
          );
          AppLogger.debug('  - season: "${liturgicalDay.season}"');
          AppLogger.debug('  - color: "${liturgicalDay.color}"');
          return liturgicalDay;
        } catch (e, stackTrace) {
          // 파싱 에러 로깅
          AppLogger.error('ERROR parsing for $dateString: $e', e, stackTrace);
          AppLogger.debug('Day data: $dayData');
          return null;
        }
      } else {
        if (dailyReadings == null) {
          AppLogger.error('ERROR: dailyReadings is null!');
        } else {
          AppLogger.warning(
            '$dateString not found (${dailyReadings.length} entries)',
          );
        }
      }

      // 2. 주일인 경우 주일 데이터만 확인
      if (date.weekday == DateTime.sunday) {
        final dayId = await _getSundayId(date);
        if (dayId != null) {
          final sundays = readings['sundays'] as Map<String, dynamic>?;
          if (sundays != null && sundays.containsKey(dayId)) {
            final liturgicalDay = LiturgicalDay.fromJson(
              dayId,
              sundays[dayId] as Map<String, dynamic>,
            );
            _cachedDays[dateString] = liturgicalDay; // 캐싱
            AppLogger.debug('Loaded Sunday: $dayId ($dateString)');
            return liturgicalDay;
          }
        }
      }

      // 3. 고정 축일 확인 (월-일 형식)
      final monthDay =
          '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final solemnities = readings['solemnities'] as Map<String, dynamic>?;
      if (solemnities != null) {
        for (final entry in solemnities.entries) {
          final data = entry.value as Map<String, dynamic>;
          if (data['date'] == monthDay) {
            final liturgicalDay = LiturgicalDay.fromJson(entry.key, data);
            _cachedDays[dateString] = liturgicalDay; // 캐싱
            AppLogger.debug('Loaded solemnity: ${entry.key} ($dateString)');
            return liturgicalDay;
          }
        }
      }

      AppLogger.warning('No data found for $dateString');
      return null;
    } catch (e, stackTrace) {
      // 에러 발생 시 로깅 및 null 반환
      final errorDateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      AppLogger.error('ERROR for $errorDateString: $e', e, stackTrace);
      return null;
    }
  }

  /// 주일 ID 계산 (캘린더 파일 우선 사용, 없으면 계산 로직 사용)
  static Future<String?> _getSundayId(DateTime date) async {
    // 캘린더 파일에서 날짜 정보 가져오기 시도
    final calendar = await LiturgicalCalendarService.loadCurrentCalendar(date);

    final year = date.year;
    DateTime advent1;
    DateTime easter;
    DateTime pentecost;
    DateTime ashWednesday;
    final christmas = DateTime(year, 12, 25);

    if (calendar != null) {
      // 캘린더 파일에서 날짜 가져오기
      final seasons = calendar.seasons;
      final adventStart = _parseDateString(seasons.advent.start);
      advent1 = adventStart;

      final easterStart = _parseDateString(seasons.easter.start);
      easter = easterStart;

      final pentecostDate = _parseDateString(seasons.pentecost.date);
      pentecost = pentecostDate;

      // 사순 수요일 = 부활절 - 46일
      ashWednesday = easter.subtract(const Duration(days: 46));
    } else {
      // 캘린더 파일이 없으면 기존 계산 로직 사용
      advent1 = _getAdventFirstSunday(year);
      easter = _getEasterDate(year);
      ashWednesday = easter.subtract(const Duration(days: 46));
      pentecost = easter.add(const Duration(days: 49));
    }

    // 대림시기
    if (date.isAfter(advent1.subtract(const Duration(days: 1))) &&
        date.isBefore(christmas)) {
      final weekNum = ((date.difference(advent1).inDays) ~/ 7) + 1;
      return 'advent_$weekNum';
    }

    // 성탄시기
    if ((date.month == 12 && date.day >= 25) ||
        (date.month == 1 && date.day <= 12)) {
      if (date.month == 12 && date.day == 25) return 'christmas_day';
      if (date.month == 1 && date.day == 1) return 'mary_mother_of_god';
      if (date.month == 1 && date.day >= 2 && date.day <= 8) {
        // 주님 공현은 1월 6일 또는 그 주일
        if (date.weekday == DateTime.sunday) {
          return 'epiphany';
        }
        // 1월 6일이 주일이 아니면 그 주일
        final epiphanyDate = DateTime(year, 1, 6);
        final epiphanySunday = epiphanyDate.add(
          Duration(days: (DateTime.sunday - epiphanyDate.weekday) % 7),
        );
        if (_isSameDay(date, epiphanySunday)) {
          return 'epiphany';
        }
      }
      // 주님 세례 축일 (공현 후 첫 주일, 보통 1월 둘째 주일)
      if (date.month == 1 && date.day >= 7 && date.day <= 13) {
        final epiphanyDate = DateTime(year, 1, 6);
        final epiphanySunday = epiphanyDate.add(
          Duration(days: (DateTime.sunday - epiphanyDate.weekday) % 7),
        );
        final baptismSunday = epiphanySunday.add(const Duration(days: 7));
        if (_isSameDay(date, baptismSunday)) {
          return 'baptism_of_the_lord';
        }
      }
      // 성가정 축일 (성탄 후 첫 주일)
      if (date.month == 12 && date.day >= 26 && date.day <= 31) {
        if (date.weekday == DateTime.sunday) {
          return 'holy_family';
        }
      }
      if (date.month == 1 && date.day >= 2 && date.day <= 6) {
        if (date.weekday == DateTime.sunday) {
          return 'holy_family';
        }
      }
    }

    // 사순시기
    if (date.isAfter(ashWednesday.subtract(const Duration(days: 1))) &&
        date.isBefore(easter)) {
      if (_isSameDay(date, easter.subtract(const Duration(days: 7)))) {
        return 'palm_sunday';
      }
      final weekNum = ((date.difference(ashWednesday).inDays) ~/ 7) + 1;
      return 'lent_$weekNum';
    }

    // 부활시기
    if (date.isAfter(easter.subtract(const Duration(days: 1))) &&
        date.isBefore(pentecost.add(const Duration(days: 1)))) {
      if (_isSameDay(date, easter)) return 'easter';
      if (_isSameDay(date, pentecost)) return 'pentecost';
      final weekNum = ((date.difference(easter).inDays) ~/ 7) + 1;
      return 'easter_$weekNum';
    }

    // 삼위일체/성체성혈/예수 성심
    if (_isSameDay(date, pentecost.add(const Duration(days: 7)))) {
      return 'trinity';
    }
    if (_isSameDay(date, pentecost.add(const Duration(days: 14)))) {
      return 'corpus_christi';
    }
    // 예수 성심 대축일 (성령 강림 후 19일째 금요일)
    final sacredHeart = pentecost.add(const Duration(days: 19));
    if (_isSameDay(date, sacredHeart)) {
      return 'sacred_heart';
    }

    // 그리스도왕 대축일 (대림 전 마지막 주일)
    final christKing = advent1.subtract(const Duration(days: 7));
    if (_isSameDay(date, christKing)) {
      return 'christ_the_king';
    }

    // 연중시기
    return null;
  }

  /// 대림 제1주일 계산 (11월 30일에 가장 가까운 주일)
  static DateTime _getAdventFirstSunday(int year) {
    final nov30 = DateTime(year, 11, 30);
    final dayOfWeek = nov30.weekday;

    if (dayOfWeek == DateTime.sunday) {
      return nov30;
    } else if (dayOfWeek < DateTime.sunday) {
      // 일요일 전이면 다음 일요일
      return nov30.add(Duration(days: DateTime.sunday - dayOfWeek));
    } else {
      // 일요일 후면 이전 일요일 또는 다음 주일
      final prevSunday = nov30.subtract(
        Duration(days: dayOfWeek - DateTime.sunday),
      );
      final nextSunday = nov30.add(
        Duration(days: 7 - dayOfWeek + DateTime.sunday),
      );

      // 11월 30일에 더 가까운 주일 선택
      if (nov30.difference(prevSunday).inDays <=
          nextSunday.difference(nov30).inDays) {
        return prevSunday;
      }
      return nextSunday;
    }
  }

  /// 부활절 계산 (알고리즘: Computus)
  static DateTime _getEasterDate(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;

    return DateTime(year, month, day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 특정 날짜의 캐시 제거 (날짜 변경 시 사용)
  static void clearDateCache(String dateString) {
    _cachedDays.remove(dateString);
  }

  /// 캐시 초기화
  static void clearCache() {
    _cachedYearA = null;
    _cachedYearB = null;
    _cachedYearC = null;
    _cachedDays.clear();
  }
}

/// 현재 날짜 문자열 Provider (날짜 변경 감지용)
/// 매일 0시에 자동으로 갱신됨
/// 날짜가 바뀌면 자동으로 새 값을 반환하여 Provider 재실행 유도
/// 주의: 이 Provider를 watch하면 매번 재실행될 수 있으므로 신중하게 사용해야 함
final currentDateStringProvider = Provider<String>((ref) {
  final now = DateTime.now();
  // 날짜만 반환 (시간 제외)하여 날짜가 바뀔 때만 값이 변경됨
  // 이 Provider는 날짜가 바뀔 때만 값이 변경되므로, watch하는 Provider가 자동으로 재실행됨
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
});

/// 오늘의 전례일 Provider (매일 0시에 자동 갱신)
/// 날짜가 바뀌면 자동으로 새로 로드됨
final todayLiturgicalDayProvider = FutureProvider<LiturgicalDay?>((ref) {
  // 날짜 문자열을 watch하여 날짜가 바뀌면 자동으로 새로 로드
  ref.watch(currentDateStringProvider);
  final now = DateTime.now();

  // 날짜가 바뀌었으면 Provider가 재실행되어 자동으로 새 데이터 로드됨

  ref.keepAlive();
  return LiturgicalReadingService.getLiturgicalDayForDate(now);
});

/// 날짜 문자열을 DateTime으로 변환하는 헬퍼
DateTime _parseDateString(String dateString) {
  final parts = dateString.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

/// 특정 날짜의 전례일 Provider (캐싱 활성화)
/// 날짜 문자열을 키로 사용하여 무한 반복 방지 (DateTime은 매번 새 인스턴스이므로)
final liturgicalDayProvider = FutureProvider.family<LiturgicalDay?, String>((
  ref,
  dateString,
) async {
  // keepAlive로 캐싱 유지
  ref.keepAlive();

  try {
    final date = _parseDateString(dateString);
    final result = await LiturgicalReadingService.getLiturgicalDayForDate(date);
    return result;
  } catch (e) {
    AppLogger.error('ERROR for $dateString: $e', e);
    rethrow;
  }
});

/// 현재 전례년도 주기 Provider
final liturgicalCycleProvider = Provider<String>((ref) {
  return LiturgicalReadingService.getLiturgicalCycle(DateTime.now());
});
