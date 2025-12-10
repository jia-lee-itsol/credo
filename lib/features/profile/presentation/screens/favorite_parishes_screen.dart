import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/parish_service.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';

/// 자주 가는 교회 화면
class FavoriteParishesScreen extends ConsumerStatefulWidget {
  const FavoriteParishesScreen({super.key});

  @override
  ConsumerState<FavoriteParishesScreen> createState() =>
      _FavoriteParishesScreenState();
}

class _FavoriteParishesScreenState
    extends ConsumerState<FavoriteParishesScreen> {
  bool _hasCheckedMainParish = false;

  @override
  void initState() {
    super.initState();
    // 다음 프레임에서 체크하도록 지연
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureMainParishInFavorites();
    });
  }

  void _ensureMainParishInFavorites() {
    if (_hasCheckedMainParish) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final mainParishId = currentUser.mainParishId;
    if (mainParishId == null) {
      _hasCheckedMainParish = true;
      return;
    }

    final favoriteParishIds = currentUser.favoriteParishIds;
    if (favoriteParishIds.contains(mainParishId)) {
      _hasCheckedMainParish = true;
      return;
    }

    // 소속 성당이 자주 가는 성당 리스트에 없으면 자동 추가
    _hasCheckedMainParish = true;
    final repository = ref.read(authRepositoryProvider);
    final updatedFavorites = List<String>.from(favoriteParishIds)
      ..add(mainParishId);

    repository.updateProfile(favoriteParishIds: updatedFavorites).then((
      result,
    ) {
      result.fold(
        (failure) {
          // 실패해도 조용히 처리 (사용자에게 알리지 않음)
        },
        (updatedUser) {
          if (mounted) {
            ref.read(authStateProvider.notifier).state = updatedUser;
            ref.invalidate(authStateStreamProvider);
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);
    final favoriteParishIds = currentUser?.favoriteParishIds ?? [];

    // currentUser가 변경될 때마다 체크
    if (currentUser != null && !_hasCheckedMainParish) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureMainParishInFavorites();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('よく行く教会'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.go(AppRoutes.parishList);
            },
            tooltip: '教会を検索',
          ),
        ],
      ),
      body: favoriteParishIds.isEmpty
          ? _buildEmptyState(context, theme, primaryColor)
          : _buildParishList(
              context,
              ref,
              theme,
              primaryColor,
              favoriteParishIds,
            ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '登録された教会がありません',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '教会を検索して追加してください',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.go(AppRoutes.parishList);
            },
            icon: const Icon(Icons.search),
            label: const Text('教会を検索'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParishList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Color primaryColor,
    List<String> favoriteParishIds,
  ) {
    return ListView.builder(
      key: const PageStorageKey('favoriteParishesList'),
      padding: const EdgeInsets.all(16),
      itemCount: favoriteParishIds.length,
      itemBuilder: (context, index) {
        final parishId = favoriteParishIds[index];
        return _FavoriteParishTile(
          key: ValueKey('favoriteParish_$parishId'),
          parishId: parishId,
          primaryColor: primaryColor,
          onTap: () {
            // myPage 내부의 중첩 라우트로 push하여 뒤로가기로 돌아올 수 있도록 함
            context.push('/my-page/favorite-parishes/parish/$parishId');
          },
          onRemove: () async {
            await _removeFavoriteParish(context, ref, parishId);
          },
        );
      },
    );
  }

  Future<void> _removeFavoriteParish(
    BuildContext context,
    WidgetRef ref,
    String parishId,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    // 소속 성당은 삭제할 수 없음
    if (parishId == currentUser.mainParishId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('所属教会は削除できません'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final repository = ref.read(authRepositoryProvider);
    final updatedFavorites = List<String>.from(currentUser.favoriteParishIds)
      ..remove(parishId);

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
          const SnackBar(
            content: Text('削除しました'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }
}

class _FavoriteParishTile extends ConsumerWidget {
  final String parishId;
  final Color primaryColor;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteParishTile({
    super.key,
    required this.parishId,
    required this.primaryColor,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isMainParish = parishId == currentUser?.mainParishId;
    final parishAsync = ref.watch(parishByIdProvider(parishId));

    return parishAsync.when(
      data: (parish) {
        if (parish == null) {
          return const SizedBox.shrink();
        }

        final name = parish['name'] as String? ?? '';
        final address = parish['address'] as String? ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.church, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 소속 성당이 아닌 경우에만 삭제 버튼 표시
                  if (!isMainParish)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade300,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('削除'),
                            content: Text('$nameを削除しますか？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onRemove();
                                },
                                child: Text(
                                  '削除',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    // 소속 성당인 경우 표시
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.star, color: primaryColor, size: 20),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('読み込み中...'),
        ),
      ),
      error: (error, _) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(Icons.error_outline, color: Colors.red),
          title: Text('エラー: $error'),
        ),
      ),
    );
  }
}
