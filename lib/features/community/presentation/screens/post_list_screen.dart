import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/data/services/parish_service.dart' as core;
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/login_required_dialog.dart';
import '../../data/providers/community_repository_providers.dart';
import '../../data/models/post.dart';

/// 게시글 목록 화면
class PostListScreen extends ConsumerStatefulWidget {
  final String parishId;

  const PostListScreen({super.key, required this.parishId});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _sortByLatest = true;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Mock 데이터를 Post 형태로 변환
  List<_PostItem> _convertMockPostsToItems() {
    return _samplePosts.map((post) {
      return _PostItem(
        title: post['title']!,
        content: post['content']!,
        author: post['author']!,
        createdAt: DateTime.now().subtract(
          Duration(hours: _samplePosts.indexOf(post) * 3),
        ),
        likeCount: int.parse(post['likes']!),
        commentCount: int.parse(post['comments']!),
        isOfficial: post['isOfficial'] == 'true',
        isPinned: post['isPinned'] == 'true',
        isMock: true,
      );
    }).toList();
  }

  /// Firebase Post를 _PostItem으로 변환
  _PostItem _convertFirebasePostToItem(Post post) {
    return _PostItem(
      title: post.title,
      content: post.body,
      author: post.authorName,
      createdAt: post.createdAt,
      likeCount: 0, // Firebase Post 모델에는 아직 likeCount가 없음
      commentCount: 0, // Firebase Post 모델에는 아직 commentCount가 없음
      isOfficial: post.isOfficial,
      isPinned: false, // Firebase Post 모델에는 아직 isPinned가 없음
      isMock: false,
      postId: post.postId,
    );
  }

  List<_PostItem> _getAllPosts(List<Post> firebasePosts) {
    final mockItems = _convertMockPostsToItems();
    final firebaseItems = firebasePosts
        .map(_convertFirebasePostToItem)
        .toList();
    // Mock 데이터를 먼저, 그 다음 Firebase 데이터
    return [...mockItems, ...firebaseItems];
  }

  List<_PostItem> _getFilteredPosts(List<_PostItem> allPosts) {
    if (_searchQuery.isEmpty) return allPosts;

    final query = _searchQuery.toLowerCase();
    return allPosts.where((post) {
      final title = post.title.toLowerCase();
      final content = post.content.toLowerCase();
      final author = post.author.toLowerCase();

      return title.contains(query) ||
          content.contains(query) ||
          author.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final parishAsync = ref.watch(core.parishByIdProvider(widget.parishId));
    final firebasePostsAsync = ref.watch(
      communityPostsProvider(widget.parishId),
    );

    return Scaffold(
      appBar: AppBar(
        title: parishAsync.when(
          data: (parish) => Text(parish?['name'] as String? ?? 'コミュニティ'),
          loading: () => const Text('コミュニティ'),
          error: (_, _) => const Text('コミュニティ'),
        ),
      ),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '投稿を検索',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

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
            child: firebasePostsAsync.when(
              data: (firebasePosts) {
                final allPosts = _getAllPosts(firebasePosts);
                final posts = _getFilteredPosts(allPosts);

                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '検索結果がありません',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _PostCard(
                      title: post.title,
                      content: post.content,
                      author: post.author,
                      createdAt: post.createdAt,
                      likeCount: post.likeCount,
                      commentCount: post.commentCount,
                      isOfficial: post.isOfficial,
                      isPinned: post.isPinned,
                      primaryColor: primaryColor,
                      isMock: post.isMock,
                      onTap: () {
                        if (post.postId != null) {
                          // Firebase 게시글인 경우
                          context.push(
                            AppRoutes.postDetailPath(
                              widget.parishId,
                              post.postId!,
                            ),
                          );
                        } else {
                          // Mock 게시글인 경우
                          context.push(
                            AppRoutes.postDetailPath(
                              widget.parishId,
                              'mock-post-$index',
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
              loading: () {
                // 로딩 중일 때는 Mock 데이터만 표시
                final mockPosts = _convertMockPostsToItems();
                final posts = _getFilteredPosts(mockPosts);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _PostCard(
                      title: post.title,
                      content: post.content,
                      author: post.author,
                      createdAt: post.createdAt,
                      likeCount: post.likeCount,
                      commentCount: post.commentCount,
                      isOfficial: post.isOfficial,
                      isPinned: post.isPinned,
                      primaryColor: primaryColor,
                      isMock: post.isMock,
                      onTap: () {
                        context.push(
                          AppRoutes.postDetailPath(
                            widget.parishId,
                            'mock-post-$index',
                          ),
                        );
                      },
                    );
                  },
                );
              },
              error: (error, stack) {
                // 에러 발생 시 Mock 데이터만 표시
                final mockPosts = _convertMockPostsToItems();
                final posts = _getFilteredPosts(mockPosts);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _PostCard(
                      title: post.title,
                      content: post.content,
                      author: post.author,
                      createdAt: post.createdAt,
                      likeCount: post.likeCount,
                      commentCount: post.commentCount,
                      isOfficial: post.isOfficial,
                      isPinned: post.isPinned,
                      primaryColor: primaryColor,
                      isMock: post.isMock,
                      onTap: () {
                        context.push(
                          AppRoutes.postDetailPath(
                            widget.parishId,
                            'mock-post-$index',
                          ),
                        );
                      },
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
            LoginRequiredDialog.show(
              context,
              message: '投稿するにはログインが必要です。ログインしますか？',
              primaryColor: primaryColor,
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

/// 게시글 아이템 (Mock + Firebase 통합)
class _PostItem {
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isOfficial;
  final bool isPinned;
  final bool isMock;
  final String? postId; // Firebase 게시글인 경우 postId

  _PostItem({
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isOfficial,
    required this.isPinned,
    required this.isMock,
    this.postId,
  });
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
  final bool isMock;
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
    this.isMock = false,
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
              if (isPinned || isOfficial || isMock)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      if (isPinned) ...[
                        const BadgeChip.pinned(),
                        const SizedBox(width: 8),
                      ],
                      if (isOfficial) const BadgeChip.official(),
                      if (isMock) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: const Text(
                            'サンプル',
                            style: TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                        ),
                      ],
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
