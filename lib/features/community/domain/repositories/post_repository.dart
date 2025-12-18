import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/comment.dart';
import '../../data/models/post.dart';

/// 게시글 Repository 인터페이스
abstract class PostRepository {
  /// 게시글 생성 (postId 반환)
  ///
  /// 공식 게시글(type == "official")인 경우 authorIsVerified가 true여야 함
  /// 그렇지 않으면 InsufficientPermissionFailure 반환
  Future<Either<Failure, String>> createPost(Post post);

  /// 게시글 업데이트
  Future<Either<Failure, void>> updatePost(Post post);

  /// 게시글 삭제
  Future<Either<Failure, void>> deletePost(String postId);

  /// 공식 공지사항 스트림 조회
  ///
  /// 필터 조건:
  /// - category == "notice"
  /// - type == "official"
  /// - status == "published"
  /// - parishId가 제공된 경우 parishId로 추가 필터링
  Stream<List<Post>> watchOfficialNotices({String? parishId});

  /// 여러 교회의 공식 공지사항 스트림 조회
  ///
  /// 필터 조건:
  /// - category == "notice"
  /// - type == "official"
  /// - status == "published"
  /// - parishIds에 포함된 교회의 공지사항만 조회
  Stream<List<Post>> watchOfficialNoticesByParishes({
    required List<String> parishIds,
  });

  /// 커뮤니티 게시글 스트림 조회
  ///
  /// 필터 조건:
  /// - category == "community"
  /// - type == "normal"
  /// - status == "published"
  /// - parishId가 제공된 경우 parishId로 추가 필터링
  Stream<List<Post>> watchCommunityPosts({String? parishId});

  /// 모든 게시글 스트림 조회 (공지 + 커뮤니티)
  ///
  /// 필터 조건:
  /// - status == "published"
  /// - parishId가 제공된 경우 parishId로 추가 필터링
  Stream<List<Post>> watchAllPosts({String? parishId});

  /// 여러 교회의 모든 게시글 스트림 조회 (공지 + 커뮤니티)
  ///
  /// 필터 조건:
  /// - status == "published"
  /// - parishIds에 포함된 교회의 게시글만 조회
  Stream<List<Post>> watchAllPostsByParishes({required List<String> parishIds});

  /// 게시글 ID로 조회
  Future<Either<Failure, Post?>> getPostById(String postId);

  /// 댓글 생성
  Future<Either<Failure, String>> createComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    List<String> imageUrls = const [],
    List<String> pdfUrls = const [],
  });

  /// 게시글의 댓글 목록 조회 (스트림)
  Stream<List<Comment>> watchComments(String postId);

  /// 좋아요 토글 (좋아요 상태이면 취소, 아니면 좋아요)
  /// 반환값: 좋아요 후 상태 (true: 좋아요, false: 취소)
  Future<Either<Failure, bool>> toggleLike({
    required String postId,
    required String userId,
  });

  /// 사용자가 좋아요 했는지 확인
  Future<Either<Failure, bool>> isLiked({
    required String postId,
    required String userId,
  });

  /// 좋아요 상태 스트림 (실시간)
  Stream<bool> watchIsLiked({required String postId, required String userId});

  /// 게시글 검색
  ///
  /// [query] 검색어 (제목, 내용에서 검색)
  /// [parishId] 특정 성당으로 필터링 (선택사항)
  /// [category] 카테고리 필터링 (선택사항: "notice", "community")
  /// [type] 타입 필터링 (선택사항: "official", "normal")
  Future<Either<Failure, List<Post>>> searchPosts({
    required String query,
    String? parishId,
    String? category,
    String? type,
  });
}
