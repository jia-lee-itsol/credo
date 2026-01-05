import 'package:flutter/material.dart';

/// 홈 화면 액션 버튼 위젯 (터치 애니메이션 포함)
class HomeActionButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const HomeActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  State<HomeActionButton> createState() => _HomeActionButtonState();
}

class _HomeActionButtonState extends State<HomeActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    widget.primaryColor.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.primaryColor.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.08),
                    blurRadius: _elevationAnimation.value * 8,
                    offset: Offset(0, _elevationAnimation.value * 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // 아이콘 컨테이너
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.primaryColor.withValues(alpha: 0.15),
                            widget.primaryColor.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 텍스트 영역
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B6B6B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 화살표
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: widget.primaryColor,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
