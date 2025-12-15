import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_localizations.dart';

/// 위치 정보 권한 화면 (온보딩 2단계)
class LocationPermissionScreen extends ConsumerWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    const primaryColor = Color(0xFF722F37);

    return Scaffold(
      backgroundColor: Colors.white,
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
                l10n.parish.locationUsage,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // 설명
              Text(
                l10n.parish.locationUsageMessage.replaceAll('\n', '\n'),
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
                      l10n.location.usagePurpose,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPurposeItem(theme, l10n.location.purposeNearbySearch),
                    const SizedBox(height: 12),
                    _buildPurposeItem(
                      theme,
                      l10n.location.purposeDistanceDisplay,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 허용 버튼
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _onAllow(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.parish.allow,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 나중에 버튼
              TextButton(
                onPressed: () => _onSkip(context),
                child: Text(
                  l10n.parish.notNow,
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

  Future<void> _onAllow(BuildContext context, WidgetRef ref) async {
    final l10n = ref.read(appLocalizationsSyncProvider);
    // 현재 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();

    // 이미 권한이 허용된 경우 바로 다음 화면으로
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      if (!context.mounted) return;
      await _completeOnboarding(context);
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      // 영구적으로 거부된 경우 설정으로 이동
      if (!context.mounted) return;
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.location.permissionRequired),
          content: Text(l10n.location.permissionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.common.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.location.openSettings),
            ),
          ],
        ),
      );

      if (shouldOpen == true && context.mounted) {
        await Geolocator.openAppSettings();
      }
      return;
    }

    if (permission == LocationPermission.denied) {
      // 시스템 위치 권한 다이얼로그 표시
      permission = await Geolocator.requestPermission();
      if (!context.mounted) return;

      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.parish.locationPermissionRequired)),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) return;
        final shouldOpen = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('位置情報の許可が必要です'),
            content: const Text('設定から位置情報の許可を有効にしてください。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('設定を開く'),
              ),
            ],
          ),
        );

        if (shouldOpen == true && context.mounted) {
          await Geolocator.openAppSettings();
        }
        return;
      }
    }

    // 권한이 허용된 경우 온보딩 완료
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      if (!context.mounted) return;
      await _completeOnboarding(context);
    }
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
