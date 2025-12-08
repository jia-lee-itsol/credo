import 'package:intl/intl.dart';

/// 날짜 유틸리티
class AppDateUtils {
  AppDateUtils._();

  /// 날짜 포맷터
  static final DateFormat _japaneseDateFormat = DateFormat('yyyy年M月d日', 'ja');
  static final DateFormat _japaneseShortDateFormat = DateFormat('M月d日', 'ja');
  static final DateFormat _japaneseTimeFormat = DateFormat('HH:mm', 'ja');
  static final DateFormat _japaneseDateTimeFormat = DateFormat('yyyy年M月d日 HH:mm', 'ja');

  /// 일본어 날짜 포맷 (예: 2024年12月8日)
  static String formatJapaneseDate(DateTime date) {
    return _japaneseDateFormat.format(date);
  }

  /// 일본어 짧은 날짜 포맷 (예: 12月8日)
  static String formatJapaneseShortDate(DateTime date) {
    return _japaneseShortDateFormat.format(date);
  }

  /// 시간 포맷 (예: 10:30)
  static String formatTime(DateTime date) {
    return _japaneseTimeFormat.format(date);
  }

  /// 일본어 날짜시간 포맷 (예: 2024年12月8日 10:30)
  static String formatJapaneseDateTime(DateTime date) {
    return _japaneseDateTimeFormat.format(date);
  }

  /// 상대적 시간 표시 (예: 3分前, 2時間前, 昨日)
  static String formatRelativeTime(DateTime date, {String locale = 'ja'}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (locale == 'ja') {
      if (difference.inSeconds < 60) {
        return 'たった今';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}時間前';
      } else if (difference.inDays < 2) {
        return '昨日';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}日前';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks週間前';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months}ヶ月前'; // ignore: unnecessary_brace_in_string_interps
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years年前';
      }
    } else {
      // 영어 포맷
      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 2) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months}mo ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years}y ago';
      }
    }
  }

  /// 요일 반환 (일본어)
  static String getJapaneseWeekday(DateTime date) {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return weekdays[date.weekday % 7];
  }

  /// 요일 반환 (영어)
  static String getEnglishWeekday(DateTime date) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekdays[date.weekday % 7];
  }

  /// 오늘인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 내일인지 확인
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// 이번 주인지 확인
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
}
