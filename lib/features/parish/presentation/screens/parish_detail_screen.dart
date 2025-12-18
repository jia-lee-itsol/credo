import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/data/services/parish_service.dart' as core;
import '../widgets/parish_detail_header.dart';
import '../widgets/parish_detail_basic_info.dart';
import '../widgets/parish_detail_actions.dart';
import '../widgets/parish_detail_mass_times.dart';

/// 교회 상세 화면
class ParishDetailScreen extends ConsumerWidget {
  final String parishId;

  const ParishDetailScreen({super.key, required this.parishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final currentUser = ref.watch(currentUserProvider);

    // 실제 데이터 조회
    final parishAsync = ref.watch(core.parishByIdProvider(parishId));

    // 즐겨찾기 여부 확인
    final isFavorite =
        currentUser?.favoriteParishIds.contains(parishId) ?? false;

    return parishAsync.when(
      data: (parish) {
        if (parish == null || parish.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.parish.detail)),
            body: Center(child: Text(l10n.parish.notFound)),
          );
        }

        final parishName = parish['name'] as String? ?? '';

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 헤더
              ParishDetailHeader(
                parishName: parishName,
                parishId: parishId,
                address: parish['address'] as String?,
                isFavorite: isFavorite,
                onFavoriteToggle: () => _toggleFavorite(
                  context,
                  ref,
                  isFavorite,
                ),
              ),

              // 기본 정보
              SliverToBoxAdapter(
                child: ParishDetailBasicInfo(
                  parish: parish,
                  primaryColor: primaryColor,
                  l10n: l10n,
                ),
              ),

              // 액션 버튼 (지도, 커뮤니티)
              SliverToBoxAdapter(
                child: ParishDetailActions(
                  parish: parish,
                  parishId: parishId,
                  primaryColor: primaryColor,
                  l10n: l10n,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 미사 시간
              SliverToBoxAdapter(
                child: ParishDetailMassTimes(
                  parish: parish,
                  primaryColor: primaryColor,
                  l10n: l10n,
                ),
              ),

              // 하단 여백
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.parish.detail)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.parish.detail)),
        body: Center(child: Text('${l10n.community.errorOccurred}: $error')),
      ),
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    bool isCurrentlyFavorite,
  ) async {
    final l10n = ref.read(appLocalizationsSyncProvider);
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.auth.loginRequired),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 소속 성당은 즐겨찾기에서 제거할 수 없음
    if (isCurrentlyFavorite && parishId == currentUser.mainParishId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.parish.cannotRemoveParish),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final repository = ref.read(authRepositoryProvider);
    final updatedFavorites = List<String>.from(currentUser.favoriteParishIds);

    if (isCurrentlyFavorite) {
      updatedFavorites.remove(parishId);
    } else {
      updatedFavorites.add(parishId);
    }

    final result = await repository.updateProfile(
      favoriteParishIds: updatedFavorites,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (updatedUser) {
        // authStateProvider를 직접 업데이트하여 즉시 UI 반영
        ref.read(authStateProvider.notifier).state = updatedUser;
        // StreamProvider도 무효화하여 다음 스트림 업데이트 시 최신 데이터 유지
        ref.invalidate(authStateStreamProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyFavorite
                  ? l10n.common.favoriteRemoved
                  : l10n.common.favoriteAdded,
            ),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }
}
