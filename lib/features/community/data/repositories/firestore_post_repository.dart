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
      AppLogger.community('===== updatePost() 호출됨 =====');
      AppLogger.community('게시글 ID: ${post.postId}');
      AppLogger.community('업데이트할 필드:');

      // 현재 문서 가져오기 (diff를 위해)
      final currentDoc = await _firestore
          .collection('posts')
          .doc(post.postId)
          .get();
      final currentData = currentDoc.data() ?? <String, dynamic>{};

      AppLogger.community('현재 문서 데이터 키: ${currentData.keys.toList()}');

      final postData = post.toFirestore();
      AppLogger.community('업데이트할 데이터 키: ${postData.keys.toList()}');

      // 변경된 필드만 추출
      final changedFields = <String, dynamic>{};
      postData.forEach((key, value) {
        final currentValue = currentData[key];

        // 리스트 비교: 내용이 같으면 변경되지 않은 것으로 처리
        if (value is List && currentValue is List) {
          if (!_listEquals(value, currentValue)) {
            changedFields[key] = value;
            AppLogger.community(
              '변경된 필드 (리스트): $key = $value (이전: $currentValue)',
            );
          }
          return;
        }

        // 기존 문서에 없는 필드는 기본값과 비교
        // commentCount가 null이고 새 값이 0이면 변경되지 않은 것으로 처리
        if (!currentData.containsKey(key)) {
          // 기본값과 같으면 무시
          if ((key == 'commentCount' && value == 0) ||
              (key == 'likeCount' && value == 0) ||
              (key == 'isPinned' && value == false) ||
              (key == 'status' && value == 'published') ||
              (key == 'imageUrls' && value is List && value.isEmpty)) {
            return;
          }
          changedFields[key] = value;
          AppLogger.community('변경된 필드 (새 필드): $key = $value');
          return;
        }

        // 일반 값 비교
        if (currentValue != value) {
          changedFields[key] = value;
          AppLogger.community('변경된 필드: $key = $value (이전: $currentValue)');
        }
      });

      AppLogger.community('실제 변경된 필드: ${changedFields.keys.toList()}');
      AppLogger.community('변경된 필드 개수: ${changedFields.length}');

      if (changedFields.isEmpty) {
        AppLogger.community('⚠️ 변경된 필드가 없습니다. 업데이트를 건너뜁니다.');
        return const Right(null);
      }

      // 변경된 필드 상세 로그
      changedFields.forEach((key, value) {
        if (value is Timestamp) {
          AppLogger.community('  변경: $key = ${value.toDate()} (Timestamp)');
        } else {
          AppLogger.community('  변경: $key = $value (${value.runtimeType})');
        }
      });

      AppLogger.community('Firestore 업데이트 시작: posts/${post.postId}');
      AppLogger.community('업데이트할 필드: ${changedFields.keys.join(", ")}');
      AppLogger.community(
        'Rules 체크: affectedKeys()는 ${changedFields.keys.toList()}를 반환해야 함',
      );

      // 변경된 필드만 업데이트
      await _firestore
          .collection('posts')
          .doc(post.postId)
          .update(changedFields);

      AppLogger.community('✅ Firestore 업데이트 성공!');
      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error(
        '===== 게시글 업데이트 실패 (FirebaseException) =====',
        e,
        stackTrace,
      );
      AppLogger.error('에러 코드: ${e.code}');
      AppLogger.error('에러 메시지: ${e.message}');
      AppLogger.error('스택 트레이스: $stackTrace');
      return Left(
        FirebaseFailure(message: e.message ?? '게시글 업데이트 실패', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('===== 게시글 업데이트 실패 (일반 예외) =====', e, stackTrace);
      AppLogger.error('에러 타입: ${e.runtimeType}');
      AppLogger.error('에러 메시지: $e');
      AppLogger.error('스택 트레이스: $stackTrace');
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
  Stream<List<Post>> watchOfficialNoticesByParishes({
    required List<String> parishIds,
  }) {
    try {
      if (parishIds.isEmpty) {
        return Stream.value(<Post>[]);
      }

      // Firestore의 whereIn은 최대 10개까지만 지원
      // 10개를 초과하면 여러 번 쿼리해야 함
      if (parishIds.length <= 10) {
        // 공식 공지사항 쿼리: category == "notice", type == "official", status == "published"
        Query query = _firestore
            .collection('posts')
            .where('category', isEqualTo: 'notice')
            .where('type', isEqualTo: 'official')
            .where('status', isEqualTo: 'published')
            .where('parishId', whereIn: parishIds);

        // 최신순 정렬
        query = query.orderBy('createdAt', descending: true);

        AppLogger.community(
          'watchOfficialNoticesByParishes 쿼리 실행: parishIds=$parishIds',
        );

        var isFirstEmission = true;

        return query
            .snapshots()
            .map((snapshot) {
              if (isFirstEmission) {
                AppLogger.community(
                  'watchOfficialNoticesByParishes 결과: ${snapshot.docs.length}개 문서',
                );
                isFirstEmission = false;
              }
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
                'watchOfficialNoticesByParishes 스트림 에러: $error',
                error,
                stackTrace,
              );
              throw error;
            });
      } else {
        // 10개를 초과하면 처음 10개만 사용 (실제로는 10개 이상의 교회를 설정하는 경우가 드뭄)
        AppLogger.warning(
          'watchOfficialNoticesByParishes: 10개를 초과하는 교회는 처음 10개만 조회합니다.',
        );
        final limitedParishIds = parishIds.take(10).toList();
        Query query = _firestore
            .collection('posts')
            .where('category', isEqualTo: 'notice')
            .where('type', isEqualTo: 'official')
            .where('status', isEqualTo: 'published')
            .where('parishId', whereIn: limitedParishIds);

        query = query.orderBy('createdAt', descending: true);

        AppLogger.community(
          'watchOfficialNoticesByParishes 쿼리 실행: parishIds=$limitedParishIds',
        );

        var isFirstEmission = true;

        return query
            .snapshots()
            .map((snapshot) {
              if (isFirstEmission) {
                AppLogger.community(
                  'watchOfficialNoticesByParishes 결과: ${snapshot.docs.length}개 문서',
                );
                isFirstEmission = false;
              }
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
                'watchOfficialNoticesByParishes 스트림 에러: $error',
                error,
                stackTrace,
              );
              throw error;
            });
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'watchOfficialNoticesByParishes 초기화 에러: $e',
        e,
        stackTrace,
      );
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

            // 인덱스 에러인 경우 더 자세한 정보 제공
            if (error is FirebaseException &&
                error.code == 'failed-precondition' &&
                error.message?.contains('index') == true) {
              AppLogger.error(
                '⚠️ Firestore 인덱스가 필요합니다. 다음 명령어로 인덱스를 배포하세요:',
                error,
                stackTrace,
              );
              AppLogger.error('firebase deploy --only firestore:indexes');
              AppLogger.error('또는 에러 메시지의 URL을 통해 수동으로 인덱스를 생성할 수 있습니다.');
            }

            throw error;
          });
    } catch (e, stackTrace) {
      AppLogger.error('watchAllPosts 초기화 에러: $e', e, stackTrace);
      // 에러 발생 시 빈 리스트 스트림 반환
      return Stream.value(<Post>[]);
    }
  }

  @override
  Stream<List<Post>> watchAllPostsByParishes({
    required List<String> parishIds,
  }) {
    try {
      if (parishIds.isEmpty) {
        return Stream.value(<Post>[]);
      }

      // Firestore의 whereIn은 최대 10개까지만 지원
      if (parishIds.length <= 10) {
        // 모든 게시글 쿼리: status == "published"
        Query query = _firestore
            .collection('posts')
            .where('status', isEqualTo: 'published')
            .where('parishId', whereIn: parishIds);

        query = query.orderBy('createdAt', descending: true);

        AppLogger.community(
          'watchAllPostsByParishes 쿼리 실행: parishIds=$parishIds',
        );

        var isFirstEmission = true;

        return query
            .snapshots()
            .map((snapshot) {
              if (isFirstEmission) {
                AppLogger.community(
                  'watchAllPostsByParishes 결과: ${snapshot.docs.length}개 문서',
                );
                isFirstEmission = false;
              }
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
                'watchAllPostsByParishes 스트림 에러: $error',
                error,
                stackTrace,
              );
              throw error;
            });
      } else {
        // 10개를 초과하면 처음 10개만 사용
        AppLogger.warning(
          'watchAllPostsByParishes: 10개를 초과하는 교회는 처음 10개만 조회합니다.',
        );
        final limitedParishIds = parishIds.take(10).toList();
        Query query = _firestore
            .collection('posts')
            .where('status', isEqualTo: 'published')
            .where('parishId', whereIn: limitedParishIds);

        query = query.orderBy('createdAt', descending: true);

        AppLogger.community(
          'watchAllPostsByParishes 쿼리 실행: parishIds=$limitedParishIds',
        );

        var isFirstEmission = true;

        return query
            .snapshots()
            .map((snapshot) {
              if (isFirstEmission) {
                AppLogger.community(
                  'watchAllPostsByParishes 결과: ${snapshot.docs.length}개 문서',
                );
                isFirstEmission = false;
              }
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
                'watchAllPostsByParishes 스트림 에러: $error',
                error,
                stackTrace,
              );
              throw error;
            });
      }
    } catch (e, stackTrace) {
      AppLogger.error('watchAllPostsByParishes 초기화 에러: $e', e, stackTrace);
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
    List<String> imageUrls = const [],
    List<String> pdfUrls = const [],
  }) async {
    try {
      AppLogger.community('댓글 생성: postId=$postId, authorId=$authorId');

      // Firestore transaction을 사용하여 댓글 생성과 게시글 commentCount 업데이트를 원자적으로 처리
      // 중요: 트랜잭션에서는 모든 읽기(get)를 먼저 수행한 후 쓰기(set/update)를 해야 함
      final commentId = await _firestore.runTransaction<String>((
        transaction,
      ) async {
        // 1. 먼저 읽기 수행: 게시글 문서 조회
        final postRef = _firestore.collection('posts').doc(postId);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          throw Exception('게시글을 찾을 수 없습니다: $postId');
        }

        final currentCount = (postDoc.data()?['commentCount'] as int?) ?? 0;

        // 2. 그 다음 쓰기 수행: 댓글 문서 생성
        final commentRef = _firestore.collection('comments').doc();
        final comment = Comment(
          commentId: commentRef.id,
          postId: postId,
          authorId: authorId,
          authorName: authorName,
          content: content,
          imageUrls: imageUrls,
          pdfUrls: pdfUrls,
          createdAt: DateTime.now(),
        );
        transaction.set(commentRef, comment.toFirestore());

        // 3. 게시글 문서의 commentCount 증가
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

  /// 두 리스트의 내용이 같은지 비교
  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Future<Either<Failure, List<Post>>> searchPosts({
    required String query,
    String? parishId,
    String? category,
    String? type,
  }) async {
    try {
      AppLogger.community('===== searchPosts() 호출됨 =====');
      AppLogger.community('검색어: $query');
      AppLogger.community('parishId: $parishId');
      AppLogger.community('category: $category');
      AppLogger.community('type: $type');

      // 기본 쿼리: status == "published"
      Query firestoreQuery = _firestore
          .collection('posts')
          .where('status', isEqualTo: 'published');

      // parishId 필터링
      if (parishId != null && parishId.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('parishId', isEqualTo: parishId);
      }

      // category 필터링
      if (category != null && category.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category);
      }

      // type 필터링
      if (type != null && type.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('type', isEqualTo: type);
      }

      // 최신순 정렬
      firestoreQuery = firestoreQuery.orderBy('createdAt', descending: true);

      AppLogger.community('Firestore 쿼리 실행 중...');

      // 쿼리 실행
      final snapshot = await firestoreQuery.get();

      AppLogger.community('쿼리 결과: ${snapshot.docs.length}개 문서');

      // Post로 변환
      final allPosts = snapshot.docs
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

      // 클라이언트 사이드에서 검색어로 필터링
      final queryLower = query.toLowerCase().trim();
      final filteredPosts = allPosts.where((post) {
        final title = post.title.toLowerCase();
        final body = post.body.toLowerCase();
        final authorName = post.authorName.toLowerCase();

        // 제목, 내용, 작성자 이름에서 검색
        return title.contains(queryLower) ||
            body.contains(queryLower) ||
            authorName.contains(queryLower);
      }).toList();

      AppLogger.community('검색 결과: ${filteredPosts.length}개 게시글');

      // 핀 고정된 게시글을 상단에 표시
      final sortedPosts = filteredPosts.sortByPinnedAndDate();

      return Right(sortedPosts);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('게시글 검색 실패: ${e.message}', e, stackTrace);
      return Left(
        FirebaseFailure(message: e.message ?? '게시글 검색 실패', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('게시글 검색 예외 발생: $e', e, stackTrace);
      return Left(ServerFailure(message: '게시글 검색 중 오류가 발생했습니다: $e'));
    }
  }
}
