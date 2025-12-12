import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/extensions/post_extensions.dart';
import '../../domain/failures/community_failures.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/comment.dart';
import '../models/post.dart';

/// Firestore를 사용한 게시글 Repository 구현
class FirestorePostRepository implements PostRepository {
  final FirebaseFirestore _firestore;

  FirestorePostRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, String>> createPost(Post post) async {
    // 공식 게시글인 경우 authorIsVerified가 true여야 함
    if (post.type == 'official' && !post.authorIsVerified) {
      return const Left(
        InsufficientPermissionFailure(
          message:
              '공식 게시글은 인증된 사용자만 작성할 수 있습니다. '
              '(authorIsVerified가 true여야 함)',
        ),
      );
    }

    try {
      AppLogger.community('===== createPost() 호출됨 =====');
      AppLogger.community('게시글 제목: ${post.title}');
      AppLogger.community('게시글 카테고리: ${post.category}');
      AppLogger.community('게시글 타입: ${post.type}');
      AppLogger.community('parishId: ${post.parishId}');
      AppLogger.community('authorId: ${post.authorId}');
      AppLogger.community('authorName: ${post.authorName}');
      AppLogger.community('authorRole: ${post.authorRole}');
      AppLogger.community('authorIsVerified: ${post.authorIsVerified}');
      AppLogger.community('status: ${post.status}');

      // postId가 없으면 Firestore가 자동 생성하도록 함
      final docRef = post.postId.isEmpty
          ? _firestore.collection('posts').doc()
          : _firestore.collection('posts').doc(post.postId);

      AppLogger.community('문서 ID: ${docRef.id}');

      // postId를 포함한 Post 객체 생성
      final postToSave = post.postId.isEmpty
          ? post.copyWith(postId: docRef.id)
          : post;

      final postData = postToSave.toFirestore();

      // 데이터를 필드별로 상세 출력
      AppLogger.debug('===== Firestore에 저장할 데이터 =====');
      postData.forEach((key, value) {
        if (value is Timestamp) {
          AppLogger.debug('  $key: ${value.toDate()} (Timestamp)');
        } else if (value == null) {
          AppLogger.debug('  $key: null');
        } else {
          AppLogger.debug('  $key: $value (${value.runtimeType})');
        }
      });
      AppLogger.debug('====================================');
      AppLogger.debug('전체 JSON: $postData');
      AppLogger.community('문서 경로: posts/${docRef.id}');
      AppLogger.community('docRef.set() 호출 시작...');

      await docRef.set(postData);

      AppLogger.community('✅ docRef.set() 완료!');
      AppLogger.community('✅ 게시글 생성 성공: ${docRef.id}');

      // 저장 후 실제로 저장되었는지 확인
      final savedDoc = await docRef.get();
      AppLogger.community('저장 확인: 문서 존재=${savedDoc.exists}');
      if (savedDoc.exists) {
        AppLogger.debug('===== 저장된 데이터 확인 =====');
        final savedData = savedDoc.data();
        savedData?.forEach((key, value) {
          if (value is Timestamp) {
            AppLogger.debug('  $key: ${value.toDate()} (Timestamp)');
          } else {
            AppLogger.debug('  $key: $value (${value.runtimeType})');
          }
        });
        AppLogger.debug('====================================');
      } else {
        AppLogger.warning('⚠️ 문서가 존재하지 않습니다!');
      }

      return Right(docRef.id);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('===== 게시글 생성 실패 =====', e, stackTrace);
      return Left(
        FirebaseFailure(message: e.message ?? '게시글 생성 실패', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('게시글 생성 실패: $e', e, stackTrace);
      return Left(PostCreationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePost(Post post) async {
    try {
      await _firestore
          .collection('posts')
          .doc(post.postId)
          .update(post.toFirestore());
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.error('게시글 업데이트 실패: $e', e);
      return Left(
        FirebaseFailure(message: e.message ?? '게시글 업데이트 실패', code: e.code),
      );
    } catch (e) {
      AppLogger.error('게시글 업데이트 실패: $e', e);
      return Left(PostUpdateFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.error('게시글 삭제 실패: $e', e);
      return Left(
        FirebaseFailure(message: e.message ?? '게시글 삭제 실패', code: e.code),
      );
    } catch (e) {
      AppLogger.error('게시글 삭제 실패: $e', e);
      return Left(PostDeleteFailure(message: e.toString()));
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

      AppLogger.community('watchOfficialNotices 쿼리 실행: parishId=$parishId');

      return query
          .snapshots()
          .map((snapshot) {
            AppLogger.community(
              'watchOfficialNotices 결과: ${snapshot.docs.length}개 문서',
            );
            final posts = snapshot.docs
                .map((doc) {
                  try {
                    return Post.fromFirestore(doc);
                  } catch (e) {
                    AppLogger.error('Post 파싱 에러 (docId: ${doc.id}): $e', e);
                    return null;
                  }
                })
                .whereType<Post>()
                .toList();
            // 핀 고정된 게시글을 상단에 표시
            return posts.sortByPinnedAndDate();
          })
          .handleError((error, stackTrace) {
            AppLogger.error(
              'watchOfficialNotices 스트림 에러: $error',
              error,
              stackTrace,
            );
            throw error;
          });
    } catch (e, stackTrace) {
      AppLogger.error('watchOfficialNotices 초기화 에러: $e', e, stackTrace);
      return Stream.value(<Post>[]);
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

      // parishId 필터링 활성화 (복합 인덱스 필요)
      // Firestore 복합 인덱스:
      // Collection: posts
      // Fields: category (Ascending), type (Ascending), status (Ascending),
      //         parishId (Ascending), createdAt (Descending)
      if (parishId != null && parishId.isNotEmpty) {
        query = query.where('parishId', isEqualTo: parishId);
      }

      // 최신순 정렬
      query = query.orderBy('createdAt', descending: true);

      AppLogger.community('watchCommunityPosts 쿼리 실행: parishId=$parishId');

      return query
          .snapshots()
          .map((snapshot) {
            AppLogger.community(
              'watchCommunityPosts 결과: ${snapshot.docs.length}개 문서',
            );
            final posts = snapshot.docs
                .map((doc) {
                  try {
                    return Post.fromFirestore(doc);
                  } catch (e) {
                    AppLogger.error('Post 파싱 에러 (docId: ${doc.id}): $e', e);
                    return null;
                  }
                })
                .whereType<Post>()
                .toList();
            // 핀 고정된 게시글을 상단에 표시
            return posts.sortByPinnedAndDate();
          })
          .handleError((error, stackTrace) {
            AppLogger.error(
              'watchCommunityPosts 스트림 에러: $error',
              error,
              stackTrace,
            );
            // 에러를 다시 throw하여 UI에서 처리할 수 있도록 함
            throw error;
          });
    } catch (e, stackTrace) {
      AppLogger.error('watchCommunityPosts 초기화 에러: $e', e, stackTrace);
      // 에러 발생 시 빈 리스트 스트림 반환
      return Stream.value(<Post>[]);
    }
  }

  @override
  Stream<List<Post>> watchAllPosts({String? parishId}) {
    try {
      // 모든 게시글 쿼리: status == "published"
      Query query = _firestore
          .collection('posts')
          .where('status', isEqualTo: 'published');

      // parishId 필터링 활성화 (복합 인덱스 필요)
      // Firestore 복합 인덱스:
      // Collection: posts
      // Fields: status (Ascending), parishId (Ascending), createdAt (Descending)
      if (parishId != null && parishId.isNotEmpty) {
        query = query.where('parishId', isEqualTo: parishId);
      }

      query = query.orderBy('createdAt', descending: true);

      AppLogger.community('watchAllPosts 쿼리 실행: parishId=$parishId');

      return query
          .snapshots()
          .map((snapshot) {
            AppLogger.community(
              'watchAllPosts 결과: ${snapshot.docs.length}개 문서',
            );
            var posts = snapshot.docs
                .map((doc) {
                  try {
                    return Post.fromFirestore(doc);
                  } catch (e) {
                    AppLogger.error('Post 파싱 에러 (docId: ${doc.id}): $e', e);
                    return null;
                  }
                })
                .whereType<Post>()
                .toList();

            // 핀 고정된 게시글을 상단에 표시
            for (final post in posts) {
              AppLogger.debug(
                'watchAllPosts 게시글: title="${post.title}", isPinned=${post.isPinned}, type=${post.type}, category=${post.category}',
              );
            }
            posts = posts.sortByPinnedAndDate();
            AppLogger.debug(
              'watchAllPosts 정렬 후 첫 번째: ${posts.isNotEmpty ? posts.first.title : "없음"}',
            );
            return posts;
          })
          .handleError((error, stackTrace) {
            AppLogger.error('watchAllPosts 스트림 에러: $error', error, stackTrace);
            throw error;
          });
    } catch (e, stackTrace) {
      AppLogger.error('watchAllPosts 초기화 에러: $e', e, stackTrace);
      // 에러 발생 시 빈 리스트 스트림 반환
      return Stream.value(<Post>[]);
    }
  }

  @override
  Future<Either<Failure, Post?>> getPostById(String postId) async {
    try {
      AppLogger.community('getPostById 호출: postId=$postId');
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (!doc.exists) {
        AppLogger.warning('게시글을 찾을 수 없음: postId=$postId');
        return const Right(null);
      }

      AppLogger.community('✅ 게시글 조회 성공: postId=$postId');
      return Right(Post.fromFirestore(doc));
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('getPostById 에러: $e', e, stackTrace);
      return Left(
        FirebaseFailure(message: e.message ?? '게시글 조회 실패', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('getPostById 에러: $e', e, stackTrace);
      return Left(PostNotFoundFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
  }) async {
    try {
      AppLogger.community('댓글 생성: postId=$postId, authorId=$authorId');

      // Firestore transaction을 사용하여 댓글 생성과 게시글 commentCount 업데이트를 원자적으로 처리
      final commentId = await _firestore.runTransaction<String>((
        transaction,
      ) async {
        // 댓글 문서 생성
        final commentRef = _firestore.collection('comments').doc();
        final comment = Comment(
          commentId: commentRef.id,
          postId: postId,
          authorId: authorId,
          authorName: authorName,
          content: content,
          createdAt: DateTime.now(),
        );
        transaction.set(commentRef, comment.toFirestore());

        // 게시글 문서의 commentCount 증가
        final postRef = _firestore.collection('posts').doc(postId);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          throw Exception('게시글을 찾을 수 없습니다: $postId');
        }

        final currentCount = (postDoc.data()?['commentCount'] as int?) ?? 0;
        transaction.update(postRef, {
          'commentCount': currentCount + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return commentRef.id;
      });

      AppLogger.community('✅ 댓글 생성 완료: $commentId');
      return Right(commentId);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('댓글 생성 실패: $e', e, stackTrace);
      return Left(
        FirebaseFailure(message: e.message ?? '댓글 생성 실패', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('댓글 생성 실패: $e', e, stackTrace);
      return Left(CommentCreationFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Comment>> watchComments(String postId) {
    try {
      return _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .snapshots()
          .map((snapshot) {
            AppLogger.community('댓글 조회: ${snapshot.docs.length}개');
            final comments = snapshot.docs
                .map((doc) {
                  try {
                    return Comment.fromFirestore(doc);
                  } catch (e) {
                    AppLogger.error('댓글 파싱 에러 (docId: ${doc.id}): $e', e);
                    return null;
                  }
                })
                .whereType<Comment>()
                .toList();

            // 클라이언트에서 생성 시간순 정렬 (오래된 것부터)
            comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

            return comments;
          })
          .handleError((error, stackTrace) {
            AppLogger.error('watchComments 스트림 에러: $error', error, stackTrace);
            // 에러 발생 시 빈 리스트 반환
            return <Comment>[];
          });
    } catch (e, stackTrace) {
      AppLogger.error('watchComments 초기화 에러: $e', e, stackTrace);
      // 에러 발생 시 빈 리스트 스트림 반환
      return Stream.value(<Comment>[]);
    }
  }

  @override
  Future<Either<Failure, bool>> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final likeDocId = '${postId}_$userId';
      final likeRef = _firestore.collection('postLikes').doc(likeDocId);
      final postRef = _firestore.collection('posts').doc(postId);

      final result = await _firestore.runTransaction<bool>((transaction) async {
        final likeDoc = await transaction.get(likeRef);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          throw PostNotFoundFailure(message: '게시글을 찾을 수 없습니다');
        }

        final currentLikeCount = postDoc.data()?['likeCount'] as int? ?? 0;

        if (likeDoc.exists) {
          // 좋아요 취소
          transaction.delete(likeRef);
          transaction.update(postRef, {
            'likeCount': currentLikeCount > 0 ? currentLikeCount - 1 : 0,
          });
          AppLogger.community('좋아요 취소: postId=$postId, userId=$userId');
          return false;
        } else {
          // 좋아요 추가
          transaction.set(likeRef, {
            'postId': postId,
            'userId': userId,
            'createdAt': FieldValue.serverTimestamp(),
          });
          transaction.update(postRef, {'likeCount': currentLikeCount + 1});
          AppLogger.community('좋아요 추가: postId=$postId, userId=$userId');
          return true;
        }
      });
      return Right(result);
    } on PostNotFoundFailure catch (e) {
      AppLogger.error('toggleLike 에러: ${e.message}', e);
      return Left(e);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('toggleLike 에러: $e', e, stackTrace);
      return Left(
        FirebaseFailure(message: e.message ?? '좋아요 처리 실패', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('toggleLike 에러: $e', e, stackTrace);
      return Left(LikeToggleFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLiked({
    required String postId,
    required String userId,
  }) async {
    try {
      final likeDocId = '${postId}_$userId';
      final likeDoc = await _firestore
          .collection('postLikes')
          .doc(likeDocId)
          .get();
      return Right(likeDoc.exists);
    } on FirebaseException catch (e) {
      AppLogger.error('isLiked 에러: $e', e);
      return Left(
        FirebaseFailure(message: e.message ?? '좋아요 상태 확인 실패', code: e.code),
      );
    } catch (e) {
      AppLogger.error('isLiked 에러: $e', e);
      return Left(LikeToggleFailure(message: e.toString()));
    }
  }

  @override
  Stream<bool> watchIsLiked({required String postId, required String userId}) {
    final likeDocId = '${postId}_$userId';
    return _firestore
        .collection('postLikes')
        .doc(likeDocId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
