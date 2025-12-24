import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/data/services/saint_feast_day_service.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/settings_list_tile.dart';
import '../../../saints/presentation/providers/saint_feast_day_providers.dart';
import '../screens/license_screen.dart';
import 'font_scale_settings_tile.dart';

/// 고객 서비스 구글 폼 URL
const String _customerServiceFormUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSdFM9lVAVL2ObVTSi08XdnpOthYpWYSuTEmIeIR7tRWfUfWWA/viewform';

/// 마이페이지 설정 섹션 위젯
class MyPageSettingsSection extends ConsumerWidget {
  final Color primaryColor;
  final bool isAuthenticated;
  final int? favoriteParishCount;

  const MyPageSettingsSection({
    super.key,
    required this.primaryColor,
    required this.isAuthenticated,
    this.favoriteParishCount,
  });

  /// 커스텀 About 다이얼로그 표시 ("Powered by Flutter" 제거)
  void _showCustomAboutDialog(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 본문 내용
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 앱 로고
                    Image.asset(
                      'assets/icons/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    // 앱 이름
                    Text(
                      'Credo',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 버전 정보
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'v1.0.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 앱 설명
                    Text(
                      l10n.app.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // 구분선
                    Divider(color: colorScheme.outlineVariant, height: 1),
                    const SizedBox(height: 24),

                    // 저작권 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.copyright,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '2026 ITSolutionz Inc.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 하단 버튼들
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // 라이선스 버튼
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LicenseScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.description),
                        label: const Text('ライセンス'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 닫기 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.common.close,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 고객 서비스 폼 열기
  Future<void> _openCustomerServiceForm(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final uri = Uri.parse(_customerServiceFormUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.common.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.common.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Column(
      children: [
        // 자주 가는 교회
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SettingsListTile(
            icon: Icons.favorite,
            title: l10n.profile.favoriteParishes,
            subtitle: isAuthenticated
                ? l10n.profile.favoriteParishesSection.registeredCount(
                    favoriteParishCount ?? 0,
                  )
                : l10n.profile.loginRequired,
            primaryColor: primaryColor,
            onTap: () {
              if (isAuthenticated) {
                context.push(AppRoutes.favoriteParishes);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.profile.loginRequired),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ),

        // 성당 FAQ
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SettingsListTile(
            icon: Icons.help_outline,
            title: l10n.profile.churchFaq.title,
            subtitle: l10n.profile.churchFaq.subtitle,
            primaryColor: primaryColor,
            onTap: () {
              context.push(AppRoutes.churchFaq);
            },
          ),
        ),

        // 알림 설정
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SettingsListTile(
            icon: Icons.notifications,
            title: l10n.profile.notificationSettings,
            primaryColor: primaryColor,
            onTap: () {
              if (isAuthenticated) {
                context.push(AppRoutes.notificationSettings);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.profile.loginRequired),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ),

        // 언어 설정
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _LanguageSettingsTile(primaryColor: primaryColor),
        ),

        // 글씨 크기 설정
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FontScaleSettingsTile(primaryColor: primaryColor),
        ),

        // 이용 규약
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SettingsListTile(
            icon: Icons.description,
            title: l10n.profile.termsOfService,
            primaryColor: primaryColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.profile.termsOfServiceComingSoon)),
              );
            },
          ),
        ),

        // 개인정보 처리방침
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SettingsListTile(
            icon: Icons.privacy_tip,
            title: l10n.profile.privacyPolicy,
            primaryColor: primaryColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.profile.privacyPolicyComingSoon)),
              );
            },
          ),
        ),

        // 고객 서비스 (의견 보내기)
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SettingsListTile(
            icon: Icons.support_agent,
            title: l10n.profile.customerService,
            subtitle: l10n.profile.customerServiceDescription,
            primaryColor: primaryColor,
            onTap: () => _openCustomerServiceForm(context, l10n),
          ),
        ),

        // 앱 정보
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SettingsListTile(
            icon: Icons.info,
            title: l10n.profile.aboutApp,
            subtitle: 'Credo v1.0.0',
            primaryColor: primaryColor,
            onTap: () {
              _showCustomAboutDialog(context, l10n);
            },
          ),
        ),

        // 캐시 삭제
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _ClearCacheTile(primaryColor: primaryColor),
        ),
      ],
    );
  }
}

/// 캐시 삭제 타일 위젯
class _ClearCacheTile extends ConsumerStatefulWidget {
  final Color primaryColor;

  const _ClearCacheTile({required this.primaryColor});

  @override
  ConsumerState<_ClearCacheTile> createState() => _ClearCacheTileState();
}

class _ClearCacheTileState extends ConsumerState<_ClearCacheTile> {
  bool _isClearing = false;

  Future<void> _clearAllCache() async {
    setState(() => _isClearing = true);

    try {
      // 성인 캐시 삭제
      await SaintFeastDayService.clearTodaySaintsCache();

      // 이미지 캐시 삭제 (SharedPreferences에서 saint_image_ 관련 키 삭제)
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('saint_image_') ||
            key.startsWith('saints_chatgpt_') ||
            key.startsWith('failed_saint_image_urls')) {
          await prefs.remove(key);
        }
      }

      // Provider 새로고침 트리거
      ref.read(saintsCacheRefreshTriggerProvider.notifier).state++;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('캐시가 삭제되었습니다. 데이터를 새로 불러옵니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('캐시 삭제 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  Future<void> _showClearCacheDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profile.clearCache),
        content: Text(l10n.profile.clearCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.common.confirm,
              style: TextStyle(color: widget.primaryColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _clearAllCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return SettingsListTile(
      icon: Icons.cleaning_services,
      title: l10n.profile.clearCache,
      subtitle: l10n.profile.clearCacheDescription,
      primaryColor: widget.primaryColor,
      trailing: _isClearing
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: widget.primaryColor,
              ),
            )
          : null,
      onTap: _isClearing ? null : () => _showClearCacheDialog(context, l10n),
    );
  }
}

/// 언어 설정 타일 위젯
class _LanguageSettingsTile extends ConsumerWidget {
  final Color primaryColor;

  const _LanguageSettingsTile({required this.primaryColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final languageCode = ref.watch(localeProvider).languageCode;
    final names = l10n.language.names;

    String languageName;
    switch (languageCode) {
      case 'ja':
        languageName = names.japanese;
        break;
      case 'en':
        languageName = names.english;
        break;
      case 'zh':
        languageName = names.chinese;
        break;
      case 'vi':
        languageName = names.vietnamese;
        break;
      case 'ko':
        languageName = names.korean;
        break;
      case 'es':
        languageName = names.spanish;
        break;
      case 'pt':
        languageName = names.portuguese;
        break;
      default:
        languageName = names.japanese;
    }

    return SettingsListTile(
      icon: Icons.language,
      title: l10n.profile.languageSettings,
      subtitle: languageName,
      primaryColor: primaryColor,
      onTap: () {
        context.push(AppRoutes.languageSettings);
      },
    );
  }
}
