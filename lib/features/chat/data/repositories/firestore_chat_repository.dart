import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Firestore를 사용한 ChatRepository 구현
class FirestoreChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  FirestoreChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _conversationsRef =>
      _firestore.collection('conversations');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  // ============ 대화방 관련 ============

  @override
  Stream<List<ConversationEntity>> watchConversations(String userId) {
    return _conversationsRef
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Stream<ConversationEntity?> watchConversation(String conversationId) {
    return _conversationsRef.doc(conversationId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ConversationModel.fromFirestore(snapshot).toEntity();
    });
  }

  @override
  String generateDirectConversationId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  Future<ConversationEntity> getOrCreateDirectConversation({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final conversationId =
        generateDirectConversationId(currentUserId, otherUserId);

    final doc = await _conversationsRef.doc(conversationId).get();

    if (doc.exists) {
      return ConversationModel.fromFirestore(doc).toEntity();
    }

    // 새 대화방 생성
    final now = DateTime.now();
    final conversation = ConversationModel(
      conversationId: conversationId,
      participants: [currentUserId, otherUserId],
      type: 'direct',
      createdAt: now,
      updatedAt: now,
    );

    await _conversationsRef.doc(conversationId).set(conversation.toJson());

    return conversation.toEntity();
  }

  @override
  Future<ConversationEntity> createGroupConversation({
    required String creatorId,
    required List<String> participantIds,
    required String name,
    String? imageUrl,
  }) async {
    final conversationId = _uuid.v4();
    final now = DateTime.now();

    // 생성자를 참여자에 포함
    final allParticipants = {...participantIds, creatorId}.toList();

    final conversation = ConversationModel(
      conversationId: conversationId,
      participants: allParticipants,
      type: 'group',
      name: name,
      imageUrl: imageUrl,
      createdBy: creatorId,
      createdAt: now,
      updatedAt: now,
    );

    await _conversationsRef.doc(conversationId).set(conversation.toJson());

    return conversation.toEntity();
  }

  @override
  Future<void> leaveConversation({
    required String conversationId,
    required String userId,
    required String userNickname,
  }) async {
    final doc = await _conversationsRef.doc(conversationId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final participants = List<String>.from(data['participants'] ?? []);
    participants.remove(userId);

    if (participants.isEmpty) {
      // 모든 참여자가 나가면 대화방 삭제
      await _conversationsRef.doc(conversationId).delete();
    } else {
      // 1. 시스템 메시지 추가 (상대방에게 표시)
      final messageRef = _messagesRef(conversationId).doc();
      final systemMessage = {
        'messageId': messageRef.id,
        'conversationId': conversationId,
        'senderId': 'system',
        'content': '$userNicknameさんがチャットを退出しました',
        'imageUrls': <String>[],
        'readBy': <String, dynamic>{},
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'system',
      };
      await messageRef.set(systemMessage);

      // 2. 참여자 목록 업데이트 및 마지막 메시지 정보 업데이트
      await _conversationsRef.doc(conversationId).update({
        'participants': participants,
        'lastMessage': '$userNicknameさんがチャットを退出しました',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> updateConversationName({
    required String conversationId,
    required String name,
  }) async {
    await _conversationsRef.doc(conversationId).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> addMembersToConversation({
    required String conversationId,
    required List<String> memberIds,
    required String addedByNickname,
  }) async {
    final doc = await _conversationsRef.doc(conversationId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final participants = List<String>.from(data['participants'] ?? []);
    final currentType = data['type'] as String? ?? 'direct';

    // 새 멤버 추가
    for (final memberId in memberIds) {
      if (!participants.contains(memberId)) {
        participants.add(memberId);
      }
    }

    // 1:1 채팅이었다면 그룹 채팅으로 변경
    final newType = participants.length > 2 ? 'group' : currentType;

    // 시스템 메시지 추가
    final messageRef = _messagesRef(conversationId).doc();
    final inviteMessage = memberIds.length == 1
        ? '$addedByNicknameさんが新しいメンバーを招待しました'
        : '$addedByNicknameさんが${memberIds.length}人を招待しました';

    final systemMessage = {
      'messageId': messageRef.id,
      'conversationId': conversationId,
      'senderId': 'system',
      'content': inviteMessage,
      'imageUrls': <String>[],
      'readBy': <String, dynamic>{},
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'system',
    };
    await messageRef.set(systemMessage);

    // 대화방 업데이트
    await _conversationsRef.doc(conversationId).update({
      'participants': participants,
      'type': newType,
      'lastMessage': inviteMessage,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============ 메시지 관련 ============

  CollectionReference<Map<String, dynamic>> _messagesRef(
          String conversationId) =>
      _conversationsRef.doc(conversationId).collection('messages');

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    return _messagesRef(conversationId)
        .orderBy('createdAt', descending: false)
        .limitToLast(100) // 최근 100개 메시지
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Future<List<MessageEntity>> loadMessages({
    required String conversationId,
    int limit = 50,
    DateTime? before,
  }) async {
    Query<Map<String, dynamic>> query =
        _messagesRef(conversationId).orderBy('createdAt', descending: true);

    if (before != null) {
      query = query.startAfter([Timestamp.fromDate(before)]);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs
        .map((doc) => MessageModel.fromFirestore(doc).toEntity())
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<List<MessageEntity>> searchMessages({
    required String conversationId,
    required String query,
    int limit = 50,
  }) async {
    if (query.isEmpty) return [];

    // 모든 메시지 가져오기 (Firestore는 텍스트 검색을 직접 지원하지 않으므로)
    final snapshot = await _messagesRef(conversationId)
        .orderBy('createdAt', descending: true)
        .limit(500) // 검색 범위 제한
        .get();

    final queryLower = query.toLowerCase().trim();
    final results = <MessageEntity>[];

    for (final doc in snapshot.docs) {
      if (results.length >= limit) break;

      final message = MessageModel.fromFirestore(doc).toEntity();
      
      // 삭제된 메시지나 시스템 메시지는 제외
      if (message.isDeleted || message.isSystemMessage) continue;

      // 메시지 내용에서 검색
      if (message.content.toLowerCase().contains(queryLower)) {
        results.add(message);
      }
    }

    // 시간순 정렬 (오래된 것부터)
    results.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return results;
  }

  @override
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    List<String> imageUrls = const [],
  }) async {
    final messageId = _uuid.v4();
    final now = DateTime.now();

    final message = MessageModel(
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      imageUrls: imageUrls,
      readBy: {senderId: now}, // 발신자는 자동으로 읽음 처리
      createdAt: now,
    );

    // 배치로 메시지 추가 및 대화방 업데이트
    final batch = _firestore.batch();

    // 메시지 추가
    batch.set(
      _messagesRef(conversationId).doc(messageId),
      message.toJson(),
    );

    // 대화방의 lastMessage 업데이트
    batch.update(_conversationsRef.doc(conversationId), {
      'lastMessage': {
        'content': content.isNotEmpty ? content : '📷 이미지',
        'senderId': senderId,
        'createdAt': Timestamp.fromDate(now),
      },
      'lastMessageAt': Timestamp.fromDate(now),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return message.toEntity();
  }

  @override
  Future<void> markMessageAsRead({
    required String messageId,
    required String conversationId,
    required String userId,
  }) async {
    await _messagesRef(conversationId).doc(messageId).update({
      'readBy.$userId': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAllMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    // 읽지 않은 메시지 가져오기
    final snapshot = await _messagesRef(conversationId)
        .where('readBy.$userId', isNull: true)
        .get();

    if (snapshot.docs.isEmpty) return;

    // 배치로 모두 읽음 처리
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'readBy.$userId': now,
        'updatedAt': now,
      });
    }

    await batch.commit();
  }

  @override
  Future<void> deleteMessage({
    required String messageId,
    required String conversationId,
    required String userId,
  }) async {
    await _messagesRef(conversationId).doc(messageId).update({
      'deletedAt': FieldValue.serverTimestamp(),
      'deletedBy': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============ 사용자 관련 ============

  @override
  Future<ChatUserEntity?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return ChatUserEntity(
      userId: userId,
      nickname: data['nickname'] ?? data['displayName'] ?? '알 수 없음',
      profileImageUrl: data['profileImageUrl'] ?? data['photoUrl'],
      lastOnlineAt: (data['lastOnlineAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<List<ChatUserEntity>> getUsers(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    // Firestore in 쿼리는 최대 10개까지만 지원
    final chunks = <List<String>>[];
    for (var i = 0; i < userIds.length; i += 10) {
      chunks.add(
          userIds.sublist(i, i + 10 > userIds.length ? userIds.length : i + 10));
    }

    final users = <ChatUserEntity>[];
    for (final chunk in chunks) {
      final snapshot =
          await _usersRef.where(FieldPath.documentId, whereIn: chunk).get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        users.add(ChatUserEntity(
          userId: doc.id,
          nickname: data['nickname'] ?? data['displayName'] ?? '알 수 없음',
          profileImageUrl: data['profileImageUrl'] ?? data['photoUrl'],
          lastOnlineAt: (data['lastOnlineAt'] as Timestamp?)?.toDate(),
        ));
      }
    }

    return users;
  }

  @override
  Future<List<ChatUserEntity>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    // 닉네임으로 검색 (startsWith 방식)
    final snapshot = await _usersRef
        .where('nickname', isGreaterThanOrEqualTo: query)
        .where('nickname', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ChatUserEntity(
        userId: doc.id,
        nickname: data['nickname'] ?? data['displayName'] ?? '알 수 없음',
        profileImageUrl: data['profileImageUrl'] ?? data['photoUrl'],
        lastOnlineAt: (data['lastOnlineAt'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  // ============ 읽지 않은 메시지 ============

  @override
  Stream<int> watchUnreadCount(String userId) {
    return watchConversations(userId).asyncMap((conversations) async {
      int totalUnread = 0;
      for (final conversation in conversations) {
        final unreadSnapshot = await _messagesRef(conversation.conversationId)
            .where('senderId', isNotEqualTo: userId)
            .get();

        for (final doc in unreadSnapshot.docs) {
          final data = doc.data();
          final readBy = data['readBy'] as Map<String, dynamic>? ?? {};
          if (!readBy.containsKey(userId)) {
            totalUnread++;
          }
        }
      }
      return totalUnread;
    });
  }

  @override
  Stream<int> watchConversationUnreadCount({
    required String conversationId,
    required String userId,
  }) {
    // 대화방 정보와 메시지 스트림을 결합
    return _conversationsRef
        .doc(conversationId)
        .snapshots()
        .asyncMap((conversationSnapshot) async {
      // 대화방 정보 확인
      if (!conversationSnapshot.exists) return 0;

      final conversationData = conversationSnapshot.data();
      if (conversationData == null) return 0;

      // 마지막 메시지 정보 확인
      final lastMessageData = conversationData['lastMessage'] as Map<String, dynamic>?;
      final lastMessageSenderId = lastMessageData?['senderId'] as String?;

      // 마지막 메시지가 내가 보낸 메시지인 경우, 읽지 않은 메시지가 없음
      if (lastMessageSenderId == userId) {
        return 0;
      }

      // 읽지 않은 메시지 카운트
      final messagesSnapshot = await _messagesRef(conversationId)
          .where('senderId', isNotEqualTo: userId)
          .get();

      int unread = 0;
      for (final doc in messagesSnapshot.docs) {
        final data = doc.data();
        final readBy = data['readBy'] as Map<String, dynamic>? ?? {};
        if (!readBy.containsKey(userId)) {
          unread++;
        }
      }
      return unread;
    });
  }

  // ============ 타이핑 인디케이터 ============

  @override
  Future<void> updateTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    final typingRef = _conversationsRef
        .doc(conversationId)
        .collection('typing')
        .doc(userId);

    if (isTyping) {
      await typingRef.set({
        'userId': userId,
        'isTyping': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await typingRef.delete();
    }
  }

  @override
  Stream<List<String>> watchTypingUsers({
    required String conversationId,
    required String currentUserId,
  }) {
    return _conversationsRef
        .doc(conversationId)
        .collection('typing')
        .where('isTyping', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final typingUsers = <String>[];
      final now = DateTime.now();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String?;
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

        // 자신 제외 및 5초 이내 업데이트만 표시
        if (userId != null &&
            userId != currentUserId &&
            updatedAt != null &&
            now.difference(updatedAt).inSeconds < 5) {
          typingUsers.add(userId);
        }
      }

      return typingUsers;
    });
  }
}

