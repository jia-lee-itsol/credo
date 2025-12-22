import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../data/providers/community_repository_providers.dart';
import '../../data/models/app_user.dart';
import '../../data/models/comment.dart';
import '../../data/models/notification.dart' as models;
import '../../data/models/post.dart';
import '../notifiers/post_form_notifier.dart';

// Repository Providers 재내보내기 (하위 호환성을 위해)
export '../../data/providers/community_repository_providers.dart';

/// 공식 공지사항 스트림 Provider (parishId 파라미터 지원)
final officialNoticesProvider = StreamProvider.autoDispose
    .family<List<Post>, String?>((ref, String? parishId) {
      final repo = ref.watch(postRepositoryProvider);
      return repo.watchOfficialNotices(parishId: parishId);
    });

/// 여러 교회의 공식 공지사항 스트림 Provider (parishIds 파라미터 지원)
///
/// 주의: 리스트를 쉼표로 구분된 문자열로 전달해야 합니다.
/// 예: "parish1,parish2,parish3"
/// 리스트를 직접 전달하면 매번 새 인스턴스로 인식되어 provider가 재생성됩니다.
final officialNoticesByParishesProvider = StreamProvider.autoDispose
    .family<List<Post>, String>((ref, String parishIdsKey) {
      final parishIds = parishIdsKey.isEmpty
          ? <String>[]
          : parishIdsKey.split(',');
      final repo = ref.watch(postRepositoryProvider);
      return repo.watchOfficialNoticesByParishes(parishIds: parishIds);
    });

/// 커뮤니티 게시글 스트림 Provider (parishId 파라미터 지원)
final communityPostsProvider = StreamProvider.autoDispose
    .family<List<Post>, String?>((ref, String? parishId) {
      final repo = ref.watch(postRepositoryProvider);
      return repo.watchCommunityPosts(parishId: parishId);
    });

/// 모든 게시글 스트림 Provider (공지 + 커뮤니티, parishId 파라미터 지원)
final allPostsProvider = StreamProvider.autoDispose.family<List<Post>, String?>(
  (ref, String? parishId) {
    final repo = ref.watch(postRepositoryProvider);
    return repo.watchAllPosts(parishId: parishId);
  },
);

/// 여러 교회의 모든 게시글 스트림 Provider (공지 + 커뮤니티, parishIds 파라미터 지원)
///
/// 주의: 리스트를 쉼표로 구분된 문자열로 전달해야 합니다.
/// 예: "parish1,parish2,parish3"
/// 리스트를 직접 전달하면 매번 새 인스턴스로 인식되어 provider가 재생성됩니다.
final allPostsByParishesProvider = StreamProvider.autoDispose
    .family<List<Post>, String>((ref, String parishIdsKey) {
      final parishIds = parishIdsKey.isEmpty
          ? <String>[]
          : parishIdsKey.split(',');
      final repo = ref.watch(postRepositoryProvider);
      return repo.watchAllPostsByParishes(parishIds: parishIds);
    });

/// 사용자 스트림 Provider (uid 파라미터)
final userStreamProvider = StreamProvider.autoDispose.family<AppUser?, String>((
  ref,
  String uid,
) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.watchUser(uid);
});

/// 사용자 조회 Provider (uid 파라미터, Future)
final userProvider = FutureProvider.autoDispose.family<AppUser?, String>((
  ref,
  String uid,
) async {
  final repo = ref.watch(userRepositoryProvider);
  final result = await repo.getUserById(uid);
  return result.fold((failure) => null, (user) => user);
});

/// displayName으로 사용자 검색 Provider (displayName 파라미터, Future)
final userByDisplayNameProvider = FutureProvider.autoDispose
    .family<AppUser?, String>((ref, String displayName) async {
      final repo = ref.watch(userRepositoryProvider);
      final result = await repo.searchUsersByDisplayName(displayName);
      return result.fold((failure) => null, (users) {
        if (users.isEmpty) {
          return null;
        }
        // 정확히 일치하는 사용자 찾기 (대소문자 구분 없음)
        try {
          return users.firstWhere(
            (user) =>
                user.displayName.toLowerCase() == displayName.toLowerCase(),
          );
        } catch (e) {
          // 정확히 일치하는 사용자가 없으면 첫 번째 사용자 반환
          return users.first;
        }
      });
    });

/// 현재 로그인한 사용자의 AppUser Provider
final currentAppUserProvider = FutureProvider.autoDispose<AppUser?>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return null;
  }
  final repo = ref.watch(userRepositoryProvider);
  final result = await repo.getUserById(currentUser.userId);
  return result.fold((failure) => null, (user) => user);
});

