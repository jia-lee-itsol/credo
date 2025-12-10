import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/prayer_service.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/expandable_content_card.dart';

/// 주요기도문 화면
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);
    final prayersAsync = ref.watch(prayersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('主な祈り'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.myPage);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                backgroundImage: currentUser?.profileImageUrl != null
                    ? NetworkImage(currentUser!.profileImageUrl!)
                    : null,
                child: currentUser?.profileImageUrl == null
                    ? Icon(Icons.person, size: 20, color: primaryColor)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: prayersAsync.when(
        data: (prayers) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: prayers.length,
          itemBuilder: (context, index) {
            final prayer = prayers[index];
            return ExpandableContentCard(
              title: prayer.title,
              subtitle: prayer.subtitle,
              icon: _getIconData(prayer.icon),
              primaryColor: primaryColor,
              content: prayer.content,
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('エラーが発生しました: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(prayersProvider),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'brightness_7':
        return Icons.brightness_7;
      case 'book':
        return Icons.book;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'route':
        return Icons.route;
      case 'restaurant':
        return Icons.restaurant;
      case 'coffee':
        return Icons.coffee;
      case 'church':
        return Icons.church;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'bedtime':
        return Icons.bedtime;
      case 'person':
        return Icons.person;
      case 'shield':
        return Icons.shield;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.article;
    }
  }
}
