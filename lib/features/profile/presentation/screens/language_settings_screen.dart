import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/settings_list_tile.dart';

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
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    // 유저의 preferredLanguages 첫 번째 항목을 사용, 없으면 기본값 'ja'
    final currentLanguageCode =
        currentUser?.preferredLanguages.isNotEmpty == true
        ? currentUser!.preferredLanguages.first
        : 'ja';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('言語設定')),
      body: ListView(
        children: [
          // 안내 메시지
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.orange.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '言語設定機能は開発中です。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

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

                  // TODO: 언어 변경 로직 구현 (아직 개발 중)
                  // final repository = ref.read(authRepositoryProvider);
                  // final result = await repository.updateProfile(
                  //   preferredLanguages: [language.code],
                  // );
                  //
                  // if (!context.mounted) return;
                  //
                  // result.fold(
                  //   (failure) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         content: Text(failure.message),
                  //         backgroundColor: Colors.red,
                  //       ),
                  //     );
                  //   },
                  //   (updatedUser) {
                  //     ref.read(authStateProvider.notifier).state = updatedUser;
                  //     ref.invalidate(authStateStreamProvider);
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         content: Text('${language.name}に切り替えました'),
                  //         backgroundColor: Colors.green,
                  //       ),
                  //     );
                  //   },
                  // );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${language.name}への切り替えは準備中です'),
                      backgroundColor: Colors.orange,
                    ),
                  );
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






