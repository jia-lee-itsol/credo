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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
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

    return Scaffold(
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

            // 섹션 타이틀: 最近のお知らせ
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                context,
                l10n.community.home.recentNotices,
              ),
            ),

            // お知らせ 리스트
            SliverToBoxAdapter(
              child: _buildNotificationsList(context, ref, theme, primaryColor),
            ),

            // 하단 여백
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
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

  Widget _buildNotificationsList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Color primaryColor,
  ) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      AppLogger.notification('currentUser가 null입니다');
      return _buildNoticesPlaceholder(context, theme, l10n);
    }

    AppLogger.notification('알림 조회 시작: userId=${currentUser.userId}');
    final notificationsAsync = ref.watch(
      notificationsProvider(currentUser.userId),
    );

    return notificationsAsync.when(
      data: (notifications) {
        AppLogger.notification('알림 데이터 수신: ${notifications.length}개');
        for (final n in notifications) {
          AppLogger.debug(
            '알림: id=${n.notificationId}, type=${n.type}, title=${n.title}, body=${n.body}',
          );
        }
        if (notifications.isEmpty) {
          return _buildNoticesPlaceholder(context, theme, l10n);
        }

        // 최근 5개만 표시
        final recentNotifications = notifications.take(5).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: recentNotifications.map((notification) {
              return Dismissible(
                key: Key(notification.notificationId),
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
                  ref
                      .read(notificationRepositoryProvider)
                      .deleteNotification(notification.notificationId);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getNotificationColor(
                        notification.type,
                      ).withValues(alpha: 0.1),
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        color: _getNotificationColor(notification.type),
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
                              notification.type,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getNotificationLabel(notification.type, l10n),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getNotificationColor(notification.type),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification.authorName ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    trailing: notification.isRead
                        ? const Icon(Icons.chevron_right, color: Colors.grey)
                        : Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getNotificationColor(notification.type),
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: () async {
                      // 알림 읽음 처리
                      if (!notification.isRead) {
                        ref
                            .read(notificationRepositoryProvider)
                            .markAsRead(notification.notificationId);
                      }

                      // 게시글 상세 화면으로 이동
                      final postId = notification.postId;
                      if (postId != null && postId.isNotEmpty) {
                        final post = await ref.read(
                          postByIdProvider(postId).future,
                        );
                        final parishId = post?.parishId ?? '';
                        if (context.mounted) {
                          context.push(
                            AppRoutes.postDetailPath(parishId, postId),
                          );
                        }
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
        AppLogger.notification('알림 로딩 중...');
        return _buildNoticesPlaceholder(context, theme, l10n);
      },
      error: (error, stack) {
        AppLogger.error('알림 조회 에러: $error', error, stack);
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
