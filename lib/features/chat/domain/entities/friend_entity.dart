import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_entity.freezed.dart';

/// 친구 관계 상태
enum FriendStatus {
  none, // 관계 없음
  pending, // 친구 요청 대기 중
  accepted, // 친구
  blocked, // 차단됨
}

/// 친구 관계 엔티티
@freezed
class FriendEntity with _$FriendEntity {
  const factory FriendEntity({
    required String odId, // 관계 문서 ID
    required String userId, // 현재 사용자
    required String friendId, // 상대방 사용자
    required FriendStatus status,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? nickname, // 친구에게 설정한 별명 (선택)
  }) = _FriendEntity;

  const FriendEntity._();

  /// 친구인지 확인
  bool get isFriend => status == FriendStatus.accepted;

  /// 차단되었는지 확인
  bool get isBlocked => status == FriendStatus.blocked;

  /// 대기 중인지 확인
  bool get isPending => status == FriendStatus.pending;
}

/// 친구 정보 (친구 관계 + 사용자 정보)
@freezed
class FriendWithUserInfo with _$FriendWithUserInfo {
  const factory FriendWithUserInfo({
    required FriendEntity friend,
    required String friendUserId,
    required String friendNickname,
    String? friendProfileImageUrl,
    DateTime? lastOnlineAt,
    String? communityName, // 소속 교회
  }) = _FriendWithUserInfo;
}
