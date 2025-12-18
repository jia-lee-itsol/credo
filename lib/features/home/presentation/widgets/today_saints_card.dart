import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
import '../widgets/home_action_button.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';

/// 오늘의 성인 카드 (HomeActionButton 스타일)
class TodaySaintsCard extends ConsumerWidget {
  const TodaySaintsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: HomeActionButton(
        icon: Icons.star,
        title: l10n.saints.todaySaints,
        subtitle: l10n.saints.todaySaintsSubtitle,
        primaryColor: primaryColor,
        backgroundColor: primaryColor.withValues(alpha: 0.1),
        onTap: () => context.go(AppRoutes.todaySaints),
      ),
    );
  }
}

