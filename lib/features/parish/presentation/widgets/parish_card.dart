import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/location_provider.dart';
import '../../../../core/utils/location_utils.dart';
import '../constants/parish_colors.dart';
import 'parish_tag.dart';

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
            border: Border.all(color: ParishColors.neutral200, width: 0.69),
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
                        color: ParishColors.neutral800,
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
                          color: ParishColors.neutral600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: ParishColors.neutral600,
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

                    // 거리, 미사 시간, 언어 태그 - 한 줄 가로 배치 (가로 스크롤 가능)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // 거리 태그 (거리가 있을 때만 표시)
                          if (distance != null) ...[
                            ParishTag(
                              text: distance,
                              backgroundColor: ParishColors.purple100,
                              textColor: ParishColors.purple600,
                            ),
                            const SizedBox(width: 8),
                          ],
                          // 미사 시간 태그
                          if (nextMass.isNotEmpty) ...[
                            ParishTag(
                              text: nextMass,
                              backgroundColor: ParishColors.neutral100,
                              textColor: ParishColors.neutral600,
                            ),
                            const SizedBox(width: 8),
                          ],
                          // 언어 태그들
                          ...languages.map(
                            (lang) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ParishOutlinedTag(
                                text: lang,
                                textColor: ParishColors.blue600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 오른쪽: 화살표
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: ParishColors.neutral600,
              ),
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
