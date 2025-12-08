import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/community_repository.dart';

/// 게시글 목록 조회 UseCase
class GetPostsUseCase {
  final CommunityRepository _repository;

  GetPostsUseCase(this._repository);

  Future<Either<Failure, List<PostEntity>>> call({
    required String parishId,
    PostSortType sortType = PostSortType.latest,
    int? limit,
    String? lastPostId,
  }) {
    return _repository.getPosts(
      parishId: parishId,
      sortType: sortType,
      limit: limit,
      lastPostId: lastPostId,
    );
  }
}

/// 게시글 상세 조회 UseCase
class GetPostByIdUseCase {
  final CommunityRepository _repository;

  GetPostByIdUseCase(this._repository);

  Future<Either<Failure, PostEntity>> call(String postId) {
    return _repository.getPostById(postId);
  }
}

/// 게시글 작성 UseCase
class CreatePostUseCase {
  final CommunityRepository _repository;

  CreatePostUseCase(this._repository);

  Future<Either<Failure, PostEntity>> call({
    required String parishId,
    required String title,
    required String content,
  }) {
    return _repository.createPost(
      parishId: parishId,
      title: title,
      content: content,
    );
  }
}

/// 게시글 삭제 UseCase
class DeletePostUseCase {
  final CommunityRepository _repository;

  DeletePostUseCase(this._repository);

  Future<Either<Failure, void>> call(String postId) {
    return _repository.deletePost(postId);
  }
}

/// 게시글 좋아요 토글 UseCase
class ToggleLikePostUseCase {
  final CommunityRepository _repository;

  ToggleLikePostUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String postId,
    required bool isLiked,
  }) {
    if (isLiked) {
      return _repository.unlikePost(postId);
    } else {
      return _repository.likePost(postId);
    }
  }
}

/// 댓글 목록 조회 UseCase
class GetCommentsUseCase {
  final CommunityRepository _repository;

  GetCommentsUseCase(this._repository);

  Future<Either<Failure, List<CommentEntity>>> call({
    required String postId,
    int? limit,
    String? lastCommentId,
  }) {
    return _repository.getComments(
      postId: postId,
      limit: limit,
      lastCommentId: lastCommentId,
    );
  }
}

/// 댓글 작성 UseCase
class CreateCommentUseCase {
  final CommunityRepository _repository;

  CreateCommentUseCase(this._repository);

  Future<Either<Failure, CommentEntity>> call({
    required String postId,
    required String content,
  }) {
    return _repository.createComment(postId: postId, content: content);
  }
}

/// 게시글/댓글 신고 UseCase
class ReportContentUseCase {
  final CommunityRepository _repository;

  ReportContentUseCase(this._repository);

  Future<Either<Failure, void>> callForPost({
    required String postId,
    required ReportReason reason,
    String? description,
  }) {
    return _repository.reportPost(
      postId: postId,
      reason: reason,
      description: description,
    );
  }

  Future<Either<Failure, void>> callForComment({
    required String commentId,
    required ReportReason reason,
    String? description,
  }) {
    return _repository.reportComment(
      commentId: commentId,
      reason: reason,
      description: description,
    );
  }
}
