import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_localizations.dart';
import '../providers/liturgy_theme_provider.dart';
import 'offline_indicator.dart';

/// 메인 네비게이션이 포함된 Scaffold
class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Scaffold(
      body: Column(
        children: [
          // 오프라인 상태 표시
          const OfflineIndicator(),
          // 메인 콘텐츠
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: primaryColor, width: 1.5),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          height: 72, // 네비게이션 바 높이 증가 (라벨 포함)
          backgroundColor: Colors.white,
          indicatorShape: const CircleBorder(), // 정원형 배경
          indicatorColor: primaryColor, // 진한 전례색 배경
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            // 선택된 항목의 라벨 색상
            if (states.contains(WidgetState.selected)) {
              return TextStyle(color: primaryColor);
            }
            // 선택되지 않은 항목의 라벨 색상
            return TextStyle(color: theme.colorScheme.onSurfaceVariant);
          }),
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: const Icon(Icons.auto_awesome_outlined, color: Colors.white),
              label: l10n.navigation.home,
            ),
            NavigationDestination(
              icon: Icon(Icons.article_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: const Icon(Icons.article_outlined, color: Colors.white),
              label: l10n.navigation.meditation,
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: const Icon(Icons.auto_stories_outlined, color: Colors.white),
              label: l10n.navigation.dailyMass,
            ),
            NavigationDestination(
              icon: Icon(Icons.church_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: const Icon(Icons.church_outlined, color: Colors.white),
              label: l10n.navigation.church,
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              label: l10n.navigation.community,
            ),
          ],
        ),
      ),
    );
  }
}
