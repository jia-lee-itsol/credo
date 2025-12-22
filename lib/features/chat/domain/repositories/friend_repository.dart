import '../entities/friend_entity.dart';
import '../entities/chat_user_entity.dart';

/// 친구 Repository 인터페이스
abstract class FriendRepository {
  // ============ 친구 관계 조회 ============

  /// 내 친구 목록 스트림
  Stream<List<FriendWithUserInfo>> watchFriends(String userId);

  /// 차단한 사용자 목록 스트림
  Stream<List<FriendWithUserInfo>> watchBlockedUsers(String userId);

  /// 특정 사용자와의 친구 관계 확인
  Future<FriendEntity?> getFriendRelation({
    required String userId,
    required String targetUserId,
  });

  /// 특정 사용자와의 친구 관계 스트림
  Stream<FriendEntity?> watchFriendRelation({
    required String userId,
    required String targetUserId,
  });

  /// 친구인지 확인
  Future<bool> isFriend({
    required String userId,
    required String targetUserId,
  });

  // ============ 친구 관계 관리 ============

  /// 친구 추가
  Future<FriendEntity> addFriend({
    required String userId,
    required String friendId,
  });

  /// 친구 삭제
  Future<void> removeFriend({
    required String odId,
  });

  /// 사용자 차단
  Future<FriendEntity> blockUser({
    required String userId,
    required String targetUserId,
  });

  /// 차단 해제
  Future<void> unblockUser({
    required String odId,
  });

  /// 친구 별명 설정
  Future<void> setFriendNickname({
    required String odId,
    required String? nickname,
  });

  // ============ 사용자 검색 ============

  /// 사용자 검색 (닉네임 또는 ID로)
  Future<List<ChatUserEntity>> searchUsers({
    required String query,
    required String currentUserId,
  });

  /// 사용자 ID로 사용자 정보 가져오기
  Future<ChatUserEntity?> getUserById(String userId);

  /// 사용자 ID로 사용자 정보 스트림 (실시간 업데이트)
  Stream<ChatUserEntity?> watchUserById(String userId);
}

