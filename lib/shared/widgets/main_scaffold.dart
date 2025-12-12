import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 메인 네비게이션이 포함된 Scaffold
class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '黙想',
          ),
          NavigationDestination(
            icon: Icon(Icons.add),
            selectedIcon: Icon(Icons.add),
            label: '共有',
          ),
          NavigationDestination(
            icon: Icon(Icons.church_outlined),
            selectedIcon: Icon(Icons.church),
            label: '教会',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'コミュニティ',
          ),
        ],
      ),
    );
  }
}
