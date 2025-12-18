import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/utils/share_utils.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';

/// 성당 상세 화면 헤더 위젯
class ParishDetailHeader extends ConsumerWidget {
  final String parishName;
  final String parishId;
  final String? address;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ParishDetailHeader({
    super.key,
    required this.parishName,
    required this.parishId,
    this.address,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          parishName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withValues(alpha: 0.3),
                primaryColor.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.church,
              size: 80,
              color: primaryColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () => _shareParish(context, ref),
        ),
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: onFavoriteToggle,
        ),
      ],
    );
  }

  Future<void> _shareParish(BuildContext context, WidgetRef ref) async {
    try {
      final l10n = ref.read(appLocalizationsSyncProvider);
      await ShareUtils.shareParish(
        parishName: parishName,
        parishId: parishId,
        address: address,
        l10n: l10n,
      );
    } catch (e) {
      if (context.mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.common.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

