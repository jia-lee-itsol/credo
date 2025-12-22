import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../data/providers/chat_repository_providers.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/entities/friend_entity.dart';
import '../providers/chat_providers.dart';
import '../providers/friend_providers.dart';

/// 채팅방 정보 화면
class ChatInfoScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatInfoScreen({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatInfoScreen> createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends ConsumerState<ChatInfoScreen> {
  List<ChatUserEntity> _participants = [];
  bool _isLoading = true;
  ConversationEntity? _conversation;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final conversationAsync =
        await ref.read(conversationStreamProvider(widget.conversationId).future);

    if (conversationAsync == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final chatRepository = ref.read(chatRepositoryProvider);
    final users = await chatRepository.getUsers(conversationAsync.participants);

    if (mounted) {
      setState(() {
        _conversation = conversationAsync;
        _participants = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('채팅방 정보')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('채팅방 정보')),
        body: const Center(child: Text('채팅방을 찾을 수 없습니다')),
      );
    }

    final isGroup = _conversation!.type == ConversationType.group;
    final participantCount = _participants.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방 정보'),
        actions: [
          if (isGroup && _conversation!.createdBy == currentUser?.userId)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditGroupNameDialog,
              tooltip: '그룹 이름 변경',
            ),
        ],
      ),
      body: ListView(
        children: [
          // 채팅방 헤더
          Container(
            padding: const EdgeInsets.all(24),
            color: primaryColor.withValues(alpha: 0.1),
            child: Column(
              children: [
                // 채팅방 이미지
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                  backgroundImage: _conversation!.imageUrl != null
                      ? NetworkImage(_conversation!.imageUrl!)
                      : null,
                  child: _conversation!.imageUrl == null
                      ? Icon(
                          isGroup ? Icons.group : Icons.person,
                          size: 50,
                          color: primaryColor,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                // 채팅방 이름
                Text(
                  isGroup
                      ? (_conversation!.name ?? '그룹 채팅')
                      : _getOtherUserName(currentUser?.userId),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isGroup ? '그룹 채팅 · $participantCount명' : '1:1 채팅',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 참여자 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '참여자 ($participantCount)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 유저 추가 버튼
                TextButton.icon(
                  onPressed: _showAddMemberDialog,
                  icon: Icon(Icons.person_add, color: primaryColor),
                  label: Text(
                    '초대하기',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // 참여자 목록
          ...(_participants.map((user) => _buildParticipantTile(
                context,
                user,
                isMe: user.userId == currentUser?.userId,
                isCreator: user.userId == _conversation!.createdBy,
              ))),

          const SizedBox(height: 24),

          // 채팅방 나가기 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _showLeaveConfirmDialog,
              icon: const Icon(Icons.exit_to_app, color: Colors.red),
              label: const Text(
                '채팅방 나가기',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getOtherUserName(String? currentUserId) {
    if (currentUserId == null) return '알 수 없음';
    final otherUser = _participants.firstWhere(
      (u) => u.userId != currentUserId,
      orElse: () => _participants.first,
    );
    return otherUser.nickname;
  }

  Widget _buildParticipantTile(
    BuildContext context,
    ChatUserEntity user, {
    required bool isMe,
    required bool isCreator,
  }) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final isDirect = _conversation?.type == ConversationType.direct;

    // 1:1 채팅방인 경우 친구 관계 확인
    final friendRelationAsync = isDirect && !isMe
        ? ref.watch(friendRelationProvider(user.userId))
        : null;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: user.profileImageUrl == null
            ? Text(
                user.nickname[0].toUpperCase(),
                style: TextStyle(color: theme.colorScheme.primary),
              )
            : null,
      ),
      title: Row(
        children: [
          Text(user.nickname),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '나',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
          if (isCreator) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '방장',
                style: TextStyle(fontSize: 10, color: Colors.orange),
              ),
            ),
          ],
        ],
      ),
      trailing: isMe
          ? null
          : isDirect && friendRelationAsync != null
              ? friendRelationAsync.when(
                  data: (relation) {
                    final isFriend = relation?.status == FriendStatus.accepted;
                    final isBlocked = relation?.status == FriendStatus.blocked;

                    if (isBlocked) {
                      return TextButton.icon(
                        onPressed: () => _handleUnblock(relation!),
                        icon: const Icon(Icons.block, size: 16),
                        label: const Text('차단 해제'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      );
                    }

                    if (!isFriend) {
                      return TextButton.icon(
                        onPressed: () => _handleAddFriend(user.userId),
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('친구 추가'),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                        ),
                      );
                    }

                    return null;
                  },
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => null,
                )
              : null,
      onTap: isMe
          ? null
          : () {
              // 다른 유저 프로필 보기
              context.push(AppRoutes.userProfilePath(user.userId));
            },
    );
  }

  Future<void> _handleAddFriend(String friendId) async {
    try {
      await addFriend(ref, friendId: friendId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('친구로 추가했습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 추가 실패: $e')),
        );
      }
    }
  }

  Future<void> _handleUnblock(FriendEntity relation) async {
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
    }
  }

  void _showAddMemberDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddMemberBottomSheet(
        conversationId: widget.conversationId,
        currentParticipants: _participants.map((u) => u.userId).toList(),
        onMembersAdded: () {
          _loadParticipants(); // 참여자 목록 새로고침
        },
      ),
    );
  }

  void _showEditGroupNameDialog() {
    final controller = TextEditingController(text: _conversation?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('그룹 이름 변경'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '그룹 이름',
            hintText: '새로운 그룹 이름을 입력하세요',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              Navigator.pop(context);

              try {
                final chatRepository = ref.read(chatRepositoryProvider);
                await chatRepository.updateConversationName(
                  conversationId: widget.conversationId,
                  name: newName,
                );
                _loadParticipants(); // 새로고침
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이름 변경 실패: $e')),
                  );
                }
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmDialog() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('채팅방 나가기'),
        content: const Text('정말 이 채팅방을 나가시겠습니까?\n상대방에게 퇴장 메시지가 전송됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                final chatRepository = ref.read(chatRepositoryProvider);
                await chatRepository.leaveConversation(
                  conversationId: widget.conversationId,
                  userId: currentUser.userId,
                  userNickname: currentUser.nickname,
                );

                if (mounted) {
                  // 채팅 목록으로 돌아가기 (2번 pop - info 화면과 chat 화면)
                  context.pop();
                  context.pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('채팅방 나가기 실패: $e')),
                  );
                }
              }
            },
            child: const Text(
              '나가기',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// 멤버 추가 바텀시트
class _AddMemberBottomSheet extends ConsumerStatefulWidget {
  final String conversationId;
  final List<String> currentParticipants;
  final VoidCallback onMembersAdded;

  const _AddMemberBottomSheet({
    required this.conversationId,
    required this.currentParticipants,
    required this.onMembersAdded,
  });

  @override
  ConsumerState<_AddMemberBottomSheet> createState() =>
      _AddMemberBottomSheetState();
}

class _AddMemberBottomSheetState extends ConsumerState<_AddMemberBottomSheet> {
  final _selectedUsers = <String>{}; // 선택된 유저 ID
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    // 친구 목록 가져오기 (이미 참여 중인 유저 제외)
    final friendsAsync = ref.watch(friendsStreamProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '멤버 초대',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _selectedUsers.isEmpty || _isLoading
                      ? null
                      : _addSelectedMembers,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          '추가 (${_selectedUsers.length})',
                          style: TextStyle(
                            color: _selectedUsers.isEmpty
                                ? Colors.grey
                                : primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),

          const Divider(),

          // 친구 목록
          Expanded(
            child: friendsAsync.when(
              data: (friends) {
                // 이미 참여 중인 유저 제외
                final availableFriends = friends
                    .where((f) => !widget.currentParticipants.contains(f.friendUserId))
                    .toList();

                if (availableFriends.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          '초대할 수 있는 친구가 없습니다',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '친구를 추가한 후 초대해보세요',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: availableFriends.length,
                  itemBuilder: (context, index) {
                    final friend = availableFriends[index];
                    final isSelected = _selectedUsers.contains(friend.friendUserId);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUsers.add(friend.friendUserId);
                          } else {
                            _selectedUsers.remove(friend.friendUserId);
                          }
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundImage: friend.friendProfileImageUrl != null
                            ? NetworkImage(friend.friendProfileImageUrl!)
                            : null,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        child: friend.friendProfileImageUrl == null
                            ? Text(
                                friend.friendNickname[0].toUpperCase(),
                                style: TextStyle(color: primaryColor),
                              )
                            : null,
                      ),
                      title: Text(friend.friendNickname),
                      subtitle: friend.communityName != null
                          ? Text(
                              friend.communityName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            )
                          : null,
                      activeColor: primaryColor,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSelectedMembers() async {
    if (_selectedUsers.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final chatRepository = ref.read(chatRepositoryProvider);
      final currentUser = ref.read(currentUserProvider);

      await chatRepository.addMembersToConversation(
        conversationId: widget.conversationId,
        memberIds: _selectedUsers.toList(),
        addedByNickname: currentUser?.nickname ?? '알 수 없음',
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onMembersAdded();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedUsers.length}명이 초대되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('초대 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

