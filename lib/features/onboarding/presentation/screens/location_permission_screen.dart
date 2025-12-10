import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/routes/app_routes.dart';

/// 위치 정보 권한 화면 (온보딩 2단계)
class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF722F37);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // 아이콘
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 32,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 24),

              // 타이틀
              Text(
                '位置情報の利用',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // 설명
              Text(
                '近くの教会を探すために\n位置情報の利用を許可してください',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // 사용 목적 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '位置情報の使用目的',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPurposeItem(theme, '現在地から近い教会の検索'),
                    const SizedBox(height: 12),
                    _buildPurposeItem(theme, '教会までの距離表示'),
                  ],
                ),
              ),

              const Spacer(),

              // 허용 버튼
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _onAllow(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '位置情報を許可する',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 나중에 버튼
              TextButton(
                onPressed: () => _onSkip(context),
                child: Text(
                  '今はしない',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurposeItem(ThemeData theme, String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  Future<void> _onAllow(BuildContext context) async {
    final status = await Geolocator.requestPermission();
    if (!context.mounted) return;

    if (status == LocationPermission.denied) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('位置情報を許可してください.')));
      return;
    }

    await _completeOnboarding(context);
  }

  Future<void> _onSkip(BuildContext context) async {
    await _completeOnboarding(context);
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    // 온보딩 완료 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  }
}
