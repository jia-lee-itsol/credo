import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/info_row.dart';

/// 성당 기본 정보 위젯
class ParishDetailBasicInfo extends StatefulWidget {
  final Map<String, dynamic> parish;
  final Color primaryColor;
  final AppLocalizations l10n;

  const ParishDetailBasicInfo({
    super.key,
    required this.parish,
    required this.primaryColor,
    required this.l10n,
  });

  @override
  State<ParishDetailBasicInfo> createState() => _ParishDetailBasicInfoState();
}

class _ParishDetailBasicInfoState extends State<ParishDetailBasicInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _fadeAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 4개의 항목에 대한 staggered 애니메이션 생성
    for (int i = 0; i < 4; i++) {
      final startInterval = i * 0.15;
      final endInterval = (startInterval + 0.4).clamp(0.0, 1.0);

      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
          ),
        ),
      );

      _slideAnimations.add(
        Tween<Offset>(
          begin: const Offset(-0.1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(startInterval, endInterval, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedRow(int index, Widget child) {
    if (index >= _fadeAnimations.length) return child;

    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 웹사이트 (website 또는 officialSite 또는 official_site 필드 확인)
    final website =
        widget.parish['website'] as String? ??
        widget.parish['officialSite'] as String? ??
        widget.parish['official_site'] as String?;

    int rowIndex = 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주소
          if (widget.parish['address'] != null) ...[
            _buildAnimatedRow(
              rowIndex++,
              InfoRow(
                icon: Icons.location_on,
                title: widget.l10n.parish.detailSection.address,
                content:
                    '${widget.parish['prefecture'] as String? ?? ''} ${widget.parish['address'] as String? ?? ''}',
                primaryColor: widget.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 전화번호
          if (widget.parish['phone'] != null &&
              (widget.parish['phone'] as String).isNotEmpty) ...[
            _buildAnimatedRow(
              rowIndex++,
              InfoRow(
                icon: Icons.phone,
                title: widget.l10n.parish.detailSection.phone,
                content: widget.parish['phone'] as String,
                primaryColor: widget.primaryColor,
                onTap: () => _launchPhone(widget.parish['phone'] as String),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 팩스
          if (widget.parish['fax'] != null &&
              (widget.parish['fax'] as String).isNotEmpty) ...[
            _buildAnimatedRow(
              rowIndex++,
              InfoRow(
                icon: Icons.fax,
                title: widget.l10n.parish.detailSection.fax,
                content: widget.parish['fax'] as String,
                primaryColor: widget.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 웹사이트
          if (website != null && website.isNotEmpty) ...[
            _buildAnimatedRow(
              rowIndex++,
              InfoRow(
                icon: Icons.language,
                title: widget.l10n.parish.detailSection.website,
                content: website,
                primaryColor: widget.primaryColor,
                onTap: () => _launchUrl(website),
              ),
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

