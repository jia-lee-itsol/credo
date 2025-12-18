import 'package:flutter/material.dart';
import '../../../../core/data/services/liturgical_reading_service.dart';
import '../../../../core/utils/app_localizations.dart';

/// 매일미사 전례일 카드 위젯
class DailyMassLiturgicalDayCard extends StatelessWidget {
  final ThemeData theme;
  final Color primaryColor;
  final LiturgicalDay day;
  final AppLocalizations l10n;

  const DailyMassLiturgicalDayCard({
    super.key,
    required this.theme,
    required this.primaryColor,
    required this.day,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
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
                  day.name.isNotEmpty
                      ? day.name
                      : _getDefaultDayName(day, l10n),
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

  String _getDefaultDayName(LiturgicalDay day, AppLocalizations l10n) {
    // 이름이 비어있을 때 기본 이름 생성
    // 주일, 대축일, 축일은 시기와 관계없이 우선 표시
    if (day.isSunday) {
      return l10n.mass.sunday;
    } else if (day.isSolemnity) {
      return l10n.mass.solemnity;
    } else if (day.isFeast) {
      return l10n.mass.feast;
    } else {
      // 시기에 따라 기본 이름 반환
      switch (day.season) {
        case 'advent':
          return l10n.mass.advent;
        case 'christmas':
          return l10n.mass.christmas;
        case 'lent':
          return l10n.mass.lent;
        case 'easter':
          return l10n.mass.easter;
        case 'ordinary':
        default:
          return l10n.mass.ordinary;
      }
    }
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

