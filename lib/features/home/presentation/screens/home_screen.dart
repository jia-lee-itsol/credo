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
import '../../../../core/data/services/saint_feast_day_service.dart' as core;
import '../widgets/home_header.dart';
import '../widgets/home_action_button.dart';
import '../widgets/today_saints_card.dart';
import '../widgets/daily_reflection_card.dart';
import '../providers/daily_reflection_provider.dart';

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
    final seasonName = LiturgySeasonUtil.getSeasonName(
      season,
      locale: currentLocale.languageCode,
    );
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final backgroundColor = ref.watch(liturgyBackgroundColorProvider);
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
            await refreshTodaySaints(ref);

            // 묵상 한마디 새로고침
            await refreshDailyReflection(ref);

            // 전례력 정보 새로고침
            final date = testDate ?? DateTime.now();
            ref.invalidate(liturgyInfoFromChatGPTProvider(date));
            ref.invalidate(currentLiturgySeasonProvider);

            // 성인 Provider 새로고침 (두 곳에 정의된 Provider 모두)
            ref.invalidate(todaySaintsProvider);
            ref.invalidate(core.todaySaintsProvider);

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
                ),
              ),

              // 테스트: 성인 축일 모달 표시 버튼 (임시)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final todaySaintsAsync = ref.read(todaySaintsProvider);
                      todaySaintsAsync.whenData((saints) {
                        if (saints.isNotEmpty && mounted) {
                          final currentUser = ref.read(currentUserProvider);
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => SaintFeastDayModal(
                              saint: saints.first,
                              userBaptismalName: currentUser?.baptismalName,
                            ),
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('오늘의 성인 축일이 없습니다.')),
                          );
                        }
                      });
                    },
                    icon: const Icon(Icons.celebration),
                    label: const Text('성인 축일 모달 테스트'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // 오늘의 묵상 한마디 카드
              const SliverToBoxAdapter(child: DailyReflectionCard()),

              // 오늘의 미사 버튼
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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

              // 오늘의 성인 카드
              const SliverToBoxAdapter(child: TodaySaintsCard()),

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
                  currentUser,
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
      return _buildNoticesPlaceholder(context, theme, l10n);
    }

    // 리스트를 쉼표로 구분된 문자열로 변환 (provider 키 안정화)
    final parishIdsKey = uniqueParishIds.join(',');

    final postsAsync = ref.watch(allPostsByParishesProvider(parishIdsKey));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return _buildNoticesPlaceholder(context, theme, l10n);
        }

        // 삭제된 게시글 제외
        final filteredPosts = posts
            .where((post) => !_dismissedPostIds.contains(post.postId))
            .toList();

        if (filteredPosts.isEmpty) {
          return _buildNoticesPlaceholder(context, theme, l10n);
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
        return _buildNoticesPlaceholder(context, theme, l10n);
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 성당 이름 헤더 (아코디언 토글)
          InkWell(
            onTap: () {
              setState(() {
                _parishExpandedState[parishId] =
                    !(_parishExpandedState[parishId] ?? false);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.church, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: parishAsync != null
                        ? parishAsync.when(
                            data: (parishData) => Text(
                              parishData?['name'] as String? ?? '알 수 없는 성당',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            loading: () => Text(
                              '알 수 없는 성당',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            error: (error, stack) => Text(
                              '알 수 없는 성당',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          )
                        : Text(
                            '알 수 없는 성당',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                  ),
                  Icon(
                    (_parishExpandedState[parishId] ?? false)
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: primaryColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          // 알림 목록 (아코디언)
          if (_parishExpandedState[parishId] ?? false)
            ...posts.map((post) {
              // 게시글을 알림 형태로 변환
              final isMyPost =
                  currentUserId != null && post.authorId == currentUserId;
              final hasComments = post.commentCount > 0;

              // 표시 형식 결정
              String notificationBody;
              String notificationType;

              if (post.isNotice) {
                // 공지글 등록
                notificationBody = l10n.community.home.noticeAdded;
                notificationType = 'notice';
              } else if (isMyPost && hasComments) {
                // 내 글에 댓글이 달린 경우
                notificationBody = l10n.community.home.commentOnMyPost;
                notificationType = 'comment';
              } else {
                // 새글 등록
                notificationBody = l10n.community.home.newPostAdded;
                notificationType = 'post';
              }

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
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                            notificationBody,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
            }),
        ],
      ),
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
