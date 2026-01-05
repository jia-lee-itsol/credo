import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/liturgy_constants.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../community/presentation/providers/community_presentation_providers.dart';
import '../../../community/data/models/post.dart';
import '../../../saints/presentation/providers/saint_feast_day_providers.dart';
import '../../../saints/presentation/widgets/saint_feast_day_modal.dart';
import '../../../../core/data/services/parish_service.dart';
import '../../../../core/data/services/saint_feast_day_service.dart';
import '../widgets/home_header.dart';
import '../widgets/home_action_button.dart';
import '../widgets/today_saints_card.dart';
import '../widgets/daily_reflection_card.dart';
import '../providers/daily_reflection_provider.dart';
import '../../../../shared/widgets/animated_list_item.dart';

/// 홈 화면
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 삭제된 게시글 ID를 추적하는 Set
  final Set<String> _dismissedPostIds = {};
  bool _hasShownSaintModal = false;
  // 성당별 아코디언 상태 (기본값: false = 접힘)
  final Map<String?, bool> _parishExpandedState = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkAndShowSaintModal() async {
    if (_hasShownSaintModal || !mounted) return;

    // SharedPreferences에서 오늘 날짜 확인
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey =
        'saint_modal_shown_${today.year}_${today.month}_${today.day}';
    final hasShownToday = prefs.getBool(todayKey) ?? false;

    if (hasShownToday) {
      _hasShownSaintModal = true;
      return;
    }

    // FutureProvider를 watch하여 데이터가 로드되면 모달 표시
    final userBaptismalSaintAsync = ref.watch(userBaptismalSaintProvider);
    userBaptismalSaintAsync.whenData((saint) async {
      if (saint != null && mounted && !_hasShownSaintModal) {
        _hasShownSaintModal = true;

        // 오늘 날짜로 표시 여부 저장
        await prefs.setBool(todayKey, true);

        final currentUser = ref.read(currentUserProvider);
        Future.microtask(() {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => SaintFeastDayModal(
                saint: saint,
                userBaptismalName: currentUser?.baptismalName,
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10nAsync = ref.watch(appLocalizationsProvider);
    final currentLocale = ref.watch(localeProvider);

    final seasonAsync = ref.watch(currentLiturgySeasonProvider);
    final testDate = ref.watch(testDateOverrideProvider);
    final season =
        seasonAsync.value ?? LiturgySeasonUtil.getCurrentSeasonSync(testDate);
    final seasonName = ref.watch(liturgyDayNameProvider(currentLocale.languageCode));
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final backgroundColor = ref.watch(liturgyBackgroundColorProvider);
    final gradientStartColor = ref.watch(liturgyGradientStartColorProvider);
    final gradientEndColor = ref.watch(liturgyGradientEndColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    // 성인 축일 모달 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowSaintModal();
    });

    return l10nAsync.when(
      data: (l10n) => Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            // 성인 캐시 삭제 및 새로고침
            await SaintFeastDayService.clearTodaySaintsCache();

            // 전례력 캐시 삭제
            await clearLiturgyCache();

            // 묵상 한마디 새로고침
            await refreshDailyReflection(ref);

            // 전례력 정보 새로고침
            final date = testDate ?? DateTime.now();
            ref.invalidate(liturgyInfoFromChatGPTProvider(date));
            ref.invalidate(currentLiturgySeasonProvider);

            // 성인 Provider 새로고침
            ref.invalidate(todaySaintsProvider);

            // 묵상 Provider 새로고침
            ref.invalidate(dailyReflectionProvider);

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
                  gradientStartColor: gradientStartColor,
                  gradientEndColor: gradientEndColor,
                ),
              ),

              // 오늘의 묵상 한마디 카드
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 0,
                  child: const DailyReflectionCard(),
                ),
              ),

              // 오늘의 미사 버튼
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: HomeActionButton(
                      icon: Icons.menu_book,
                      title: l10n.community.home.todayMass,
                      subtitle: l10n.community.home.todayBibleReadingAndPrayer,
                      primaryColor: primaryColor,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      onTap: () => context.go(AppRoutes.dailyMass),
                    ),
                  ),
                ),
              ),

              // 오늘의 성인 카드
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 2,
                  child: const TodaySaintsCard(),
                ),
              ),

              // 섹션 타이틀
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 3,
                  child: _buildSectionTitle(
                    context,
                    l10n.community.home.recentNotifications,
                  ),
                ),
              ),

              // 알림 리스트
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 4,
                  child: _buildRecentNotificationsList(
                    context,
                    ref,
                    theme,
                    primaryColor,
                    l10n,
                    currentUser,
                  ),
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
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// 최근 알림 리스트 빌드
  Widget _buildRecentNotificationsList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Color primaryColor,
    AppLocalizations l10n,
    UserEntity? currentUser,
  ) {
    // 소속 교회와 자주 가는 교회 목록 생성
    final parishIds = <String>[];
    if (currentUser?.mainParishId != null) {
      parishIds.add(currentUser!.mainParishId!);
    }
    if (currentUser?.favoriteParishIds != null) {
      parishIds.addAll(currentUser!.favoriteParishIds);
    }
    // 중복 제거
    final uniqueParishIds = parishIds.toSet().toList();

    if (uniqueParishIds.isEmpty) {
      return _buildNotificationsPlaceholder(context, theme, l10n);
    }

    // 리스트를 쉼표로 구분된 문자열로 변환 (provider 키 안정화)
    final parishIdsKey = uniqueParishIds.join(',');

    final postsAsync = ref.watch(allPostsByParishesProvider(parishIdsKey));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return _buildNotificationsPlaceholder(context, theme, l10n);
        }

        // 삭제된 게시글 제외
        final filteredPosts = posts
            .where((post) => !_dismissedPostIds.contains(post.postId))
            .toList();

        if (filteredPosts.isEmpty) {
          return _buildNotificationsPlaceholder(context, theme, l10n);
        }

        // 성당별로 그룹화
        final Map<String?, List<Post>> postsByParish = {};
        for (final post in filteredPosts) {
          final parishId = post.parishId;
          if (!postsByParish.containsKey(parishId)) {
            postsByParish[parishId] = [];
          }
          postsByParish[parishId]!.add(post);
        }

        // 각 성당별로 최대 5개까지만 표시
        final limitedPostsByParish = <String?, List<Post>>{};
        for (final entry in postsByParish.entries) {
          limitedPostsByParish[entry.key] = entry.value.take(5).toList();
        }

        final currentUserId = currentUser?.userId;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: limitedPostsByParish.entries.map((entry) {
              final parishId = entry.key;
              final parishPosts = entry.value;

              return _buildParishNotificationCard(
                context,
                ref,
                theme,
                primaryColor,
                l10n,
                currentUserId,
                parishId,
                parishPosts,
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
        return _buildNotificationsPlaceholder(context, theme, l10n);
      },
    );
  }

  /// 성당별 알림 카드 빌드
  Widget _buildParishNotificationCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Color primaryColor,
    AppLocalizations l10n,
    String? currentUserId,
    String? parishId,
    List<Post> posts,
  ) {
    // 성당 정보 가져오기
    final parishAsync = parishId != null
        ? ref.watch(parishByIdProvider(parishId))
        : null;
    final isExpanded = _parishExpandedState[parishId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 성당 이름 헤더 (아코디언 토글)
            Material(
              color: isExpanded
                  ? primaryColor.withValues(alpha: 0.05)
                  : Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _parishExpandedState[parishId] = !isExpanded;
                  });
                },
                splashColor: primaryColor.withValues(alpha: 0.08),
                highlightColor: primaryColor.withValues(alpha: 0.04),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 교회 아이콘 컨테이너
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor.withValues(alpha: 0.15),
                              primaryColor.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.church_outlined,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: parishAsync != null
                            ? parishAsync.when(
                                data: (parishData) => Text(
                                  parishData?['name'] as String? ?? '알 수 없는 성당',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A1A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                loading: () => Text(
                                  '알 수 없는 성당',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A1A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                error: (error, stack) => Text(
                                  '알 수 없는 성당',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A1A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              )
                            : Text(
                                '알 수 없는 성당',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A1A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                      ),
                      // 알림 개수 뱃지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${posts.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 확장/축소 아이콘
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 알림 목록 (아코디언)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  // 구분선
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.15),
                          primaryColor.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  ...posts.map((post) {
                    final isMyPost =
                        currentUserId != null && post.authorId == currentUserId;
                    final hasComments = post.commentCount > 0;

                    String notificationBody;
                    String notificationType;

                    if (post.isNotice) {
                      notificationBody = l10n.community.home.noticeAdded;
                      notificationType = 'notice';
                    } else if (isMyPost && hasComments) {
                      notificationBody = l10n.community.home.commentOnMyPost;
                      notificationType = 'comment';
                    } else {
                      notificationBody = l10n.community.home.newPostAdded;
                      notificationType = 'post';
                    }

                    final notificationColor = _getNotificationColor(notificationType);

                    return Dismissible(
                      key: Key(post.postId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.withValues(alpha: 0.8),
                              Colors.red,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _dismissedPostIds.add(post.postId);
                        });
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (post.parishId != null) {
                              context.push(
                                AppRoutes.postDetailPath(post.parishId!, post.postId),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // 아이콘 컨테이너
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: notificationColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getNotificationIcon(notificationType),
                                    color: notificationColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // 내용
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 타입 태그
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              notificationColor.withValues(alpha: 0.12),
                                              notificationColor.withValues(alpha: 0.06),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _getNotificationLabel(notificationType, l10n),
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: notificationColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // 제목
                                      Text(
                                        notificationBody,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF2D2D2D),
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // 화살표
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsPlaceholder(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.community.home.noNotifications,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B6B6B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
      case 'post':
        return Colors.green;
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
      case 'post':
        return Icons.article;
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
      case 'post':
        return l10n.community.notificationLabels.post;
      case 'comment':
      default:
        return l10n.community.notificationLabels.comment;
    }
  }
}
