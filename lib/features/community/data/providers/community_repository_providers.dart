import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/providers/auth_provider.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/notifiers/post_form_notifier.dart';
import '../models/app_user.dart';
import '../models/post.dart';
import '../repositories/firestore_post_repository.dart';
import '../repositories/firestore_user_repository.dart';

/// PostRepository Provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return FirestorePostRepository();
});

/// UserRepository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirestoreUserRepository();
});

/// 공식 공지사항 스트림 Provider (parishId 파라미터 지원)
final officialNoticesProvider = StreamProvider.autoDispose
    .family<List<Post>, String?>((ref, String? parishId) {
      final repo = ref.watch(postRepositoryProvider);
      return repo.watchOfficialNotices(parishId: parishId);
    });

/// 커뮤니티 게시글 스트림 Provider (parishId 파라미터 지원)
final communityPostsProvider = StreamProvider.autoDispose
    .family<List<Post>, String?>((ref, String? parishId) {
      final repo = ref.watch(postRepositoryProvider);
      return repo.watchCommunityPosts(parishId: parishId);
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
) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUserById(uid);
});

/// 현재 로그인한 사용자의 AppUser Provider
final currentAppUserProvider = FutureProvider.autoDispose<AppUser?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return Future.value(null);
  }
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUserById(currentUser.userId);
});

/// PostFormNotifier Provider
final postFormNotifierProvider = StateNotifierProvider.autoDispose
    .family<PostFormNotifier, PostFormState, PostFormParams>((ref, params) {
      final repo = ref.watch(postRepositoryProvider);
      return PostFormNotifier(
        postRepository: repo,
        currentUser: params.currentUser,
        initialPost: params.initialPost,
        isOfficial: params.isOfficial,
        parishId: params.parishId,
      );
    });
