import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../domain/entities/friend_entity.dart';
import '../providers/friend_providers.dart';
import '../providers/chat_providers.dart';

/// 유저 프로필 화면
class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);
    final userAsync = ref.watch(userByIdProvider(widget.userId));
    final friendRelationAsync =
        ref.watch(friendRelationProvider(widget.userId));

    final isMyProfile = currentUser?.userId == widget.userId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          if (!isMyProfile)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'report',
                  child: const Row(
                    children: [
                      Icon(Icons.report_outlined, color: Colors.red),
                      SizedBox(width: 8),
                      Text('신고하기', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'report') {
                  _showReportDialog();
                }
              },
            ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('사용자를 찾을 수 없습니다'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),

                // 프로필 이미지
                CircleAvatar(
                  key: ValueKey(user.profileImageUrl ?? 'no-image'),
                  radius: 60,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: user.profileImageUrl == null
                      ? Text(
                          user.nickname[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 48,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                // 닉네임
                Text(
                  user.nickname,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // 사용자 ID
                Text(
                  'ID: ${user.userId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // 액션 버튼들 (자신이 아닌 경우에만)
                if (!isMyProfile)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: friendRelationAsync.when(
                      data: (relation) => _buildActionButtons(
                        context,
                        theme,
                        primaryColor,
                        relation,
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => _buildActionButtons(
                        context,
                        theme,
                        primaryColor,
                        null,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    FriendEntity? relation,
  ) {
    final isFriend = relation?.status == FriendStatus.accepted;
    final isBlocked = relation?.status == FriendStatus.blocked;

    return Column(
      children: [
        // 친구 추가/삭제 버튼
        if (isBlocked)
          // 차단된 상태
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () => _handleUnblock(relation!),
              icon: const Icon(Icons.block, color: Colors.red),
              label: const Text(
                '차단 해제',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        else if (isFriend)
          // 친구인 상태
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _handleSendMessage,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('메시지 보내기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed:
                    _isLoading ? null : () => _showRemoveFriendDialog(relation!),
                icon: Icon(Icons.person_remove, color: Colors.grey[600]),
                tooltip: '친구 삭제',
              ),
            ],
          )
        else
          // 친구가 아닌 상태
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _handleAddFriend(sendMessageAfter: true),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('친구 추가 후 메시지 보내기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleAddFriend,
                  icon: const Icon(Icons.person_add),
                  label: const Text('친구만 추가'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 12),

        // 차단 버튼 (차단되지 않은 경우에만)
        if (!isBlocked)
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _isLoading ? null : _handleBlock,
              icon: Icon(Icons.block, color: Colors.grey[600]),
              label: Text(
                '차단하기',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),

        // 로딩 표시
        if (_isLoading) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  Future<void> _handleAddFriend({bool sendMessageAfter = false}) async {
    setState(() => _isLoading = true);
    try {
      await addFriend(ref, friendId: widget.userId);
      if (mounted) {
        if (sendMessageAfter) {
          // 친구 추가 후 바로 메시지 보내기
          await _handleSendMessage();
        } else {
          // 친구 추가 성공 - 메시지 보내기 옵션 제공
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('친구로 추가했습니다'),
              action: SnackBarAction(
                label: '메시지 보내기',
                onPressed: _handleSendMessage,
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 추가 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRemoveFriendDialog(FriendEntity relation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('친구 삭제'),
        content: const Text('이 사용자를 친구 목록에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleRemoveFriend(relation);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRemoveFriend(FriendEntity relation) async {
    setState(() => _isLoading = true);
    try {
      await removeFriend(ref, odId: relation.odId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('친구를 삭제했습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 삭제 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBlock() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 차단'),
        content: const Text(
          '이 사용자를 차단하시겠습니까?\n차단하면 서로 메시지를 주고받을 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('차단', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await blockUser(ref, targetUserId: widget.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자를 차단했습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('차단 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUnblock(FriendEntity relation) async {
    setState(() => _isLoading = true);
    try {
      await unblockUser(ref, odId: relation.odId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('차단을 해제했습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('차단 해제 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSendMessage() async {
    setState(() => _isLoading = true);
    try {
      final conversation = await startDirectChat(
        ref,
        otherUserId: widget.userId,
      );
      if (mounted) {
        context.push(AppRoutes.chatPath(conversation.conversationId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅 시작 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showReportDialog() {
    // TODO: 신고 다이얼로그 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('신고 기능은 준비 중입니다')),
    );
  }
}

