import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../data/repositories/firestore_friend_repository.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/repositories/friend_repository.dart';

/// FriendRepository Provider
final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FirestoreFriendRepository();
});

/// 내 친구 목록 스트림
final friendsStreamProvider =
    StreamProvider.autoDispose<List<FriendWithUserInfo>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return const Stream.empty();
  }

  final repository = ref.watch(friendRepositoryProvider);
  return repository.watchFriends(currentUser.userId);
});

/// 차단한 사용자 목록 스트림
final blockedUsersStreamProvider =
    StreamProvider.autoDispose<List<FriendWithUserInfo>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return const Stream.empty();
  }

  final repository = ref.watch(friendRepositoryProvider);
  return repository.watchBlockedUsers(currentUser.userId);
});

/// 특정 사용자와의 친구 관계 스트림
final friendRelationProvider = StreamProvider.autoDispose
    .family<FriendEntity?, String>((ref, targetUserId) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return const Stream.empty();
  }

  final repository = ref.watch(friendRepositoryProvider);
  return repository.watchFriendRelation(
    userId: currentUser.userId,
    targetUserId: targetUserId,
  );
});

/// 친구인지 확인 Provider
final isFriendProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, targetUserId) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return false;

  final repository = ref.watch(friendRepositoryProvider);
  return repository.isFriend(
    userId: currentUser.userId,
    targetUserId: targetUserId,
  );
});

/// 사용자 검색 Provider
final friendUserSearchProvider =
    FutureProvider.autoDispose.family<List<ChatUserEntity>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];

  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];

  final repository = ref.watch(friendRepositoryProvider);
  return repository.searchUsers(
    query: query,
    currentUserId: currentUser.userId,
  );
});

/// 사용자 정보 Provider
final userByIdProvider =
    FutureProvider.autoDispose.family<ChatUserEntity?, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getUserById(userId);
});

/// 사용자 정보 스트림 Provider (실시간 업데이트)
final userByIdStreamProvider =
    StreamProvider.autoDispose.family<ChatUserEntity?, String>((
  ref,
  userId,
) {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.watchUserById(userId);
});

// ============ 친구 관리 함수들 ============

/// 친구 추가
Future<FriendEntity> addFriend(
  WidgetRef ref, {
  required String friendId,
}) async {
  final currentUser = ref.read(currentUserProvider);
  if (currentUser == null) {
    throw Exception('로그인이 필요합니다');
  }

  final repository = ref.read(friendRepositoryProvider);
  return repository.addFriend(
    userId: currentUser.userId,
    friendId: friendId,
  );
}

/// 친구 삭제
Future<void> removeFriend(
  WidgetRef ref, {
  required String odId,
}) async {
  final repository = ref.read(friendRepositoryProvider);
  await repository.removeFriend(odId: odId);
}

/// 사용자 차단
Future<FriendEntity> blockUser(
  WidgetRef ref, {
  required String targetUserId,
}) async {
  final currentUser = ref.read(currentUserProvider);
  if (currentUser == null) {
    throw Exception('로그인이 필요합니다');
  }

  final repository = ref.read(friendRepositoryProvider);
  return repository.blockUser(
    userId: currentUser.userId,
    targetUserId: targetUserId,
  );
}

/// 차단 해제
Future<void> unblockUser(
  WidgetRef ref, {
  required String odId,
}) async {
  final repository = ref.read(friendRepositoryProvider);
  await repository.unblockUser(odId: odId);
}

