import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/image_upload_service.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../data/providers/chat_repository_providers.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../providers/chat_providers.dart';
import '../providers/friend_providers.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

/// 채팅 화면
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  final _imageUploadService = ImageUploadService();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 읽음 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markMessagesAsRead(ref, conversationId: widget.conversationId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String content) async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      await sendMessage(
        ref,
        conversationId: widget.conversationId,
        content: content,
      );

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('메시지 전송 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      // 이미지 선택 방법 선택
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1200,
      );

      if (pickedFile == null) return;

      setState(() => _isSending = true);

      // 이미지 업로드
      final imageUrl = await _imageUploadService.uploadImage(
        imageFile: File(pickedFile.path),
        userId: currentUser.userId,
      );

      // 이미지 메시지 전송
      await sendMessage(
        ref,
        conversationId: widget.conversationId,
        content: '📷 이미지',
        imageUrls: [imageUrl],
      );

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지 전송 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTypingChanged(bool isTyping) {
    updateTypingStatus(
      ref,
      conversationId: widget.conversationId,
      isTyping: isTyping,
    );
  }

  Widget _buildTypingIndicator(BuildContext context, Color primaryColor) {
    final typingUsersAsync = ref.watch(
      typingUsersProvider(widget.conversationId),
    );
    final participantsAsync = ref.watch(
      conversationParticipantsProvider(widget.conversationId),
    );

    return typingUsersAsync.when(
      data: (typingUserIds) {
        if (typingUserIds.isEmpty) {
          return const SizedBox.shrink();
        }

        return participantsAsync.when(
          data: (participants) {
            final typingNames = typingUserIds.map((userId) {
              final user = participants.firstWhere(
                (p) => p.userId == userId,
                orElse: () => participants.first,
              );
              return user.nickname;
            }).toList();

            final text = typingNames.length == 1
                ? '${typingNames[0]}님이 입력 중...'
                : '${typingNames.length}명이 입력 중...';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: primaryColor.withValues(alpha: 0.05),
              child: Row(
                children: [
                  _TypingDots(color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);
    final conversationAsync = ref.watch(
      conversationStreamProvider(widget.conversationId),
    );
    final messagesAsync = ref.watch(
      messagesStreamProvider(widget.conversationId),
    );

    // 1:1 채팅인 경우 상대방 정보
    final partnerAsync = ref.watch(chatPartnerProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: conversationAsync.when(
          data: (conversation) {
            if (conversation == null) {
              return const Text('채팅');
            }

            final isDirect = conversation.type == ConversationType.direct;

            if (isDirect) {
              return partnerAsync.when(
                data: (partner) => InkWell(
                  onTap: partner != null
                      ? () => context.push(
                          AppRoutes.userProfilePath(partner.userId),
                        )
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          key: ValueKey(partner?.profileImageUrl ?? 'no-image'),
                          radius: 18,
                          backgroundImage: partner?.profileImageUrl != null
                              ? NetworkImage(partner!.profileImageUrl!)
                              : null,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: partner?.profileImageUrl == null
                              ? Text(
                                  (partner?.nickname ?? '?')[0].toUpperCase(),
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(partner?.nickname ?? '알 수 없음'),
                            Text(
                              '프로필 보기',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Text('로딩 중...'),
                error: (_, __) => const Text('채팅'),
              );
            }

            // 그룹 채팅
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: conversation.imageUrl != null
                      ? NetworkImage(conversation.imageUrl!)
                      : null,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: conversation.imageUrl == null
                      ? Icon(Icons.group, color: primaryColor, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.name ?? '그룹 채팅',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        '${conversation.participants.length}명',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Text('로딩 중...'),
          error: (_, __) => const Text('채팅'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
            tooltip: '메시지 검색',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('채팅방 정보'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('채팅방 나가기', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'info') {
                context.push(AppRoutes.chatInfoPath(widget.conversationId));
              } else if (value == 'leave') {
                _showLeaveConfirmDialog();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 타이핑 인디케이터
          _buildTypingIndicator(context, primaryColor),

          // 메시지 목록
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '첫 메시지를 보내보세요!',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 새 메시지 수신 시 읽음 처리
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  markMessagesAsRead(
                    ref,
                    conversationId: widget.conversationId,
                  );
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser?.userId;

                    // 읽음 상태 계산 (상대방이 읽었는지)
                    final conversation = ref
                        .read(conversationStreamProvider(widget.conversationId))
                        .value;
                    final otherParticipants =
                        conversation?.participants
                            .where((id) => id != currentUser?.userId)
                            .toList() ??
                        [];
                    final isRead = otherParticipants.any(
                      (id) => message.readBy.containsKey(id),
                    );

                    // 발신자 정보 표시 여부 (그룹 채팅에서 다른 사람 메시지)
                    final showSenderInfo =
                        conversation?.type == ConversationType.group && !isMe;

                    // 이전 메시지와 발신자가 다르면 발신자 정보 표시
                    final showAvatar =
                        showSenderInfo &&
                        (index == 0 ||
                            messages[index - 1].senderId != message.senderId);

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      isRead: isRead,
                      showSenderInfo: showAvatar,
                      senderName: showAvatar ? message.senderId : null,
                      onTapSender: !isMe
                          ? () => context.push(
                              AppRoutes.userProfilePath(message.senderId),
                            )
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('메시지를 불러올 수 없습니다'),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 메시지 입력 또는 친구 추가 요청
          _buildBottomBar(
            context,
            theme,
            primaryColor,
            conversationAsync,
            currentUser?.userId,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    AsyncValue<ConversationEntity?> conversationAsync,
    String? currentUserId,
  ) {
    return conversationAsync.when(
      data: (conversation) {
        if (conversation == null || currentUserId == null) {
          return const SizedBox.shrink();
        }

        // 1:1 채팅인 경우에만 친구 여부 확인
        if (conversation.type == ConversationType.direct) {
          final otherUserId = conversation.participants.firstWhere(
            (id) => id != currentUserId,
            orElse: () => '',
          );

          if (otherUserId.isEmpty) {
            return MessageInput(onSend: _sendMessage, isLoading: _isSending);
          }

          final friendRelationAsync = ref.watch(
            friendRelationProvider(otherUserId),
          );

          return friendRelationAsync.when(
            data: (relation) {
              final isFriend = relation?.status == FriendStatus.accepted;
              final isBlocked = relation?.status == FriendStatus.blocked;

              // 차단된 경우
              if (isBlocked) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.block, color: Colors.grey),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '차단한 사용자입니다',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _handleUnblock(relation!),
                        child: const Text('차단 해제'),
                      ),
                    ],
                  ),
                );
              }

              // 친구인 경우 - 메시지 입력 가능
              if (isFriend) {
                return MessageInput(
                  onSend: _sendMessage,
                  onImagePick: _pickAndSendImage,
                  onTypingChanged: _onTypingChanged,
                  isLoading: _isSending,
                );
              }

              // 친구가 아닌 경우 - 친구 추가/차단 옵션 표시
              return _buildFriendRequestBar(
                context,
                theme,
                primaryColor,
                otherUserId,
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => MessageInput(
              onSend: _sendMessage,
              onImagePick: _pickAndSendImage,
              onTypingChanged: _onTypingChanged,
              isLoading: _isSending,
            ),
          );
        }

        // 그룹 채팅인 경우 - 항상 메시지 입력 가능
        return MessageInput(
          onSend: _sendMessage,
          onImagePick: _pickAndSendImage,
          onTypingChanged: _onTypingChanged,
          isLoading: _isSending,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildFriendRequestBar(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    String otherUserId,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(color: primaryColor.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.person_add_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '메시지를 보내려면 친구로 추가해주세요',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isSending
                      ? null
                      : () => _handleAddFriendAndReply(otherUserId),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('친구 추가'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _isSending ? null : () => _handleBlock(otherUserId),
                icon: Icon(Icons.block, size: 18, color: Colors.grey[600]),
                label: Text('차단', style: TextStyle(color: Colors.grey[600])),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddFriendAndReply(String friendId) async {
    setState(() => _isSending = true);
    try {
      await addFriend(ref, friendId: friendId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('친구로 추가했습니다. 이제 메시지를 보낼 수 있습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('친구 추가 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _handleBlock(String targetUserId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 차단'),
        content: const Text('이 사용자를 차단하시겠습니까?\n차단하면 서로 메시지를 주고받을 수 없습니다.'),
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

    setState(() => _isSending = true);
    try {
      await blockUser(ref, targetUserId: targetUserId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('사용자를 차단했습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('차단 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _handleUnblock(FriendEntity relation) async {
    setState(() => _isSending = true);
    try {
      await unblockUser(ref, odId: relation.odId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('차단을 해제했습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('차단 해제 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _MessageSearchDialog(
        conversationId: widget.conversationId,
        onMessageSelected: (message) {
          Navigator.pop(dialogContext);
          // 검색된 메시지로 스크롤 (간단한 구현)
          _scrollToMessage(message);
        },
      ),
    );
  }

  void _scrollToMessage(MessageEntity message) {
    // 메시지로 스크롤하는 로직은 나중에 구현 가능
    // 현재는 스크롤 컨트롤러를 사용하여 구현할 수 있음
    _scrollToBottom();
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
                // 채팅방 나가기 처리
                final chatRepository = ref.read(chatRepositoryProvider);
                await chatRepository.leaveConversation(
                  conversationId: widget.conversationId,
                  userId: currentUser.userId,
                  userNickname: currentUser.nickname,
                );

                // 채팅 화면 닫기
                if (mounted) {
                  context.pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('채팅방 나가기 실패: $e')));
                }
              }
            },
            child: const Text('나가기', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 타이핑 애니메이션 (점 3개)
class _TypingDots extends StatefulWidget {
  final Color color;

  const _TypingDots({required this.color});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animation = (_controller.value + delay) % 1.0;
            final scale = animation < 0.5 ? 0.5 + animation : 1.5 - animation;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// 메시지 검색 다이얼로그
class _MessageSearchDialog extends ConsumerStatefulWidget {
  final String conversationId;
  final Function(MessageEntity) onMessageSelected;

  const _MessageSearchDialog({
    required this.conversationId,
    required this.onMessageSelected,
  });

  @override
  ConsumerState<_MessageSearchDialog> createState() =>
      _MessageSearchDialogState();
}

class _MessageSearchDialogState extends ConsumerState<_MessageSearchDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    final searchResultsAsync = ref.watch(
      messageSearchProvider(
        MessageSearchParams(
          conversationId: widget.conversationId,
          query: _searchQuery,
        ),
      ),
    );

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 검색 입력
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '메시지 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 검색 결과
            Expanded(
              child: _searchQuery.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            '검색어를 입력하세요',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : searchResultsAsync.when(
                      data: (messages) {
                        if (messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '검색 결과가 없습니다',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe =
                                message.senderId == currentUser?.userId;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                child: Icon(
                                  Icons.message,
                                  color: primaryColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                message.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isMe
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                _formatDate(message.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              onTap: () => widget.onMessageSelected(message),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '검색 중 오류가 발생했습니다',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            // 닫기 버튼
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '어제 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
