import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/liturgy_constants.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../community/presentation/providers/community_presentation_providers.dart';
import '../widgets/home_header.dart';
import '../widgets/home_action_button.dart';

/// 홈 화면
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 삭제된 게시글 ID를 추적하는 Set
  final Set<String> _dismissedPostIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10nAsync = ref.watch(appLocalizationsProvider);
    final currentLocale = ref.watch(localeProvider);

    final seasonAsync = ref.watch(currentLiturgySeasonProvider);
    final testDate = ref.watch(testDateOverrideProvider);
    final season =
        seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync(testDate);
    final seasonName = LiturgySeasonUtil.getSeasonName(
      season,
      locale: currentLocale.languageCode,
    );
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final backgroundColor = ref.watch(liturgyBackgroundColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    return l10nAsync.when(
      data: (l10n) => Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            // 알림 provider 새로고침
            if (currentUser != null) {
              ref.invalidate(notificationsProvider(currentUser.userId));
            }
          },
          child: CustomScrollView(
            slivers: [
              // 헤더
              SliverToBoxAdapter(
                child: HomeHeader(
                  season: season,
                  seasonName: seasonName,
                  primaryColor: primaryColor,
                  backgroundColor: backgroundColor,
                ),
              ),

              // 근처 교회 찾기 버튼
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: HomeActionButton(
                    icon: Icons.location_on_outlined,
                    title: l10n.parish.search,
                    subtitle: l10n.parish.searchFromCurrentLocation,
                    primaryColor: primaryColor,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    onTap: () => context.go(AppRoutes.parishList),
                  ),
                ),
              ),

              // 오늘의 미사 버튼
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: HomeActionButton(
                    icon: Icons.auto_stories,
                    title: l10n.community.home.todayMass,
                    subtitle: l10n.community.home.todayBibleReadingAndPrayer,
                    primaryColor: primaryColor,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    onTap: () => context.go(AppRoutes.dailyMass),
                  ),
                ),
              ),

              // 섹션 타이틀
              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  context,
                  l10n.community.home.recentNotices,
                ),
              ),

              // 공지사항 리스트
              SliverToBoxAdapter(
                child: _buildRecentNoticesList(
                  context,
                  ref,
                  theme,
                  primaryColor,
                  l10n,
                  currentUser?.mainParishId,
                ),
              ),

              // 하단 여백
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 최근 공지사항 리스트 빌드
  Widget _buildRecentNoticesList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Color primaryColor,
    AppLocalizations l10n,
    String? parishId,
  ) {
    if (parishId == null) {
      return _buildNoticesPlaceholder(context, theme, l10n);
    }

    final noticesAsync = ref.watch(officialNoticesProvider(parishId));

    return noticesAsync.when(
      data: (notices) {
        if (notices.isEmpty) {
          return _buildNoticesPlaceholder(context, theme, l10n);
        }

        // 삭제된 게시글 제외
        final filteredNotices = notices
            .where((post) => !_dismissedPostIds.contains(post.postId))
            .take(5)
            .toList();

        if (filteredNotices.isEmpty) {
          return _buildNoticesPlaceholder(context, theme, l10n);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: filteredNotices.map((post) {
              // 게시글을 알림 형태로 변환
              final notificationType = 'notice'; // 공지글은 항상 notice 타입
              final notificationTitle = post.title;
              final notificationBody = post.body.split('\n').first;

              return Dismissible(
                key: Key(post.postId),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // 삭제된 게시글 ID를 Set에 추가하여 리스트에서 제외
                  setState(() {
                    _dismissedPostIds.add(post.postId);
                  });
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getNotificationColor(
                        notificationType,
                      ).withValues(alpha: 0.1),
                      child: Icon(
                        _getNotificationIcon(notificationType),
                        color: _getNotificationColor(notificationType),
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getNotificationColor(
                              notificationType,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getNotificationLabel(notificationType, l10n),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getNotificationColor(notificationType),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notificationTitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notificationBody,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    trailing: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getNotificationColor(notificationType),
                        shape: BoxShape.circle,
                      ),
                    ),
                    onTap: () {
                      if (post.parishId != null) {
                        context.push(
                          AppRoutes.postDetailPath(post.parishId!, post.postId),
                        );
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stack) {
        AppLogger.error('공지사항 조회 에러: $error', error, stack);
        return _buildNoticesPlaceholder(context, theme, l10n);
      },
    );
  }

  Widget _buildNoticesPlaceholder(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 40,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.community.home.noNotices,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 알림 타입에 따른 색상
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'mention':
        return Colors.blue;
      case 'notice':
        return Colors.orange;
      case 'comment':
      default:
        return const Color(0xFF722F37); // primaryColor
    }
  }

  /// 알림 타입에 따른 아이콘
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'mention':
        return Icons.alternate_email;
      case 'notice':
        return Icons.campaign;
      case 'comment':
      default:
        return Icons.chat_bubble_outline;
    }
  }

  /// 알림 타입에 따른 라벨
  String _getNotificationLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'mention':
        return l10n.community.notificationLabels.mention;
      case 'notice':
        return l10n.community.notificationLabels.notice;
      case 'comment':
      default:
        return l10n.community.notificationLabels.comment;
    }
  }
}
