import 'package:flutter/material.dart';

/// 인증 화면용 로고 헤더 위젯
class AuthLogoHeader extends StatelessWidget {
  final Color primaryColor;
  final Color backgroundColor;
  final String title;
  final String? subtitle;

  const AuthLogoHeader({
    super.key,
    required this.primaryColor,
    required this.backgroundColor,
    this.title = 'Credo',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 40),
        // 로고
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.church, size: 48, color: primaryColor),
          ),
        ),
        const SizedBox(height: 24),
        // 타이틀
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 48),
      ],
    );
  }
}

