import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../widgets/my_page_profile_section.dart';
import '../widgets/my_page_settings_section.dart';
import '../widgets/my_page_auth_button.dart';
import '../widgets/my_page_navigation_bar.dart';

/// 마이페이지 화면
class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _profileFadeAnimation;
  late Animation<double> _profileScaleAnimation;
  late Animation<double> _settingsFadeAnimation;
  late Animation<Offset> _settingsSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _profileFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _profileScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _settingsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _settingsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
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
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentUserProvider);
    final mainParishId = currentUser?.mainParishId;

    // 인증 상태 디버깅
    AppLogger.profile('빌드됨');
    AppLogger.profile('isAuthenticated: $isAuthenticated');
    AppLogger.profile('currentUser: ${currentUser?.userId ?? 'null'}');
    if (currentUser != null) {
      AppLogger.profile(
        '사용자 정보: userId=${currentUser.userId}, email=${currentUser.email}, nickname=${currentUser.nickname}',
      );
    }

    // 현재 경로를 기반으로 선택된 탭 인덱스 결정
    final currentLocation = GoRouterState.of(context).matchedLocation;
    int selectedIndex = 0;
    if (currentLocation.startsWith(AppRoutes.home)) {
      selectedIndex = 0;
    } else if (currentLocation.startsWith(AppRoutes.prayer)) {
      selectedIndex = 1;
    } else if (currentLocation.startsWith(AppRoutes.dailyMass)) {
      selectedIndex = 2;
    } else if (currentLocation.startsWith(AppRoutes.parishList)) {
      selectedIndex = 3;
    } else if (currentLocation.startsWith(AppRoutes.community)) {
      selectedIndex = 4;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(l10n.profile.myPage)),
      body: ListView(
        children: [
          // 프로필 섹션 (애니메이션 적용)
          FadeTransition(
            opacity: _profileFadeAnimation,
            child: ScaleTransition(
              scale: _profileScaleAnimation,
              child: MyPageProfileSection(
                theme: theme,
                primaryColor: primaryColor,
                isAuthenticated: isAuthenticated,
                currentUser: currentUser,
                mainParishId: mainParishId,
              ),
            ),
          ),

          // 설정 섹션 (애니메이션 적용)
          FadeTransition(
            opacity: _settingsFadeAnimation,
            child: SlideTransition(
              position: _settingsSlideAnimation,
              child: MyPageSettingsSection(
                primaryColor: primaryColor,
                isAuthenticated: isAuthenticated,
                favoriteParishCount: currentUser?.favoriteParishIds.length,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 로그인/로그아웃 버튼 (애니메이션 적용)
          FadeTransition(
            opacity: _buttonFadeAnimation,
            child: MyPageAuthButton(
              primaryColor: primaryColor,
              isAuthenticated: isAuthenticated,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: MyPageNavigationBar(
        selectedIndex: selectedIndex,
        primaryColor: primaryColor,
        theme: theme,
      ),
    );
  }
}
