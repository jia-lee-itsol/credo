import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_localizations.dart';

/// 성당 액션 버튼 위젯 (지도, 커뮤니티)
class ParishDetailActions extends StatefulWidget {
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
  State<ParishDetailActions> createState() => _ParishDetailActionsState();
}

class _ParishDetailActionsState extends State<ParishDetailActions>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _leftButtonAnimation;
  late Animation<double> _rightButtonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _leftButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _rightButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 주소가 없으면 버튼 표시하지 않음
    if (widget.parish['address'] == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 지도 버튼
          Expanded(
            child: AnimatedBuilder(
              animation: _leftButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _leftButtonAnimation.value,
                  child: Opacity(
                    opacity: _leftButtonAnimation.value,
                    child: child,
                  ),
                );
              },
              child: _AnimatedActionButton(
                isOutlined: true,
                icon: Icons.map,
                label: widget.l10n.parish.openInMap,
                onPressed: () {
                  final address =
                      '${widget.parish['prefecture'] as String? ?? ''} ${widget.parish['address'] as String? ?? ''}';
                  _launchMapByAddress(address);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 커뮤니티 버튼
          Expanded(
            child: AnimatedBuilder(
              animation: _rightButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _rightButtonAnimation.value,
                  child: Opacity(
                    opacity: _rightButtonAnimation.value,
                    child: child,
                  ),
                );
              },
              child: _AnimatedActionButton(
                isOutlined: false,
                icon: Icons.forum,
                label: widget.l10n.parish.community,
                primaryColor: widget.primaryColor,
                onPressed: () {
                  final targetParishId = widget.parishId;
                  final currentLocation = GoRouterState.of(context).matchedLocation;

                  if (currentLocation.startsWith('/my-page')) {
                    context.go('/community/$targetParishId');
                  } else {
                    context.push(AppRoutes.communityParishPath(targetParishId));
                  }
                },
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

/// 탭 시 애니메이션이 있는 액션 버튼
class _AnimatedActionButton extends StatefulWidget {
  final bool isOutlined;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? primaryColor;

  const _AnimatedActionButton({
    required this.isOutlined,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primaryColor,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _tapController.reverse();
  }

  void _handleTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _tapAnimation,
        child: widget.isOutlined
            ? OutlinedButton.icon(
                onPressed: widget.onPressed,
                icon: Icon(widget.icon),
                label: Text(widget.label),
              )
            : ElevatedButton.icon(
                onPressed: widget.onPressed,
                icon: Icon(widget.icon),
                label: Text(widget.label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
      ),
    );
  }
}

