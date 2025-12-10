import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/liturgical_reading_service.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/expandable_content_card.dart';

/// 매일미사 화면
class DailyMassScreen extends ConsumerStatefulWidget {
  const DailyMassScreen({super.key});

  @override
  ConsumerState<DailyMassScreen> createState() => _DailyMassScreenState();
}

class _DailyMassScreenState extends ConsumerState<DailyMassScreen> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final primaryColor = ref.read(liturgyPrimaryColorProvider);
    final testDate = ref.read(testDateOverrideProvider);
    final initialDate = _selectedDate ?? testDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2033, 12, 31),
      locale: const Locale('ja', 'JP'),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);
    final testDate = ref.watch(testDateOverrideProvider);

    // 선택한 날짜가 있으면 사용, 없으면 테스트 날짜 또는 오늘 날짜
    final displayDate = _selectedDate ?? testDate ?? DateTime.now();
    final dateFormat = DateFormat('yyyy年M月d日 (E)', 'ja');

    // 날짜를 문자열로 변환하여 Provider family 키로 사용 (무한 반복 방지)
    final dateKey =
        '${displayDate.year}-${displayDate.month.toString().padLeft(2, '0')}-${displayDate.day.toString().padLeft(2, '0')}';
    final liturgicalDayAsync = ref.watch(liturgicalDayProvider(dateKey));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('毎日のミサ'),
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
      body: liturgicalDayAsync.when(
        data: (liturgicalDay) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 날짜 헤더 (데이트피커 포함)
              _buildDateHeader(
                context,
                theme,
                primaryColor,
                dateFormat.format(displayDate),
              ),

              const SizedBox(height: 16),

              // 전례일 정보
              if (liturgicalDay != null) ...[
                _buildLiturgicalDayCard(theme, primaryColor, liturgicalDay),
                const SizedBox(height: 24),
                _buildReadingsSection(primaryColor, liturgicalDay),
              ] else
                _buildNoDataCard(theme, primaryColor),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          print('[DailyMassScreen] ❌ ERROR: $error');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('エラーが発生しました: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(liturgicalDayProvider(dateKey)),
                  child: const Text('再試行'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    String date,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              date,
              style: theme.textTheme.titleMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_month, color: primaryColor),
            onPressed: () => _selectDate(context),
            tooltip: '날짜 선택',
          ),
        ],
      ),
    );
  }

  Widget _buildLiturgicalDayCard(
    ThemeData theme,
    Color primaryColor,
    LiturgicalDay day,
  ) {
    final liturgicalColor = _getLiturgicalColor(day.color);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: liturgicalColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: liturgicalColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              color: liturgicalColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.name.isNotEmpty ? day.name : _getDefaultDayName(day),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSeasonName(day.season),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: liturgicalColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getColorName(day.color),
              style: TextStyle(
                color: liturgicalColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsSection(Color primaryColor, LiturgicalDay day) {
    final readings = day.readings;

    return Column(
      children: [
        // 제1독서
        ExpandableContentCard(
          title: '第一朗読',
          subtitle: readings.first.reference,
          icon: Icons.menu_book,
          primaryColor: primaryColor,
          content: readings.first.text.isNotEmpty
              ? '${readings.first.title}\n\n${readings.first.text}'
              : '${readings.first.title}\n\n（本文は準備中です）',
        ),

        // 화답송 (있는 경우만 표시)
        if (readings.psalm != null && readings.psalm!.reference.isNotEmpty)
          ExpandableContentCard(
            title: '答唱詩編',
            subtitle: readings.psalm!.reference,
            icon: Icons.library_music,
            primaryColor: primaryColor,
            content: readings.psalm!.text.isNotEmpty
                ? '【答唱】${readings.psalm!.response}\n\n${readings.psalm!.text}'
                : '【答唱】${readings.psalm!.response}\n\n（本文は準備中です）',
          ),

        // 제2독서 (있는 경우)
        if (readings.second != null)
          ExpandableContentCard(
            title: '第二朗読',
            subtitle: readings.second!.reference,
            icon: Icons.menu_book,
            primaryColor: primaryColor,
            content: readings.second!.text.isNotEmpty
                ? '${readings.second!.title}\n\n${readings.second!.text}'
                : '${readings.second!.title}\n\n（本文は準備中です）',
          ),

        // 복음
        ExpandableContentCard(
          title: '福音朗読',
          subtitle: readings.gospel.reference,
          icon: Icons.auto_stories,
          primaryColor: primaryColor,
          content: readings.gospel.text.isNotEmpty
              ? '${readings.gospel.title}\n\n${readings.gospel.text}'
              : '${readings.gospel.title}\n\n（本文は準備中です）',
        ),
      ],
    );
  }

  String _getDefaultDayName(LiturgicalDay day) {
    // 이름이 비어있을 때 기본 이름 생성 (일본어)
    // 주일, 대축일, 축일은 시기와 관계없이 우선 표시
    if (day.isSunday) {
      return '主日';
    } else if (day.isSolemnity) {
      return '大祝日';
    } else if (day.isFeast) {
      return '祝日';
    } else {
      // 시기에 따라 기본 이름 반환
      switch (day.season) {
        case 'advent':
          return '待降節';
        case 'christmas':
          return '降誕節';
        case 'lent':
          return '四旬節';
        case 'easter':
          return '復活節';
        case 'ordinary':
        default:
          return '年間平日';
      }
    }
  }

  Widget _buildNoDataCard(ThemeData theme, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '本日のミサ情報がありません',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '平日のミサ情報は現在準備中です',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLiturgicalColor(String color) {
    switch (color) {
      case 'white':
        return const Color(0xFFD4AF37); // 금색으로 표시 (흰색은 보이지 않으므로)
      case 'red':
        return Colors.red.shade700;
      case 'green':
        return Colors.green.shade700;
      case 'purple':
        return Colors.purple.shade700;
      case 'rose':
        return Colors.pink.shade300;
      case 'black':
        return Colors.black87;
      default:
        return Colors.green.shade700;
    }
  }

  String _getColorName(String color) {
    switch (color) {
      case 'white':
        return '白';
      case 'red':
        return '赤';
      case 'green':
        return '緑';
      case 'purple':
        return '紫';
      case 'rose':
        return '薔薇';
      case 'black':
        return '黒';
      default:
        return '緑';
    }
  }

  String _getSeasonName(String season) {
    switch (season) {
      case 'advent':
        return '待降節';
      case 'christmas':
        return '降誕節';
      case 'lent':
        return '四旬節';
      case 'easter':
        return '復活節';
      case 'ordinary':
        return '年間';
      default:
        return '';
    }
  }
}