/// PostFormNotifier Provider
final postFormNotifierProvider = StateNotifierProvider.autoDispose
    .family<PostFormNotifier, PostFormState, PostFormParams>((ref, params) {
      final postRepo = ref.watch(postRepositoryProvider);
      final userRepo = ref.watch(userRepositoryProvider);
      final notificationRepo = ref.watch(notificationRepositoryProvider);
      final l10n = ref.watch(appLocalizationsSyncProvider);
      return PostFormNotifier(
        postRepository: postRepo,
        userRepository: userRepo,
        notificationRepository: notificationRepo,
        currentUser: params.currentUser,
        initialPost: params.initialPost,
        parishId: params.parishId,
        l10n: l10n,
      );
    });

/// 게시글 상세 조회 Provider (postId 파라미터)
final postByIdProvider = FutureProvider.autoDispose.family<Post?, String>((
  ref,
  String postId,
) async {
  final repo = ref.watch(postRepositoryProvider);
  final result = await repo.getPostById(postId);
  return result.fold((failure) {
    // 에러 발생 시 null 반환 (UI에서 처리)
    return null;
  }, (post) => post);
});

/// 사용자 알림 스트림 Provider (userId 파라미터)
final notificationsProvider = StreamProvider.autoDispose
    .family<List<models.AppNotification>, String>((ref, String userId) {
      final repo = ref.watch(notificationRepositoryProvider);
      return repo.watchNotifications(userId);
    });

/// 게시글 댓글 스트림 Provider (postId 파라미터)
final commentsProvider = StreamProvider.autoDispose
    .family<List<Comment>, String>((ref, String postId) {
      final repo = ref.watch(postRepositoryProvider);
      return repo.watchComments(postId);
    });

/// 성당별 게시글 수 Provider (parishId 파라미터)
final postCountProvider = StreamProvider.autoDispose.family<int, String>((
  ref,
  String parishId,
) {
  final postsAsync = ref.watch(allPostsProvider(parishId));
  return postsAsync.when(
    data: (posts) => Stream.value(posts.length),
    loading: () => Stream.value(0),
    error: (error, stackTrace) => Stream.value(0),
  );
});

/// 성당별 새 게시글 여부 Provider (parishId 파라미터)
final hasNewPostsProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  String parishId,
) async {
  final postsAsync = ref.watch(allPostsProvider(parishId));

  return postsAsync.when(
    data: (posts) async {
      if (posts.isEmpty) {
        return false;
      }

      // 최신 게시글의 createdAt 가져오기
      final latestPost = posts.reduce(
        (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
      );

      // SharedPreferences에서 마지막 읽은 타임스탬프 가져오기
      final prefs = await SharedPreferences.getInstance();
      final lastReadKey = 'last_read_parish_$parishId';
      final lastReadTimestamp = prefs.getInt(lastReadKey);

      if (lastReadTimestamp == null) {
        // 처음 읽는 경우 새 게시글이 있다고 간주하지 않음
        return false;
      }

      final lastRead = DateTime.fromMillisecondsSinceEpoch(lastReadTimestamp);
      return latestPost.createdAt.isAfter(lastRead);
    },
    loading: () async => false,
    error: (error, stackTrace) async => false,
  );
});

/// 마지막 읽은 타임스탬프 업데이트 함수
Future<void> updateLastReadTimestamp(String parishId) async {
  final prefs = await SharedPreferences.getInstance();
  final lastReadKey = 'last_read_parish_$parishId';
  await prefs.setInt(lastReadKey, DateTime.now().millisecondsSinceEpoch);
}

/// 게시글 검색 Provider
///
/// [query] 검색어
/// [parishId] 성당 ID (선택사항)
/// [category] 카테고리 (선택사항: "notice", "community")
/// [type] 타입 (선택사항: "official", "normal")
final searchPostsProvider = FutureProvider.autoDispose
    .family<List<Post>, SearchPostsParams>((ref, params) async {
      final repo = ref.watch(postRepositoryProvider);
      final result = await repo.searchPosts(
        query: params.query,
        parishId: params.parishId,
        category: params.category,
        type: params.type,
      );
      return result.fold((failure) => <Post>[], (posts) => posts);
    });

/// 게시글 검색 파라미터
class SearchPostsParams {
  final String query;
  final String? parishId;
  final String? category;
  final String? type;

  SearchPostsParams({
    required this.query,
    this.parishId,
    this.category,
    this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchPostsParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          parishId == other.parishId &&
          category == other.category &&
          type == other.type;

  @override
  int get hashCode =>
      query.hashCode ^ parishId.hashCode ^ category.hashCode ^ type.hashCode;
}
