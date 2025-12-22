import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/repositories/friend_repository.dart';
import '../models/friend_model.dart';

/// Firestore를 사용한 FriendRepository 구현
class FirestoreFriendRepository implements FriendRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  FirestoreFriendRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _friendsRef =>
      _firestore.collection('friends');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _parishesRef =>
      _firestore.collection('parishes');

  // 캐시된 교회 이름
  final Map<String, String> _parishNameCache = {};

  /// 교회 이름 가져오기 (캐시 사용)
  Future<String?> _getParishName(String? parishId) async {
    if (parishId == null || parishId.isEmpty) return null;
    
    if (_parishNameCache.containsKey(parishId)) {
      return _parishNameCache[parishId];
    }
    
    try {
      final doc = await _parishesRef.doc(parishId).get();
      if (doc.exists) {
        final name = doc.data()?['name'] as String?;
        if (name != null) {
          _parishNameCache[parishId] = name;
        }
        return name;
      }
    } catch (_) {
      // 에러 무시
    }
    return null;
  }

  // ============ 친구 관계 조회 ============

  @override
  Stream<List<FriendWithUserInfo>> watchFriends(String userId) {
    return _friendsRef
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final friends = <FriendWithUserInfo>[];

      for (final doc in snapshot.docs) {
        final friendModel = FriendModel.fromFirestore(doc);
        final friendEntity = friendModel.toEntity();

        // 친구 사용자 정보 가져오기
        final userDoc = await _usersRef.doc(friendEntity.friendId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final parishId = userData['main_parish_id'] as String? ??
              userData['parishId'] as String?;
          final communityName = await _getParishName(parishId);
          
          friends.add(FriendWithUserInfo(
            friend: friendEntity,
            friendUserId: friendEntity.friendId,
            friendNickname:
                friendEntity.nickname ?? userData['nickname'] ?? '알 수 없음',
            friendProfileImageUrl: userData['profileImageUrl'],
            lastOnlineAt: (userData['lastOnlineAt'] as Timestamp?)?.toDate(),
            communityName: communityName,
          ));
        }
      }

      return friends;
    });
  }

  @override
  Stream<List<FriendWithUserInfo>> watchBlockedUsers(String userId) {
    return _friendsRef
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'blocked')
        .snapshots()
        .asyncMap((snapshot) async {
      final blocked = <FriendWithUserInfo>[];

      for (final doc in snapshot.docs) {
        final friendModel = FriendModel.fromFirestore(doc);
        final friendEntity = friendModel.toEntity();

        final userDoc = await _usersRef.doc(friendEntity.friendId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          blocked.add(FriendWithUserInfo(
            friend: friendEntity,
            friendUserId: friendEntity.friendId,
            friendNickname: userData['nickname'] ?? '알 수 없음',
            friendProfileImageUrl: userData['profileImageUrl'],
          ));
        }
      }

      return blocked;
    });
  }

  @override
  Future<FriendEntity?> getFriendRelation({
    required String userId,
    required String targetUserId,
  }) async {
    final snapshot = await _friendsRef
        .where('userId', isEqualTo: userId)
        .where('friendId', isEqualTo: targetUserId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return FriendModel.fromFirestore(snapshot.docs.first).toEntity();
  }

  @override
  Stream<FriendEntity?> watchFriendRelation({
    required String userId,
    required String targetUserId,
  }) {
    return _friendsRef
        .where('userId', isEqualTo: userId)
        .where('friendId', isEqualTo: targetUserId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return FriendModel.fromFirestore(snapshot.docs.first).toEntity();
    });
  }

  @override
  Future<bool> isFriend({
    required String userId,
    required String targetUserId,
  }) async {
    final relation = await getFriendRelation(
      userId: userId,
      targetUserId: targetUserId,
    );
    return relation?.status == FriendStatus.accepted;
  }

  // ============ 친구 관계 관리 ============

  @override
  Future<FriendEntity> addFriend({
    required String userId,
    required String friendId,
  }) async {
    // 기존 관계 확인
    final existingRelation = await getFriendRelation(
      userId: userId,
      targetUserId: friendId,
    );

    if (existingRelation != null) {
      // 차단 상태였다면 친구로 변경
      if (existingRelation.status == FriendStatus.blocked) {
        await _friendsRef.doc(existingRelation.odId).update({
          'status': 'accepted',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return existingRelation.copyWith(status: FriendStatus.accepted);
      }
      return existingRelation;
    }

    // 새 친구 관계 생성
    final odId = _uuid.v4();
    final now = DateTime.now();

    final friendModel = FriendModel(
      odId: odId,
      userId: userId,
      friendId: friendId,
      status: 'accepted',
      createdAt: now,
    );

    await _friendsRef.doc(odId).set(friendModel.toJson());

    return friendModel.toEntity();
  }

  @override
  Future<void> removeFriend({required String odId}) async {
    await _friendsRef.doc(odId).delete();
  }

  @override
  Future<FriendEntity> blockUser({
    required String userId,
    required String targetUserId,
  }) async {
    // 기존 관계 확인
    final existingRelation = await getFriendRelation(
      userId: userId,
      targetUserId: targetUserId,
    );

    if (existingRelation != null) {
      // 기존 관계를 차단으로 변경
      await _friendsRef.doc(existingRelation.odId).update({
        'status': 'blocked',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return existingRelation.copyWith(status: FriendStatus.blocked);
    }

    // 새 차단 관계 생성
    final odId = _uuid.v4();
    final now = DateTime.now();

    final friendModel = FriendModel(
      odId: odId,
      userId: userId,
      friendId: targetUserId,
      status: 'blocked',
      createdAt: now,
    );

    await _friendsRef.doc(odId).set(friendModel.toJson());

    return friendModel.toEntity();
  }

  @override
  Future<void> unblockUser({required String odId}) async {
    await _friendsRef.doc(odId).delete();
  }

  @override
  Future<void> setFriendNickname({
    required String odId,
    required String? nickname,
  }) async {
    await _friendsRef.doc(odId).update({
      'nickname': nickname,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============ 사용자 검색 ============

  @override
  Future<List<ChatUserEntity>> searchUsers({
    required String query,
    required String currentUserId,
  }) async {
    if (query.isEmpty) return [];

    final usersMap = <String, ChatUserEntity>{};
    final lowerQuery = query.toLowerCase();

    // 1. 닉네임으로 검색 (prefix 매칭)
    final nicknameSnapshot = await _usersRef
        .where('nickname', isGreaterThanOrEqualTo: query)
        .where('nickname', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    for (final doc in nicknameSnapshot.docs) {
      if (doc.id != currentUserId && !usersMap.containsKey(doc.id)) {
        final data = doc.data();
        usersMap[doc.id] = ChatUserEntity(
          userId: doc.id,
          nickname: data['nickname'] ?? '알 수 없음',
          profileImageUrl: data['profileImageUrl'],
          lastOnlineAt: (data['lastOnlineAt'] as Timestamp?)?.toDate(),
        );
      }
    }

    // 2. 이메일로 검색 (prefix 매칭)
    final emailSnapshot = await _usersRef
        .where('email', isGreaterThanOrEqualTo: lowerQuery)
        .where('email', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
        .limit(20)
        .get();

    for (final doc in emailSnapshot.docs) {
      if (doc.id != currentUserId && !usersMap.containsKey(doc.id)) {
        final data = doc.data();
        usersMap[doc.id] = ChatUserEntity(
          userId: doc.id,
          nickname: data['nickname'] ?? '알 수 없음',
          profileImageUrl: data['profileImageUrl'],
          lastOnlineAt: (data['lastOnlineAt'] as Timestamp?)?.toDate(),
        );
      }
    }

    // 3. 정확한 이메일 매칭
    final exactEmailSnapshot = await _usersRef
        .where('email', isEqualTo: lowerQuery)
        .limit(1)
        .get();

    for (final doc in exactEmailSnapshot.docs) {
      if (doc.id != currentUserId && !usersMap.containsKey(doc.id)) {
        final data = doc.data();
        usersMap[doc.id] = ChatUserEntity(
          userId: doc.id,
          nickname: data['nickname'] ?? '알 수 없음',
          profileImageUrl: data['profileImageUrl'],
          lastOnlineAt: (data['lastOnlineAt'] as Timestamp?)?.toDate(),
        );
      }
    }

    // 4. 사용자 ID로 검색 (정확히 일치)
    if (!usersMap.containsKey(query) && query != currentUserId) {
      final userDoc = await _usersRef.doc(query).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        usersMap[query] = ChatUserEntity(
          userId: userDoc.id,
          nickname: data['nickname'] ?? '알 수 없음',
          profileImageUrl: data['profileImageUrl'],
          lastOnlineAt: (data['lastOnlineAt'] as Timestamp?)?.toDate(),
        );
      }
    }

    return usersMap.values.toList();
  }

  @override
  Future<ChatUserEntity?> getUserById(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    // profileImageUrl, profile_image_url, photoUrl 필드 확인 (다양한 필드명 지원)
    final profileImageUrl = data['profileImageUrl'] ?? 
                            data['profile_image_url'] ?? 
                            data['photoUrl'];
    return ChatUserEntity(
      userId: doc.id,
      nickname: data['nickname'] ?? '알 수 없음',
      profileImageUrl: profileImageUrl,
      lastOnlineAt: (data['lastOnlineAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Stream<ChatUserEntity?> watchUserById(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;

      final data = doc.data()!;
      // profileImageUrl, profile_image_url, photoUrl 필드 확인 (다양한 필드명 지원)
      final profileImageUrl = data['profileImageUrl'] ?? 
                              data['profile_image_url'] ?? 
                              data['photoUrl'];
      return ChatUserEntity(
        userId: doc.id,
        nickname: data['nickname'] ?? '알 수 없음',
        profileImageUrl: profileImageUrl,
        lastOnlineAt: (data['lastOnlineAt'] as Timestamp?)?.toDate(),
      );
    });
  }
}

