import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/message_entity.dart';

/// 메시지 버블 위젯
class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final bool showTime;
  final bool isRead;
  final String? senderName;
  final String? senderProfileUrl;
  final bool showSenderInfo;
  final VoidCallback? onTapSender;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showTime = true,
    this.isRead = false,
    this.senderName,
    this.senderProfileUrl,
    this.showSenderInfo = false,
    this.onTapSender,
  });

  void _showMessageOptions(BuildContext context) {
    if (isMe) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('프로필 보기'),
              onTap: () {
                Navigator.pop(context);
                onTapSender?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenImageView(imageUrl: imageUrl),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 시스템 메시지
    if (message.isSystemMessage) {
      return _buildSystemMessage(context);
    }

    if (message.isDeleted) {
      return _buildDeletedMessage(context);
    }

    return GestureDetector(
      onLongPress: !isMe && onTapSender != null
          ? () => _showMessageOptions(context)
          : null,
      child: Padding(
      padding: EdgeInsets.only(
        left: isMe ? 48 : 8,
        right: isMe ? 8 : 48,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 발신자 정보 (그룹 채팅에서 다른 사람 메시지)
          if (!isMe && showSenderInfo && senderName != null)
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 4),
              child: Text(
                senderName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 상대방 프로필 이미지
              if (!isMe && showSenderInfo) ...[
                GestureDetector(
                  onTap: onTapSender,
                  child: CircleAvatar(
                    key: ValueKey(senderProfileUrl ?? 'no-image'),
                    radius: 16,
                    backgroundImage: senderProfileUrl != null
                        ? NetworkImage(senderProfileUrl!)
                        : null,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: senderProfileUrl == null
                        ? Text(
                            (senderName ?? '?')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // 시간 (왼쪽 - 내 메시지)
              if (isMe && showTime) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isRead)
                      Text(
                        '읽음',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    Text(
                      DateFormat('HH:mm').format(message.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
              ],

              // 메시지 내용
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지
                      if (message.hasImages)
                        ...message.imageUrls.map((url) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () => _showFullScreenImage(context, url),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 200),
                                    child: CachedNetworkImage(
                                      imageUrl: url,
                                      placeholder: (context, url) => Container(
                                        width: 200,
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 200,
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )),

                      // 텍스트
                      if (message.content.isNotEmpty)
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 시간 (오른쪽 - 상대방 메시지)
              if (!isMe && showTime) ...[
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(message.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDeletedMessage(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 48 : 8,
        right: isMe ? 8 : 48,
        top: 4,
        bottom: 4,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '삭제된 메시지입니다',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  /// 시스템 메시지 빌드 (입장, 퇴장 등)
  Widget _buildSystemMessage(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message.content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 전체 화면 이미지 뷰
class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            // 이미지
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),

            // 닫기 버튼
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

