import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_localizations.dart';

/// 메인 네비게이션이 포함된 Scaffold
class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        height: 72, // 네비게이션 바 높이 증가 (라벨 포함)
        indicatorShape: const CircleBorder(), // 정원형 배경
        indicatorColor: primaryColor.withValues(alpha: 0.2), // 배경 색상
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
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navigation.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.navigation.meditation,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add),
            selectedIcon: const Icon(Icons.add),
            label: l10n.navigation.share,
          ),
          NavigationDestination(
            icon: const Icon(Icons.church_outlined),
            selectedIcon: const Icon(Icons.church),
            label: l10n.navigation.church,
          ),
          NavigationDestination(
            icon: const Icon(Icons.forum_outlined),
            selectedIcon: const Icon(Icons.forum),
            label: l10n.navigation.community,
          ),
        ],
      ),
    );
  }
}
