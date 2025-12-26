import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/info_row.dart';

/// 성당 기본 정보 위젯
class ParishDetailBasicInfo extends StatelessWidget {
  final Map<String, dynamic> parish;
  final Color primaryColor;
  final AppLocalizations l10n;
  final bool canEdit;
  final VoidCallback? onEditAddress;
  final VoidCallback? onEditPhone;

  const ParishDetailBasicInfo({
    super.key,
    required this.parish,
    required this.primaryColor,
    required this.l10n,
    this.canEdit = false,
    this.onEditAddress,
    this.onEditPhone,
  });

  @override
  Widget build(BuildContext context) {
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
            GestureDetector(
              onLongPress: canEdit ? onEditAddress : null,
              child: InfoRow(
                icon: Icons.location_on,
                title: l10n.parish.detailSection.address,
                content:
                    '${parish['prefecture'] as String? ?? ''} ${parish['address'] as String? ?? ''}',
                primaryColor: primaryColor,
                trailing: canEdit ? Icon(Icons.edit, size: 16, color: Colors.grey.shade400) : null,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 전화번호
          if (parish['phone'] != null &&
              (parish['phone'] as String).isNotEmpty) ...[
            GestureDetector(
              onLongPress: canEdit ? onEditPhone : null,
              child: InfoRow(
                icon: Icons.phone,
                title: l10n.parish.detailSection.phone,
                content: parish['phone'] as String,
                primaryColor: primaryColor,
                onTap: () => _launchPhone(parish['phone'] as String),
                trailing: canEdit ? Icon(Icons.edit, size: 16, color: Colors.grey.shade400) : null,
              ),
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
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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

