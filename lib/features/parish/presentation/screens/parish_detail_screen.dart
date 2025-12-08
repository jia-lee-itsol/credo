import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/providers/liturgy_theme_provider.dart';
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

    // 실제 데이터 조회
    final parishAsync = ref.watch(parishByIdProvider(parishId));

    return parishAsync.when(
      data: (parish) {
        if (parish == null || parish.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('教会詳細')),
            body: const Center(
              child: Text('教会情報が見つかりませんでした'),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 앱바
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    parish['name'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: 즐겨찾기 토글
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('お気に入りに追加しました')));
                },
              ),
            ],
          ),

          // 기본 정보
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 주소
                  if (parish['address'] != null)
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on,
                      title: '住所',
                      content: '${parish['prefecture'] as String? ?? ''} ${parish['address'] as String? ?? ''}',
                      primaryColor: primaryColor,
                    ),
                  if (parish['address'] != null) const SizedBox(height: 16),

                  // 전화번호
                  if (parish['phone'] != null && (parish['phone'] as String).isNotEmpty)
                    _buildInfoRow(
                      context,
                      icon: Icons.phone,
                      title: '電話',
                      content: parish['phone'] as String,
                      primaryColor: primaryColor,
                      onTap: () => _launchPhone(parish['phone'] as String),
                    ),
                  if (parish['phone'] != null && (parish['phone'] as String).isNotEmpty)
                    const SizedBox(height: 16),

                  // 팩스
                  if (parish['fax'] != null && (parish['fax'] as String).isNotEmpty)
                    _buildInfoRow(
                      context,
                      icon: Icons.fax,
                      title: 'FAX',
                      content: parish['fax'] as String,
                      primaryColor: primaryColor,
                    ),
                  if (parish['fax'] != null && (parish['fax'] as String).isNotEmpty)
                    const SizedBox(height: 16),

                  // 웹사이트
                  if (parish['website'] != null && (parish['website'] as String).isNotEmpty)
                    _buildInfoRow(
                      context,
                      icon: Icons.language,
                      title: 'ウェブサイト',
                      content: parish['website'] as String,
                      primaryColor: primaryColor,
                      onTap: () => _launchUrl(parish['website'] as String),
                    ),
                  if (parish['website'] != null && (parish['website'] as String).isNotEmpty)
                    const SizedBox(height: 16),

                  // 지도 버튼 (주소가 있으면 표시)
                  if (parish['address'] != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final address = '${parish['prefecture'] as String? ?? ''} ${parish['address'] as String? ?? ''}';
                          _launchMapByAddress(address);
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('地図アプリで開く'),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 미사 시간
          SliverToBoxAdapter(
            child: Padding(
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
                  _buildMassTimeTable(context, primaryColor, parish),
                ],
              ),
            ),
          ),

          // 커뮤니티 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push(AppRoutes.communityParishPath(parishId));
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
        body: Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color primaryColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: onTap != null ? primaryColor : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMassTimeTable(
    BuildContext context,
    Color primaryColor,
    Map<String, dynamic> parish,
  ) {
    final theme = Theme.of(context);
    final massTime = parish['massTime'] as String?;

    if (massTime == null || massTime.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'ミサ時間情報がありません',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          massTime,
          style: theme.textTheme.bodyLarge,
        ),
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
