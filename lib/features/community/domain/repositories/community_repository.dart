import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';

/// 커뮤니티 Repository 인터페이스
abstract class CommunityRepository {
  /// 게시글 목록 조회
  Future<Either<Failure, List<PostEntity>>> getPosts({
    required String parishId,
    PostSortType sortType = PostSortType.latest,
    int? limit,
    String? lastPostId,
  });

  /// 게시글 상세 조회
  Future<Either<Failure, PostEntity>> getPostById(String postId);

  /// 게시글 작성
  Future<Either<Failure, PostEntity>> createPost({
    required String parishId,
    required String title,
    required String content,
  });

  /// 게시글 수정
  Future<Either<Failure, PostEntity>> updatePost({
    required String postId,
    String? title,
    String? content,
  });

  /// 게시글 삭제
  Future<Either<Failure, void>> deletePost(String postId);

  /// 게시글 좋아요
  Future<Either<Failure, void>> likePost(String postId);

  /// 게시글 좋아요 취소
  Future<Either<Failure, void>> unlikePost(String postId);

  /// 댓글 목록 조회
  Future<Either<Failure, List<CommentEntity>>> getComments({
    required String postId,
    int? limit,
    String? lastCommentId,
  });

  /// 댓글 작성
  Future<Either<Failure, CommentEntity>> createComment({
    required String postId,
    required String content,
  });

  /// 댓글 수정
  Future<Either<Failure, void>> updateComment({
    required String commentId,
    required String content,
    List<String>? imageUrls,
    List<String>? pdfUrls,
  });

  /// 댓글 삭제
  Future<Either<Failure, void>> deleteComment(String commentId);

  /// 게시글 신고
  Future<Either<Failure, void>> reportPost({
    required String postId,
    required ReportReason reason,
    String? description,
  });

  /// 댓글 신고
  Future<Either<Failure, void>> reportComment({
    required String commentId,
    required ReportReason reason,
    String? description,
  });

  /// 공식 게시글 고정
  Future<Either<Failure, void>> pinPost(String postId);

  /// 공식 게시글 고정 해제
  Future<Either<Failure, void>> unpinPost(String postId);
}

/// 게시글 정렬 유형
enum PostSortType {
  latest, // 최신순
  popular, // 인기순
}
