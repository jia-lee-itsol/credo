import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../core/utils/app_localizations.dart';

// Figma 디자인에 맞춘 색상 상수
const _primaryColor = Color(0xFF6A1F2B);
const _selectedCardBackground = Color(0xFFF9F3F4);
const _buttonTextColor = Color(0xFFFAF7F4);
const _neutral800 = Color(0xFF262626);
const _neutral600 = Color(0xFF525252);
const _neutral500 = Color(0xFF737373);
const _neutral200 = Color(0xFFE5E5E5);

/// 언어 선택 화면 (온보딩 1단계)
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String _selectedLanguage = 'ja';

  final List<_LanguageOption> _languages = [
    _LanguageOption(code: 'ja', name: '日本語', subtitle: 'Japanese'),
    _LanguageOption(code: 'en', name: 'English', subtitle: 'English'),
    _LanguageOption(code: 'ko', name: '한국어', subtitle: 'Korean'),
    _LanguageOption(code: 'zh', name: '中文', subtitle: 'Chinese'),
    _LanguageOption(code: 'vi', name: 'Tiếng Việt', subtitle: 'Vietnamese'),
    _LanguageOption(code: 'es', name: 'Español', subtitle: 'Spanish'),
    _LanguageOption(code: 'pt', name: 'Português', subtitle: 'Portuguese'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 35),
          child: Column(
            children: [
              // 헤더 영역
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _selectedCardBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.language,
                      size: 24,
                      color: _primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 타이틀
                  Text(
                    '言語を選択',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                      color: _neutral800,
                      letterSpacing: 0.07,
                      height: 32 / 24,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  const SizedBox(height: 8),

                  // 부제목
                  Text(
                    'Select Language',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: _neutral600,
                      letterSpacing: -0.31,
                      height: 24 / 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),

              const SizedBox(height: 38),

              // 언어 리스트
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _languages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12.27),
                  itemBuilder: (context, index) {
                    final language = _languages[index];
                    final isSelected = _selectedLanguage == language.code;

                    return _LanguageCard(
                      language: language,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedLanguage = language.code;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    '次へ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: _buttonTextColor,
                      letterSpacing: -0.31,
                      height: 24 / 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onNext() async {
    // 언어 코드 매핑 (온보딩 화면에서 사용하는 코드를 실제 언어 코드로 변환)
    String languageCode = _selectedLanguage;

    // AppLocalizationsDelegate 및 LocalizationService 캐시 무효화 (로케일 변경 전)
    clearAppLocalizationsCache();

    // 로케일 업데이트 (즉시 UI 반영)
    await ref
        .read(localeProvider.notifier)
        .setLocaleByLanguageCode(languageCode);

    // 번역 데이터 Provider 무효화하여 새 로케일로 다시 로드
    ref.invalidate(appLocalizationsProvider);
    ref.invalidate(appLocalizationsSyncProvider);

    // 번역 데이터 로드 (로케일 변경 후) - 새 로케일의 번역 데이터를 캐시에 저장
    await ref.read(appLocalizationsProvider.future);

    if (mounted) {
      context.go(AppRoutes.onboardingLocation);
    }
  }
}

class _LanguageOption {
  final String code;
  final String name;
  final String subtitle;

  _LanguageOption({
    required this.code,
    required this.name,
    required this.subtitle,
  });
}

class _LanguageCard extends StatelessWidget {
  final _LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 78.74),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.17,
            vertical: 16.17,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _primaryColor : _neutral200,
              width: isSelected ? 1.2 : 1.38,
            ),
            color: isSelected ? _selectedCardBackground : Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      language.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: _neutral800,
                        letterSpacing: -0.31,
                        height: 24 / 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: _neutral500,
                        letterSpacing: -0.15,
                        height: 20 / 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.circle, size: 8, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
