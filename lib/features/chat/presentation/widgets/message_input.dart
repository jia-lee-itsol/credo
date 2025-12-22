import 'dart:async';

import 'package:flutter/material.dart';

/// 메시지 입력 필드 위젯
class MessageInput extends StatefulWidget {
  final Function(String content) onSend;
  final VoidCallback? onImagePick;
  final Function(bool isTyping)? onTypingChanged;
  final bool isLoading;

  const MessageInput({
    super.key,
    required this.onSend,
    this.onImagePick,
    this.onTypingChanged,
    this.isLoading = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _setTyping(false);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }

    // 타이핑 상태 업데이트
    if (hasText && !_isTyping) {
      _setTyping(true);
    }

    // 타이핑 타이머 리셋 (3초 후 타이핑 종료)
    _typingTimer?.cancel();
    if (hasText) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _setTyping(false);
      });
    } else {
      _setTyping(false);
    }
  }

  void _setTyping(bool isTyping) {
    if (_isTyping != isTyping) {
      _isTyping = isTyping;
      widget.onTypingChanged?.call(isTyping);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    _typingTimer?.cancel();
    _setTyping(false);
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 이미지 첨부 버튼
            if (widget.onImagePick != null)
              IconButton(
                onPressed: widget.isLoading ? null : widget.onImagePick,
                icon: const Icon(Icons.image_outlined),
                color: theme.colorScheme.primary,
              ),

            // 텍스트 입력 필드
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: '메시지를 입력하세요',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  enabled: !widget.isLoading,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 전송 버튼
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: _hasText && !widget.isLoading ? _handleSend : null,
                style: IconButton.styleFrom(
                  backgroundColor: _hasText
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: const CircleBorder(),
                ),
                icon: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: _hasText
                            ? theme.colorScheme.onPrimary
                            : Colors.grey,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

