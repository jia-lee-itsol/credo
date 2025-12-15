import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/settings_list_tile.dart';
import '../../../../core/utils/app_localizations.dart';

/// 언어 설정 화면
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  /// 지원 언어 목록
  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(code: 'ja', name: '日本語', nativeName: '日本語'),
    LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    LanguageOption(code: 'zh', name: '中文', nativeName: '中文'),
    LanguageOption(code: 'vi', name: 'Tiếng Việt', nativeName: 'Tiếng Việt'),
    LanguageOption(code: 'ko', name: '한국어', nativeName: '한국어'),
    LanguageOption(code: 'es', name: 'Español', nativeName: 'Español'),
    LanguageOption(code: 'pt', name: 'Português', nativeName: 'Português'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10nAsync = ref.watch(appLocalizationsProvider);

    // 현재 선택된 언어 코드
    final currentLanguageCode = currentLocale.languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: l10nAsync.when(
          data: (l10n) => Text(l10n.language.settings),
          loading: () {
            final l10nSync = ref.read(appLocalizationsSyncProvider);
            return Text(l10nSync.language.settings);
          },
          error: (_, _) {
            final l10nSync = ref.read(appLocalizationsSyncProvider);
            return Text(l10nSync.language.settings);
          },
        ),
      ),
      body: ListView(
        children: [
          // 언어 목록
          ...supportedLanguages.map((language) {
            final isSelected = language.code == currentLanguageCode;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SettingsListTile(
                icon: Icons.language,
                title: language.name,
                subtitle: language.nativeName != language.name
                    ? language.nativeName
                    : null,
                primaryColor: primaryColor,
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: primaryColor)
                    : const Icon(Icons.chevron_right),
                onTap: () async {
                  // 이미 선택된 언어면 무시
                  if (isSelected) return;

                  // AppLocalizationsDelegate 및 LocalizationService 캐시 무효화 (로케일 변경 전)
                  clearAppLocalizationsCache();

                  // 로케일 업데이트 (즉시 UI 반영)
                  await ref
                      .read(localeProvider.notifier)
                      .setLocaleByLanguageCode(language.code);

                  // 번역 데이터 Provider 무효화하여 새 로케일로 다시 로드
                  ref.invalidate(appLocalizationsProvider);
                  ref.invalidate(appLocalizationsSyncProvider);

                  // 로그인된 사용자가 있으면 프로필도 업데이트
                  final currentUser = ref.read(currentUserProvider);

                  // 번역 데이터 로드 (로케일 변경 후) - 새 로케일의 번역 데이터를 캐시에 저장
                  final updatedL10n = await ref.read(
                    appLocalizationsProvider.future,
                  );

                  if (currentUser != null) {
                    final repository = ref.read(authRepositoryProvider);
                    final result = await repository.updateProfile(
                      preferredLanguages: [language.code],
                    );

                    if (!context.mounted) return;

                    result.fold(
                      (failure) {
                        // 로케일은 이미 변경되었으므로 에러만 표시
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              updatedL10n.language
                                  .switchedButProfileUpdateFailed(
                                    language: language.name,
                                    error: failure.message,
                                  ),
                            ),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      },
                      (updatedUser) {
                        // 프로필 업데이트 성공
                        ref.read(authStateProvider.notifier).state =
                            updatedUser;
                        ref.invalidate(authStateStreamProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                updatedL10n.language.switched(
                                  language: language.name,
                                ),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    );
                  } else {
                    // 로그인하지 않은 경우 로케일만 변경
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            updatedL10n.language.switched(
                              language: language.name,
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),
            );
          }),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// 언어 옵션 모델
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}
