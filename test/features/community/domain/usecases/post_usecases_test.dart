import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/community/domain/usecases/post_usecases.dart';
import 'package:credo/features/community/domain/repositories/community_repository.dart';
import 'package:credo/features/community/domain/entities/post_entity.dart';
import 'package:credo/core/error/failures.dart';

// Mock classes
class MockCommunityRepository extends Mock implements CommunityRepository {}

void main() {
  late MockCommunityRepository mockRepository;

  setUpAll(() {
    // Register fallback values for enum types used in any() matchers
    registerFallbackValue(PostSortType.latest);
    registerFallbackValue(ReportReason.spam);
  });

  setUp(() {
    mockRepository = MockCommunityRepository();
  });

  group('GetPostsUseCase', () {
    test('게시글 목록 조회가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = GetPostsUseCase(mockRepository);
      final testPosts = [
        PostEntity(
          postId: 'post1',
          userId: 'user1',
          title: 'Test Post 1',
          content: 'Content 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        PostEntity(
          postId: 'post2',
          userId: 'user2',
          title: 'Test Post 2',
          content: 'Content 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(
        () => mockRepository.getPosts(
          parishId: any(named: 'parishId'),
          sortType: any(named: 'sortType'),
          limit: any(named: 'limit'),
          lastPostId: any(named: 'lastPostId'),
        ),
      ).thenAnswer((_) async => Right(testPosts));

      // Act
      final result = await useCase.call(
        parishId: 'parish1',
        sortType: PostSortType.latest,
      );

      // Assert
      expect(result, isA<Right<Failure, List<PostEntity>>>());
      result.fold((failure) => fail('실패가 발생하지 않아야 함'), (posts) {
        expect(posts, testPosts);
        expect(posts.length, 2);
      });
      verify(
        () => mockRepository.getPosts(
          parishId: 'parish1',
          sortType: PostSortType.latest,
          limit: null,
          lastPostId: null,
        ),
      ).called(1);
    });

    test('게시글 목록 조회 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = GetPostsUseCase(mockRepository);
      final failure = ServerFailure(message: 'Server error');

      when(
        () => mockRepository.getPosts(
          parishId: any(named: 'parishId'),
          sortType: any(named: 'sortType'),
          limit: any(named: 'limit'),
          lastPostId: any(named: 'lastPostId'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call(parishId: 'parish1');

      // Assert
      expect(result, isA<Left<Failure, List<PostEntity>>>());
      result.fold((f) => expect(f, failure), (value) => fail('실패가 발생해야 함'));
    });
  });

  group('GetPostByIdUseCase', () {
    test('게시글 상세 조회가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = GetPostByIdUseCase(mockRepository);
      final testPost = PostEntity(
        postId: 'post1',
        userId: 'user1',
        title: 'Test Post',
        content: 'Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        () => mockRepository.getPostById(any()),
      ).thenAnswer((_) async => Right(testPost));

      // Act
      final result = await useCase.call('post1');

      // Assert
      expect(result, isA<Right<Failure, PostEntity>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (post) => expect(post, testPost),
      );
      verify(() => mockRepository.getPostById('post1')).called(1);
    });

    test('게시글 상세 조회 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = GetPostByIdUseCase(mockRepository);
      final failure = NotFoundFailure(message: 'Post not found');

      when(
        () => mockRepository.getPostById(any()),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call('post1');

      // Assert
      expect(result, isA<Left<Failure, PostEntity>>());
      result.fold((f) => expect(f, failure), (value) => fail('실패가 발생해야 함'));
    });
  });

  group('CreatePostUseCase', () {
    test('게시글 작성이 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = CreatePostUseCase(mockRepository);
      final testPost = PostEntity(
        postId: 'post1',
        userId: 'user1',
        title: 'New Post',
        content: 'New Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        () => mockRepository.createPost(
          parishId: any(named: 'parishId'),
          title: any(named: 'title'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => Right(testPost));

      // Act
      final result = await useCase.call(
        parishId: 'parish1',
        title: 'New Post',
        content: 'New Content',
      );

      // Assert
      expect(result, isA<Right<Failure, PostEntity>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (post) => expect(post, testPost),
      );
      verify(
        () => mockRepository.createPost(
          parishId: 'parish1',
          title: 'New Post',
          content: 'New Content',
        ),
      ).called(1);
    });

    test('게시글 작성 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = CreatePostUseCase(mockRepository);
      final failure = ValidationFailure(message: 'Invalid data');

      when(
        () => mockRepository.createPost(
          parishId: any(named: 'parishId'),
          title: any(named: 'title'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call(
        parishId: 'parish1',
        title: 'New Post',
        content: 'New Content',
      );

      // Assert
      expect(result, isA<Left<Failure, PostEntity>>());
      result.fold((f) => expect(f, failure), (value) => fail('실패가 발생해야 함'));
    });
  });

  group('DeletePostUseCase', () {
    test('게시글 삭제가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = DeletePostUseCase(mockRepository);

      when(
        () => mockRepository.deletePost(any()),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call('post1');

      // Assert
      expect(result, isA<Right<Failure, void>>());
      result.fold((failure) => fail('실패가 발생하지 않아야 함'), (_) {});
      verify(() => mockRepository.deletePost('post1')).called(1);
    });

    test('게시글 삭제 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = DeletePostUseCase(mockRepository);
      final failure = PermissionFailure(message: 'Not authorized');

      when(
        () => mockRepository.deletePost(any()),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call('post1');

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold((f) => expect(f, failure), (value) => fail('실패가 발생해야 함'));
    });
  });

  group('ToggleLikePostUseCase', () {
    test('좋아요가 없을 때 좋아요를 추가해야 함', () async {
      // Arrange
      final useCase = ToggleLikePostUseCase(mockRepository);

      when(
        () => mockRepository.likePost(any()),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(postId: 'post1', isLiked: false);

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRepository.likePost('post1')).called(1);
      verifyNever(() => mockRepository.unlikePost(any()));
    });

    test('좋아요가 있을 때 좋아요를 취소해야 함', () async {
      // Arrange
      final useCase = ToggleLikePostUseCase(mockRepository);

      when(
        () => mockRepository.unlikePost(any()),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(postId: 'post1', isLiked: true);

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRepository.unlikePost('post1')).called(1);
      verifyNever(() => mockRepository.likePost(any()));
    });
  });

  group('GetCommentsUseCase', () {
    test('댓글 목록 조회가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = GetCommentsUseCase(mockRepository);
      final testComments = [
        CommentEntity(
          commentId: 'comment1',
          postId: 'post1',
          userId: 'user1',
          content: 'Comment 1',
          createdAt: DateTime.now(),
        ),
        CommentEntity(
          commentId: 'comment2',
          postId: 'post1',
          userId: 'user2',
          content: 'Comment 2',
          createdAt: DateTime.now(),
        ),
      ];

      when(
        () => mockRepository.getComments(
          postId: any(named: 'postId'),
          limit: any(named: 'limit'),
          lastCommentId: any(named: 'lastCommentId'),
        ),
      ).thenAnswer((_) async => Right(testComments));

      // Act
      final result = await useCase.call(postId: 'post1');

      // Assert
      expect(result, isA<Right<Failure, List<CommentEntity>>>());
      result.fold((failure) => fail('실패가 발생하지 않아야 함'), (comments) {
        expect(comments, testComments);
        expect(comments.length, 2);
      });
      verify(
        () => mockRepository.getComments(
          postId: 'post1',
          limit: null,
          lastCommentId: null,
        ),
      ).called(1);
    });
  });

  group('CreateCommentUseCase', () {
    test('댓글 작성이 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = CreateCommentUseCase(mockRepository);
      final testComment = CommentEntity(
        commentId: 'comment1',
        postId: 'post1',
        userId: 'user1',
        content: 'New Comment',
        createdAt: DateTime.now(),
      );

      when(
        () => mockRepository.createComment(
          postId: any(named: 'postId'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => Right(testComment));

      // Act
      final result = await useCase.call(
        postId: 'post1',
        content: 'New Comment',
      );

      // Assert
      expect(result, isA<Right<Failure, CommentEntity>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (comment) => expect(comment, testComment),
      );
      verify(
        () => mockRepository.createComment(
          postId: 'post1',
          content: 'New Comment',
        ),
      ).called(1);
    });
  });

  group('ReportContentUseCase', () {
    test('게시글 신고가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = ReportContentUseCase(mockRepository);

      when(
        () => mockRepository.reportPost(
          postId: any(named: 'postId'),
          reason: any(named: 'reason'),
          description: any(named: 'description'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.callForPost(
        postId: 'post1',
        reason: ReportReason.spam,
        description: 'Spam content',
      );

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(
        () => mockRepository.reportPost(
          postId: 'post1',
          reason: ReportReason.spam,
          description: 'Spam content',
        ),
      ).called(1);
    });

    test('댓글 신고가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = ReportContentUseCase(mockRepository);

      when(
        () => mockRepository.reportComment(
          commentId: any(named: 'commentId'),
          reason: any(named: 'reason'),
          description: any(named: 'description'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.callForComment(
        commentId: 'comment1',
        reason: ReportReason.harassment,
        description: 'Harassment',
      );

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(
        () => mockRepository.reportComment(
          commentId: 'comment1',
          reason: ReportReason.harassment,
          description: 'Harassment',
        ),
      ).called(1);
    });
  });
}
