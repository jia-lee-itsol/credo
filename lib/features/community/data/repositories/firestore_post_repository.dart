import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post.dart';

/// Firestore를 사용한 게시글 Repository 구현
class FirestorePostRepository implements PostRepository {
  final FirebaseFirestore _firestore;

  FirestorePostRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> createPost(Post post) async {
    // 공식 게시글인 경우 authorIsVerified가 true여야 함
    if (post.type == 'official' && !post.authorIsVerified) {
      throw Exception(
        '공식 게시글은 인증된 사용자만 작성할 수 있습니다. '
        '(authorIsVerified가 true여야 함)',
      );
    }

    try {
      // postId가 없으면 Firestore가 자동 생성하도록 함
      final docRef = post.postId.isEmpty
          ? _firestore.collection('posts').doc()
          : _firestore.collection('posts').doc(post.postId);

      // postId를 포함한 Post 객체 생성
      final postToSave = post.postId.isEmpty
          ? post.copyWith(postId: docRef.id)
          : post;

      await docRef.set(postToSave.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('게시글 생성 실패: $e');
    }
  }

  @override
  Future<void> updatePost(Post post) async {
    try {
      await _firestore
          .collection('posts')
          .doc(post.postId)
          .update(post.toJson());
    } catch (e) {
      throw Exception('게시글 업데이트 실패: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('게시글 삭제 실패: $e');
    }
  }

  @override
  Stream<List<Post>> watchOfficialNotices({String? parishId}) {
    try {
      // 공식 공지사항 쿼리: category == "notice", type == "official", status == "published"
      Query query = _firestore
          .collection('posts')
          .where('category', isEqualTo: 'notice')
          .where('type', isEqualTo: 'official')
          .where('status', isEqualTo: 'published');

      // parishId가 제공된 경우 추가 필터링
      if (parishId != null && parishId.isNotEmpty) {
        query = query.where('parishId', isEqualTo: parishId);
      }

      // 최신순 정렬
      query = query.orderBy('createdAt', descending: true);

      debugPrint('🔍 watchOfficialNotices 쿼리 실행: parishId=$parishId');

      return query
          .snapshots()
          .map((snapshot) {
            debugPrint(
              '📊 watchOfficialNotices 결과: ${snapshot.docs.length}개 문서',
            );
            final posts = snapshot.docs
                .map((doc) {
                  try {
                    return Post.fromFirestore(doc);
                  } catch (e) {
                    debugPrint('❌ Post 파싱 에러 (docId: ${doc.id}): $e');
                    return null;
                  }
                })
                .whereType<Post>()
                .toList();
            return posts;
          })
          .handleError((error, stackTrace) {
            debugPrint('❌ watchOfficialNotices 스트림 에러: $error');
            debugPrint('스택 트레이스: $stackTrace');
            throw error;
          });
    } catch (e, stackTrace) {
      debugPrint('❌ watchOfficialNotices 초기화 에러: $e');
      debugPrint('스택 트레이스: $stackTrace');
      return Stream.value(<Post>[]).map((_) {
        throw e;
      });
    }
  }

  @override
  Stream<List<Post>> watchCommunityPosts({String? parishId}) {
    try {
      // 커뮤니티 게시글 쿼리: category == "community", type == "normal", status == "published"
      Query query = _firestore
          .collection('posts')
          .where('category', isEqualTo: 'community')
          .where('type', isEqualTo: 'normal')
          .where('status', isEqualTo: 'published');

      // TODO: parishId 필터링은 나중에 인덱스가 완전히 빌드된 후 활성화
      // 현재는 모든 커뮤니티 게시글을 조회 (parishId 무시)
      // if (parishId != null && parishId.isNotEmpty) {
      //   query = query.where('parishId', isEqualTo: parishId);
      // }

      // 최신순 정렬
      query = query.orderBy('createdAt', descending: true);

      debugPrint('🔍 watchCommunityPosts 쿼리 실행: parishId=$parishId (필터링 비활성화)');

      return query
          .snapshots()
          .map((snapshot) {
            debugPrint(
              '📊 watchCommunityPosts 결과: ${snapshot.docs.length}개 문서',
            );
            final posts = snapshot.docs
                .map((doc) {
                  try {
                    return Post.fromFirestore(doc);
                  } catch (e) {
                    debugPrint('❌ Post 파싱 에러 (docId: ${doc.id}): $e');
                    return null;
                  }
                })
                .whereType<Post>()
                .toList();
            return posts;
          })
          .handleError((error, stackTrace) {
            debugPrint('❌ watchCommunityPosts 스트림 에러: $error');
            debugPrint('스택 트레이스: $stackTrace');
            // 에러를 다시 throw하여 UI에서 처리할 수 있도록 함
            throw error;
          });
    } catch (e, stackTrace) {
      debugPrint('❌ watchCommunityPosts 초기화 에러: $e');
      debugPrint('스택 트레이스: $stackTrace');
      // 에러 스트림 반환
      return Stream.value(<Post>[]).map((_) {
        throw e;
      });
    }
  }
}
