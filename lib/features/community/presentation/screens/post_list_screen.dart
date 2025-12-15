import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/parish_service.dart' as core;
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/widgets/login_required_dialog.dart';
import '../providers/community_presentation_providers.dart';
import '../../data/models/post.dart';
import '../widgets/post_card.dart';
import '../widgets/post_list_filter_bar.dart';
import '../widgets/post_list_search_bar.dart';

/// 게시글 목록 화면
class PostListScreen extends ConsumerStatefulWidget {
  final String parishId;

  const PostListScreen({super.key, required this.parishId});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  final TextEditingController _searchController = TextEditingController();
  PostListFilterType _filterType = PostListFilterType.latest;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Firebase Post를 _PostItem으로 변환
  _PostItem _convertFirebasePostToItem(Post post) {
    return _PostItem(
      title: post.title,
      content: post.body,
      author: post.authorName,
      authorId: post.authorId,
      createdAt: post.createdAt,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      isOfficial: post.isOfficial,
      isPinned: post.isPinned,
      postId: post.postId,
    );
  }

  List<_PostItem> _getAllPosts(List<Post> firebasePosts) {
    return firebasePosts.map(_convertFirebasePostToItem).toList();
  }

  List<_PostItem> _getFilteredPosts(List<_PostItem> allPosts) {
    var filtered = allPosts;

    // 필터 타입에 따라 필터링
    if (_filterType == PostListFilterType.myPosts) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        // 현재 사용자가 작성한 게시글만 필터링
        filtered = filtered.where((post) {
          return post.authorId == currentUser.userId;
        }).toList();
      } else {
        // 로그인하지 않은 경우 빈 리스트
        filtered = [];
      }
    }

    // 검색 쿼리 필터링
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((post) {
        final title = post.title.toLowerCase();
        final content = post.content.toLowerCase();
        final author = post.author.toLowerCase();

        return title.contains(query) ||
            content.contains(query) ||
            author.contains(query);
      }).toList();
    }

    // 정렬 (isPinned 우선, 그 다음 Latest 또는 Popular)
    if (_filterType == PostListFilterType.latest) {
      filtered = _sortPostItemsByPinnedAndDate(filtered);
    } else if (_filterType == PostListFilterType.popular) {
      // 인기순: 좋아요 + 댓글 수 합계로 정렬
      filtered = _sortPostItemsByPinnedAndPopularity(filtered);
    } else if (_filterType == PostListFilterType.myPosts) {
      // 내 게시글도 핀 우선 정렬
      filtered = _sortPostItemsByPinnedAndDate(filtered);
    }

    return filtered;
  }

  /// _PostItem 리스트를 핀 고정 우선, 그 다음 생성 시간순으로 정렬
  List<_PostItem> _sortPostItemsByPinnedAndDate(List<_PostItem> items) {
    return [...items]..sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  /// _PostItem 리스트를 핀 고정 우선, 그 다음 인기순으로 정렬
  List<_PostItem> _sortPostItemsByPinnedAndPopularity(List<_PostItem> items) {
    return [...items]..sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      // 인기 점수 = likeCount + commentCount
      final aScore = a.likeCount + a.commentCount;
      final bScore = b.likeCount + b.commentCount;
      if (bScore != aScore) {
        return bScore.compareTo(aScore);
      }
      // 점수가 같으면 최신순
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final parishAsync = ref.watch(core.parishByIdProvider(widget.parishId));
    final firebasePostsAsync = ref.watch(allPostsProvider(widget.parishId));

    return Scaffold(
      appBar: AppBar(
        title: parishAsync.when(
          data: (parish) {
            final l10n = ref.read(appLocalizationsSyncProvider);
            return Text(parish?['name'] as String? ?? l10n.community.title);
          },
          loading: () {
            final l10n = ref.read(appLocalizationsSyncProvider);
            return Text(l10n.community.title);
          },
          error: (_, _) {
            final l10n = ref.read(appLocalizationsSyncProvider);
            return Text(l10n.community.title);
          },
        ),
      ),
      body: Column(
        children: [
          // 검색바
          PostListSearchBar(
            controller: _searchController,
            searchQuery: _searchQuery,
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),

          // 정렬 탭
          PostListFilterBar(
            filterType: _filterType,
            onFilterChanged: (type) => setState(() => _filterType = type),
            primaryColor: primaryColor,
          ),

          // 게시글 목록
          Expanded(
            child: firebasePostsAsync.when(
              data: (firebasePosts) {
                final allPosts = _getAllPosts(firebasePosts);
                final posts = _getFilteredPosts(allPosts);

                if (posts.isEmpty) {
                  return RefreshIndicator(
                    color: primaryColor,
                    onRefresh: () async {
                      ref.invalidate(allPostsProvider(widget.parishId));
                    },
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
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
                                  l10n.community.noSearchResults,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () async {
                    ref.invalidate(allPostsProvider(widget.parishId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCard(
                        title: post.title,
                        content: post.content,
                        author: post.author,
                        createdAt: post.createdAt,
                        likeCount: post.likeCount,
                        commentCount: post.commentCount,
                        isOfficial: post.isOfficial,
                        isPinned: post.isPinned,
                        primaryColor: primaryColor,
                        onTap: () {
                          if (post.postId != null) {
                            context.push(
                              AppRoutes.postDetailPath(
                                widget.parishId,
                                post.postId!,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
              error: (error, stack) {
                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () async {
                    ref.invalidate(allPostsProvider(widget.parishId));
                  },
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.community.errorOccurred,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.community.swipeToRefresh,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
              message: l10n.auth.loginRequiredQuestion,
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

/// 게시글 아이템
class _PostItem {
  final String title;
  final String content;
  final String author;
  final String? authorId;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isOfficial;
  final bool isPinned;
  final String? postId;

  _PostItem({
    required this.title,
    required this.content,
    required this.author,
    this.authorId,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isOfficial,
    required this.isPinned,
    this.postId,
  });
}
