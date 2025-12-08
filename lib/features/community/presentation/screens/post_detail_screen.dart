import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';

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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '公式',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                  Row(
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
                            AppDateUtils.formatRelativeTime(
                              DateTime.now().subtract(const Duration(hours: 2)),
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 본문
                  Text(
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
                  ),
                  const SizedBox(height: 24),

                  // 좋아요 버튼
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (isAuthenticated) {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          } else {
                            _showLoginRequiredDialog(context, primaryColor);
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
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
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
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 댓글 섹션
                  Text(
                    'コメント (5)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 댓글 목록
                  ..._sampleComments.map(
                    (comment) => _CommentItem(
                      author: comment['author']!,
                      content: comment['content']!,
                      createdAt: DateTime.now().subtract(
                        Duration(hours: int.parse(comment['hoursAgo']!)),
                      ),
                      primaryColor: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 댓글 입력
          Container(
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
                      _showLoginRequiredDialog(context, primaryColor);
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
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context, Color primaryColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログインが必要です'),
        content: const Text('この機能を使用するにはログインが必要です。ログインしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.signIn);
            },
            child: Text('ログイン', style: TextStyle(color: primaryColor)),
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

class _CommentItem extends StatelessWidget {
  final String author;
  final String content;
  final DateTime createdAt;
  final Color primaryColor;

  const _CommentItem({
    required this.author,
    required this.content,
    required this.createdAt,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              author[0],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppDateUtils.formatRelativeTime(createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content, style: theme.textTheme.bodyMedium),
              ],
            ),
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
