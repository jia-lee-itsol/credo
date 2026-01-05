import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/location_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../core/utils/location_utils.dart';
import '../constants/parish_colors.dart';

/// 교회 카드 위젯
class ParishCard extends ConsumerWidget {
  final Map<String, dynamic> parish;
  final VoidCallback onTap;

  const ParishCard({super.key, required this.parish, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = parish['name'] as String? ?? '';
    final address = parish['address'] as String? ?? '';
    final massTime = parish['massTime'] as String? ?? '';

    // 실제 거리 계산
    final distanceKm = ref.watch(parishDistanceProvider(parish));
    final distance = distanceKm != null
        ? LocationUtils.formatDistance(distanceKm)
        : null;

    // 전례 시기에 맞는 색상 가져오기
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    // 지원 언어 추출
    final languages = _getSupportedLanguages(massTime);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withValues(alpha: 0.08),
          highlightColor: primaryColor.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ParishColors.neutral200.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 교회 아이콘
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.church_outlined,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // 중앙: 교회 정보
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
                          fontWeight: FontWeight.w600,
                          color: ParishColors.neutral800,
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // 주소
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: ParishColors.neutral600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: ParishColors.neutral600,
                                letterSpacing: -0.1,
                                height: 1.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      if (distance != null || languages.isNotEmpty) ...[
                        const SizedBox(height: 10),

                        // 거리, 언어 태그
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // 거리 태그
                              if (distance != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.directions_walk,
                                        size: 12,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        distance,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              // 언어 태그들
                              ...languages.map(
                                (lang) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: ParishColors.blue600.withValues(alpha: 0.4),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      lang,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: ParishColors.blue600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 오른쪽: 화살표
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: ParishColors.neutral100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: ParishColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getSupportedLanguages(String massTime) {
    final languages = <String>[];

    // 일본어는 기본 언어이므로 뱃지 표시하지 않음

    // 영어
    if (massTime.contains('英語') || massTime.contains('English')) {
      languages.add('EN');
    }

    // 스페인어
    if (massTime.contains('スペイン語') ||
        massTime.contains('Spanish') ||
        massTime.contains('Español')) {
      languages.add('ES');
    }

    // 중국어
    if (massTime.contains('中国語') ||
        massTime.contains('Chinese') ||
        massTime.contains('中文')) {
      languages.add('CN');
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
