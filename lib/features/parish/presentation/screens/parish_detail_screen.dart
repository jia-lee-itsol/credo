import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/parish_service.dart';

/// 교회 상세 화면
class ParishDetailScreen extends ConsumerWidget {
  final String parishId;

  const ParishDetailScreen({super.key, required this.parishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    // 실제 데이터 조회
    final parishAsync = ref.watch(parishByIdProvider(parishId));

    // 즐겨찾기 여부 확인
    final isFavorite =
        currentUser?.favoriteParishIds.contains(parishId) ?? false;

    return parishAsync.when(
      data: (parish) {
        if (parish == null || parish.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('教会詳細')),
            body: const Center(child: Text('教会情報が見つかりませんでした')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 앱바
              _buildSliverAppBar(
                context,
                ref,
                parish,
                primaryColor,
                isFavorite,
              ),

              // 기본 정보
              SliverToBoxAdapter(
                child: _buildBasicInfo(context, parish, primaryColor),
              ),

              // 미사 시간
              SliverToBoxAdapter(
                child: _buildMassTimeSection(
                  context,
                  theme,
                  primaryColor,
                  parish,
                ),
              ),

              // 커뮤니티 버튼
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // parishId를 명시적으로 사용하여 올바른 교회로 이동
                      // 클로저에서 최신 값을 사용하도록 보장
                      final targetParishId = parishId;

                      // 현재 경로가 myPage 내부인 경우 go 사용, 아니면 push 사용
                      final currentLocation = GoRouterState.of(
                        context,
                      ).matchedLocation;

                      if (currentLocation.startsWith('/my-page')) {
                        // myPage 내부에서 접근한 경우 go 사용 (StatefulShellRoute 브랜치로 이동)
                        // 전체 경로를 명시적으로 지정하여 올바른 parishId 전달
                        // GoRouter는 자동으로 URL 인코딩/디코딩을 처리함
                        context.go('/community/$targetParishId');
                      } else {
                        // parish 브랜치에서 접근한 경우 push 사용
                        context.push(
                          AppRoutes.communityParishPath(targetParishId),
                        );
                      }
                    },
                    icon: const Icon(Icons.forum),
                    label: const Text('この教会のコミュニティを見る'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              // 하단 여백
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('教会詳細')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('教会詳細')),
        body: Center(child: Text('エラーが発生しました: $error')),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> parish,
    Color primaryColor,
    bool isFavorite,
  ) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          parish['name'] as String? ?? '',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: () => _toggleFavorite(context, ref, isFavorite),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    bool isCurrentlyFavorite,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ログインが必要です'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 소속 성당은 즐겨찾기에서 제거할 수 없음
    if (isCurrentlyFavorite && parishId == currentUser.mainParishId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('所属教会はお気に入りから削除できません'),
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
              isCurrentlyFavorite ? 'お気に入りから削除しました' : 'お気に入りに追加しました',
            ),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Widget _buildBasicInfo(
    BuildContext context,
    Map<String, dynamic> parish,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주소
          if (parish['address'] != null) ...[
            InfoRow(
              icon: Icons.location_on,
              title: '住所',
              content:
                  '${parish['prefecture'] as String? ?? ''} ${parish['address'] as String? ?? ''}',
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 16),
          ],

          // 전화번호
          if (parish['phone'] != null &&
              (parish['phone'] as String).isNotEmpty) ...[
            InfoRow(
              icon: Icons.phone,
              title: '電話',
              content: parish['phone'] as String,
              primaryColor: primaryColor,
              onTap: () => _launchPhone(parish['phone'] as String),
            ),
            const SizedBox(height: 16),
          ],

          // 팩스
          if (parish['fax'] != null &&
              (parish['fax'] as String).isNotEmpty) ...[
            InfoRow(
              icon: Icons.fax,
              title: 'FAX',
              content: parish['fax'] as String,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 16),
          ],

          // 웹사이트
          if (parish['website'] != null &&
              (parish['website'] as String).isNotEmpty) ...[
            InfoRow(
              icon: Icons.language,
              title: 'ウェブサイト',
              content: parish['website'] as String,
              primaryColor: primaryColor,
              onTap: () => _launchUrl(parish['website'] as String),
            ),
            const SizedBox(height: 16),
          ],

          // 지도 버튼 (주소가 있으면 표시)
          if (parish['address'] != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final address =
                      '${parish['prefecture'] as String? ?? ''} ${parish['address'] as String? ?? ''}';
                  _launchMapByAddress(address);
                },
                icon: const Icon(Icons.map),
                label: const Text('地図アプリで開く'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMassTimeSection(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    Map<String, dynamic> parish,
  ) {
    final massTime = parish['massTime'] as String?;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ミサ時間',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: massTime == null || massTime.isEmpty
                  ? Text(
                      'ミサ時間情報がありません',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Text(massTime, style: theme.textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMapByAddress(String address) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
