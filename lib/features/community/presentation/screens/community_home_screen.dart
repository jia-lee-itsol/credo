import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../parish/presentation/providers/parish_presentation_providers.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../chat/domain/entities/conversation_entity.dart';
import '../providers/community_presentation_providers.dart';

/// 커뮤니티 홈 화면 (교회 선택)
class CommunityHomeScreen extends ConsumerWidget {
  const CommunityHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final currentUser = ref.watch(currentUserProvider);
    final mainParishId = currentUser?.mainParishId;

    // 소속 교회 정보 가져오기
    final mainParishAsync = mainParishId != null
        ? ref.watch(parishByIdEntityProvider(mainParishId))
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.community.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.myPage);
              },
              child: CircleAvatar(
                key: ValueKey(currentUser?.profileImageUrl ?? 'no-image'),
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                backgroundImage: currentUser?.profileImageUrl != null
                    ? NetworkImage(currentUser!.profileImageUrl!)
                    : null,
                child: currentUser?.profileImageUrl == null
                    ? Icon(Icons.person, size: 20, color: primaryColor)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 소속 교회 섹션
          Text(
            l10n.community.home.parish,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (mainParishId != null && mainParishAsync != null)
            mainParishAsync.when(
              data: (parish) {
                if (parish == null) {
                  return _buildEmptyParishCard(
                    l10n.community.home.parishNotSet,
                    primaryColor,
                  );
                }
                // 게시글 수와 새 게시글 여부 가져오기
                final postCountAsync = ref.watch(
                  postCountProvider(mainParishId),
                );
                final hasNewPostsAsync = ref.watch(
                  hasNewPostsProvider(mainParishId),
                );

                return postCountAsync.when(
                  data: (postCount) {
                    return hasNewPostsAsync.when(
                      data: (hasNewPosts) => _CommunityParishCard(
                        name: parish.name,
                        postCount: postCount,
                        hasNewPosts: hasNewPosts,
                        primaryColor: primaryColor,
                        parishId: mainParishId,
                        onTap: () {
                          // 마지막 읽은 타임스탬프 업데이트
                          updateLastReadTimestamp(mainParishId);
                          context.push(
                            AppRoutes.communityParishPath(mainParishId),
                          );
                        },
                      ),
                      loading: () => _CommunityParishCard(
                        name: parish.name,
                        postCount: postCount,
                        hasNewPosts: false,
                        primaryColor: primaryColor,
                        parishId: mainParishId,
                        onTap: () {
                          updateLastReadTimestamp(mainParishId);
                          context.push(
                            AppRoutes.communityParishPath(mainParishId),
                          );
                        },
                      ),
                      error: (error, stackTrace) => _CommunityParishCard(
                        name: parish.name,
                        postCount: postCount,
                        hasNewPosts: false,
                        primaryColor: primaryColor,
                        parishId: mainParishId,
                        onTap: () {
                          updateLastReadTimestamp(mainParishId);
                          context.push(
                            AppRoutes.communityParishPath(mainParishId),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) => _CommunityParishCard(
                    name: parish.name,
                    postCount: 0,
                    hasNewPosts: false,
                    primaryColor: primaryColor,
                    parishId: mainParishId,
                    onTap: () {
                      updateLastReadTimestamp(mainParishId);
                      context.push(AppRoutes.communityParishPath(mainParishId));
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => _buildEmptyParishCard(
                l10n.community.home.parishLoadFailed,
                primaryColor,
              ),
            )
          else
            _buildEmptyParishCard(
              l10n.community.home.parishNotSet,
              primaryColor,
            ),

          const SizedBox(height: 24),

          // 다른 교회 커뮤니티 검색
          OutlinedButton.icon(
            onPressed: () {
              context.push(AppRoutes.parishList);
            },
            icon: const Icon(Icons.search),
            label: Text(l10n.community.home.searchOtherParishes),
          ),

          const SizedBox(height: 32),

          // 메시지 섹션
          _ChatSection(primaryColor: primaryColor),
        ],
      ),
    );
  }
}

/// 채팅 섹션 위젯
class _ChatSection extends ConsumerWidget {
  final Color primaryColor;

  const _ChatSection({required this.primaryColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final conversationsAsync = ref.watch(conversationsStreamProvider);
    final totalUnreadAsync = ref.watch(totalUnreadCountProvider);

    // 로그인하지 않은 경우
    if (currentUser == null) {
      return _buildLoginRequiredSection(context, theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '메시지',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                totalUnreadAsync.when(
                  data: (count) {
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.friendList),
              child: const Text('친구리스트 보기'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 채팅 목록 또는 빈 상태
        conversationsAsync.when(
          data: (conversations) {
            if (conversations.isEmpty) {
              return _buildEmptyChatCard(context, primaryColor);
            }

            // 최근 3개만 표시
            final recentChats = conversations.take(3).toList();

            return Card(
              child: Column(
                children: [
                  ...recentChats.asMap().entries.map((entry) {
                    final index = entry.key;
                    final conversation = entry.value;
                    return Column(
                      children: [
                        _ChatPreviewItem(
                          conversation: conversation,
                          primaryColor: primaryColor,
                          onTap: () {
                            context.push(
                              AppRoutes.chatPath(conversation.conversationId),
                            );
                          },
                        ),
                        if (index < recentChats.length - 1)
                          const Divider(height: 1, indent: 72),
                      ],
                    );
                  }),
                ],
              ),
            );
          },
          loading: () => Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            ),
          ),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '메시지를 불러올 수 없습니다',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 버튼들
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.newChat),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('메시지 보내기'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.friendList),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('친구 추가'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginRequiredSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '메시지',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  '로그인이 필요합니다',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '로그인하면 다른 사용자와 메시지를 주고받을 수 있습니다',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChatCard(BuildContext context, Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: primaryColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                '아직 메시지가 없습니다',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '다른 사용자와 대화를 시작해보세요',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

/// 채팅 미리보기 아이템
class _ChatPreviewItem extends ConsumerWidget {
  final ConversationEntity conversation;
  final Color primaryColor;
  final VoidCallback onTap;

  const _ChatPreviewItem({
    required this.conversation,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDirect = conversation.type == ConversationType.direct;

    // 1:1 채팅인 경우 상대방 정보 가져오기
    final partnerAsync = isDirect
        ? ref.watch(chatPartnerProvider(conversation.conversationId))
        : null;

    // 읽지 않은 메시지 수
    final unreadCountAsync = ref.watch(
      conversationUnreadCountProvider(conversation.conversationId),
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 프로필 이미지
            _buildAvatar(context, isDirect, partnerAsync),
            const SizedBox(width: 12),

            // 대화 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildName(context, isDirect, partnerAsync),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage?.content ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 읽지 않은 메시지 수
            unreadCountAsync.when(
              data: (count) {
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    bool isDirect,
    AsyncValue<dynamic>? partnerAsync,
  ) {
    if (isDirect && partnerAsync != null) {
      return partnerAsync.when(
        data: (partner) {
          if (partner?.profileImageUrl != null) {
            return CircleAvatar(
              key: ValueKey(partner!.profileImageUrl),
              radius: 22,
              backgroundImage: NetworkImage(partner.profileImageUrl!),
            );
          }
          return CircleAvatar(
            key: ValueKey('no-image-${partner?.userId ?? 'unknown'}'),
            radius: 22,
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            child: Text(
              (partner?.nickname ?? '?')[0].toUpperCase(),
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        loading: () => CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[200],
        ),
        error: (_, __) => CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, size: 20),
        ),
      );
    }

    // 그룹 채팅
    if (conversation.imageUrl != null) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(conversation.imageUrl!),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: primaryColor.withValues(alpha: 0.1),
      child: Icon(
        Icons.group,
        color: primaryColor,
        size: 20,
      ),
    );
  }

  Widget _buildName(
    BuildContext context,
    bool isDirect,
    AsyncValue<dynamic>? partnerAsync,
  ) {
    final theme = Theme.of(context);

    if (isDirect && partnerAsync != null) {
      return partnerAsync.when(
        data: (partner) => Text(
          partner?.nickname ?? '알 수 없음',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        loading: () => Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        error: (_, __) => Text(
          '알 수 없음',
          style: theme.textTheme.titleSmall,
        ),
      );
    }

    return Text(
      conversation.name ?? '그룹 채팅',
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// 소속 교회가 없을 때 표시할 카드
Widget _buildEmptyParishCard(String message, Color primaryColor) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    ),
  );
}

class _CommunityParishCard extends ConsumerWidget {
  final String name;
  final int postCount;
  final bool hasNewPosts;
  final Color primaryColor;
  final String parishId;
  final VoidCallback onTap;

  const _CommunityParishCard({
    required this.name,
    required this.postCount,
    required this.hasNewPosts,
    required this.primaryColor,
    required this.parishId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.forum, color: primaryColor),
                  ),
                  if (hasNewPosts)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.community.postsCount(postCount),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
