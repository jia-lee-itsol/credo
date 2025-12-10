import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/login_required_dialog.dart';
import '../widgets/comment_item.dart';

/// 게시글 상세 화면
class PostDetailScreen extends ConsumerStatefulWidget {
  final String parishId;
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.parishId,
    required this.postId,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                _showReportDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('通報する'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 게시글 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 공식 배지
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: BadgeChip.official(),
                  ),

                  // 제목
                  Text(
                    '【お知らせ】年末年始のミサ時間について',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 작성자 & 시간
                  _buildAuthorInfo(theme, primaryColor),
                  const SizedBox(height: 24),

                  // 본문
                  _buildContent(theme),
                  const SizedBox(height: 24),

                  // 좋아요 버튼
                  _buildLikeButton(isAuthenticated, primaryColor),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 댓글 섹션
                  _buildCommentsSection(theme, primaryColor),
                ],
              ),
            ),
          ),

          // 댓글 입력
          _buildCommentInput(theme, isAuthenticated, primaryColor),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo(ThemeData theme, Color primaryColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: primaryColor.withValues(alpha: 0.2),
          child: Icon(
            Icons.church,
            size: 16,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '東京カテドラル',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '2時間前',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Text(
      '''年末年始のミサ時間をお知らせいたします。

■ 12月31日（大晦日）
・18:00 感謝のミサ

■ 1月1日（神の母聖マリア）
・10:00 新年ミサ

■ 1月2日以降
・通常通りのスケジュールとなります

皆様のご参列をお待ちしております。
新しい年も皆様に神様の祝福がありますように。''',
      style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
    );
  }

  Widget _buildLikeButton(bool isAuthenticated, Color primaryColor) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            if (isAuthenticated) {
              setState(() {
                _isLiked = !_isLiked;
              });
            } else {
              LoginRequiredDialog.show(context, primaryColor: primaryColor);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _isLiked
                  ? primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: _isLiked ? primaryColor : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _isLiked ? '25' : '24',
                  style: TextStyle(
                    color: _isLiked ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(ThemeData theme, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'コメント (5)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // 댓글 목록
        ..._sampleComments.map(
          (comment) => CommentItem(
            author: comment['author']!,
            content: comment['content']!,
            createdAt: DateTime.now().subtract(
              Duration(hours: int.parse(comment['hoursAgo']!)),
            ),
            primaryColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput(
    ThemeData theme,
    bool isAuthenticated,
    Color primaryColor,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'コメントを入力...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            onPressed: () {
              if (!isAuthenticated) {
                LoginRequiredDialog.show(context, primaryColor: primaryColor);
                return;
              }
              if (_commentController.text.trim().isNotEmpty) {
                // TODO: 댓글 작성 처리
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('コメントを投稿しました')),
                );
                _commentController.clear();
              }
            },
            icon: Icon(Icons.send, color: primaryColor),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通報する'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('スパム'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('通報しました')));
              },
            ),
            ListTile(
              title: const Text('不適切なコンテンツ'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('通報しました')));
              },
            ),
            ListTile(
              title: const Text('誹謗中傷'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('通報しました')));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

// 샘플 댓글 데이터
final _sampleComments = [
  {'author': 'パウロ', 'content': 'ありがとうございます！年末のミサに参加します。', 'hoursAgo': '1'},
  {'author': 'マリア', 'content': '新年のミサも楽しみにしています。', 'hoursAgo': '2'},
  {'author': 'ヨハネ', 'content': '駐車場は使えますか？', 'hoursAgo': '3'},
  {'author': '東京カテドラル', 'content': '@ヨハネ はい、駐車場はご利用いただけます。', 'hoursAgo': '3'},
  {
    'author': 'ペトロ',
    'content': '今年もありがとうございました。来年もよろしくお願いします。',
    'hoursAgo': '5',
  },
];
