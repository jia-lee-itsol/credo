import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/utils/share_utils.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';

/// 성당 상세 화면 헤더 위젯
class ParishDetailHeader extends ConsumerWidget {
  final String parishName;
  final String parishId;
  final String? address;
  final String? imageUrl;
  final bool isFavorite;
  final bool canEditImage;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onEditImage;

  const ParishDetailHeader({
    super.key,
    required this.parishName,
    required this.parishId,
    this.address,
    this.imageUrl,
    required this.isFavorite,
    this.canEditImage = false,
    required this.onFavoriteToggle,
    this.onEditImage,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        background: GestureDetector(
          onLongPress: canEditImage ? onEditImage : null,
          child: _buildBackground(primaryColor),
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

  Widget _buildBackground(Color primaryColor) {
    // 이미지 URL이 있으면 이미지 표시
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(primaryColor),
            errorWidget: (context, url, error) => _buildPlaceholder(primaryColor),
          ),
          // 그라데이션 오버레이 (텍스트 가독성)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 이미지가 없으면 기본 플레이스홀더
    return _buildPlaceholder(primaryColor);
  }

  Widget _buildPlaceholder(Color primaryColor) {
    return Container(
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
    );
  }

  Future<void> _shareParish(BuildContext context, WidgetRef ref) async {
    try {
      final l10n = ref.read(appLocalizationsSyncProvider);
      await ShareUtils.shareParish(
        context: context,
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
