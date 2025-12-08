import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';

/// 게시글 목록 화면
class PostListScreen extends ConsumerStatefulWidget {
  final String parishId;

  const PostListScreen({super.key, required this.parishId});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  bool _sortByLatest = true;

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('東京カテドラル聖マリア大聖堂')),
      body: Column(
        children: [
          // 정렬 탭
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _SortChip(
                  label: '最新',
                  isSelected: _sortByLatest,
                  onTap: () => setState(() => _sortByLatest = true),
                  primaryColor: primaryColor,
                ),
                const SizedBox(width: 8),
                _SortChip(
                  label: '人気',
                  isSelected: !_sortByLatest,
                  onTap: () => setState(() => _sortByLatest = false),
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),

          // 게시글 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _samplePosts.length,
              itemBuilder: (context, index) {
                final post = _samplePosts[index];
                return _PostCard(
                  title: post['title']!,
                  content: post['content']!,
                  author: post['author']!,
                  createdAt: DateTime.now().subtract(
                    Duration(hours: index * 3),
                  ),
                  likeCount: int.parse(post['likes']!),
                  commentCount: int.parse(post['comments']!),
                  isOfficial: post['isOfficial'] == 'true',
                  isPinned: post['isPinned'] == 'true',
                  primaryColor: primaryColor,
                  onTap: () {
                    context.push(
                      AppRoutes.postDetailPath(widget.parishId, 'post-$index'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final isAuthenticated = ref.read(isAuthenticatedProvider);
          if (isAuthenticated) {
            context.push(AppRoutes.postCreatePath(widget.parishId));
          } else {
            // 로그인하지 않은 경우 로그인 화면으로 이동
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('ログインが必要です'),
                content: const Text('投稿するにはログインが必要です。ログインしますか？'),
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
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isOfficial;
  final bool isPinned;
  final Color primaryColor;
  final VoidCallback onTap;

  const _PostCard({
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isOfficial,
    required this.isPinned,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 배지들
              if (isPinned || isOfficial)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      if (isPinned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.push_pin,
                                size: 12,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '固定',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isOfficial)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 12,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '公式',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              // 제목
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 본문 미리보기
              Text(
                content,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 하단 정보
              Row(
                children: [
                  // 작성자
                  Text(
                    author,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '・',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  // 시간
                  Text(
                    AppDateUtils.formatRelativeTime(createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  // 좋아요
                  Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text('$likeCount', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 12),
                  // 댓글
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text('$commentCount', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 샘플 데이터
final _samplePosts = [
  {
    'title': '【お知らせ】年末年始のミサ時間について',
    'content':
        '年末年始のミサ時間をお知らせいたします。12月31日は18時から、1月1日は10時からとなります。皆様のご参列をお待ちしております。',
    'author': '東京カテドラル',
    'likes': '24',
    'comments': '5',
    'isOfficial': 'true',
    'isPinned': 'true',
  },
  {
    'title': '聖歌隊メンバー募集中です',
    'content': '聖歌隊では新しいメンバーを募集しています。経験不問、歌うことが好きな方ならどなたでも歓迎します。練習は毎週土曜日の午後です。',
    'author': '聖歌隊担当',
    'likes': '18',
    'comments': '8',
    'isOfficial': 'true',
    'isPinned': 'false',
  },
  {
    'title': '先週のミサで感動しました',
    'content': '先週日曜日のミサに初めて参加しました。神父様のお話がとても心に響きました。これからも通い続けたいと思います。',
    'author': 'マリア',
    'likes': '12',
    'comments': '3',
    'isOfficial': 'false',
    'isPinned': 'false',
  },
  {
    'title': '駐車場についての質問',
    'content': '来週の日曜日に家族で伺いたいのですが、教会の駐車場は何台くらい停められますか？また、近くにコインパーキングはありますか？',
    'author': 'ヨハネ',
    'likes': '3',
    'comments': '6',
    'isOfficial': 'false',
    'isPinned': 'false',
  },
];
