import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_localizations.dart';

/// 성당 액션 버튼 위젯 (지도, 커뮤니티)
class ParishDetailActions extends StatelessWidget {
  final Map<String, dynamic> parish;
  final String parishId;
  final Color primaryColor;
  final AppLocalizations l10n;

  const ParishDetailActions({
    super.key,
    required this.parish,
    required this.parishId,
    required this.primaryColor,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // 주소가 없으면 버튼 표시하지 않음
    if (parish['address'] == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
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
    );
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
}

