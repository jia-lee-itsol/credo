import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/community/data/repositories/firestore_post_repository.dart';
import 'package:credo/features/community/data/models/post.dart';
import 'package:credo/core/error/failures.dart';
import 'package:credo/features/community/domain/failures/community_failures.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

// Note: Firestore의 sealed 클래스는 직접 상속할 수 없으므로
// mocktail의 Mock을 사용하여 인터페이스를 구현합니다.

void main() {
  late FirestorePostRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockPostsCollection;
  late MockCollectionReference mockCommentsCollection;
  late MockCollectionReference mockLikesCollection;
  late MockDocumentReference mockDocumentRef;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockPostsCollection = MockCollectionReference();
    mockCommentsCollection = MockCollectionReference();
    mockLikesCollection = MockCollectionReference();
    mockDocumentRef = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    repository = FirestorePostRepository(firestore: mockFirestore);

    // 기본 설정
    when(() => mockFirestore.collection('posts'))
        .thenReturn(mockPostsCollection);
    when(() => mockFirestore.collection('comments'))
        .thenReturn(mockCommentsCollection);
    when(() => mockFirestore.collection('postLikes'))
        .thenReturn(mockLikesCollection);
    when(() => mockPostsCollection.doc(any())).thenReturn(mockDocumentRef);
    when(() => mockDocumentRef.id).thenReturn('test-post-id');
  });

  group('FirestorePostRepository', () {
    group('createPost', () {
      test('게시글이 성공적으로 생성되어야 함', () async {
        // Arrange
        final now = DateTime.now();
        final post = Post(
          postId: '',
          title: 'Test Post',
          body: 'Test Body',
          authorId: 'test-author-id',
          authorName: 'Test Author',
          parishId: 'test-parish-id',
          createdAt: now,
          updatedAt: now,
          type: 'normal',
          authorIsVerified: false,
        );

        when(() => mockPostsCollection.doc()).thenReturn(mockDocumentRef);
        when(() => mockDocumentRef.set(any(), any()))
            .thenAnswer((_) async => Future.value());
        when(() => mockDocumentRef.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(() => mockDocumentSnapshot.data()).thenReturn({});

        // Act
        final result = await repository.createPost(post);

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (postId) {
            expect(postId, isNotEmpty);
          },
        );
        verify(() => mockDocumentRef.set(any(), any())).called(1);
      });

      test('공식 게시글인데 authorIsVerified가 false면 InsufficientPermissionFailure를 반환해야 함',
          () async {
        // Arrange
        final now = DateTime.now();
        final post = Post(
          postId: '',
          title: 'Official Post',
          body: 'Official Body',
          authorId: 'test-author-id',
          authorName: 'Test Author',
          parishId: 'test-parish-id',
          createdAt: now,
          updatedAt: now,
          type: 'official',
          authorIsVerified: false, // 인증되지 않은 사용자
        );

        // Act
        final result = await repository.createPost(post);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<InsufficientPermissionFailure>());
          },
          (_) => fail('실패가 발생해야 함'),
        );
        verifyNever(() => mockDocumentRef.set(any(), any()));
      });

      test('FirebaseException 발생 시 FirebaseFailure를 반환해야 함', () async {
        // Arrange
        final now = DateTime.now();
        final post = Post(
          postId: '',
          title: 'Test Post',
          body: 'Test Body',
          authorId: 'test-author-id',
          authorName: 'Test Author',
          parishId: 'test-parish-id',
          createdAt: now,
          updatedAt: now,
        );

        final firebaseException = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        );

        when(() => mockPostsCollection.doc()).thenReturn(mockDocumentRef);
        when(() => mockDocumentRef.set(any(), any()))
            .thenThrow(firebaseException);

        // Act
        final result = await repository.createPost(post);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<FirebaseFailure>());
            expect(failure.code, 'permission-denied');
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });

      test('일반 예외 발생 시 PostCreationFailure를 반환해야 함', () async {
        // Arrange
        final now = DateTime.now();
        final post = Post(
          postId: '',
          title: 'Test Post',
          body: 'Test Body',
          authorId: 'test-author-id',
          authorName: 'Test Author',
          parishId: 'test-parish-id',
          createdAt: now,
          updatedAt: now,
        );

        when(() => mockPostsCollection.doc()).thenReturn(mockDocumentRef);
        when(() => mockDocumentRef.set(any(), any()))
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.createPost(post);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<PostCreationFailure>());
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });
    });

    group('updatePost', () {
      test('게시글이 성공적으로 업데이트되어야 함', () async {
        // Arrange
        final now = DateTime.now();
        final post = Post(
          postId: 'test-post-id',
          title: 'Updated Title',
          body: 'Updated Body',
          authorId: 'test-author-id',
          authorName: 'Test Author',
          parishId: 'test-parish-id',
          createdAt: now,
          updatedAt: now,
        );

        when(() => mockDocumentRef.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(() => mockDocumentSnapshot.data()).thenReturn({
          'title': 'Old Title',
          'body': 'Old Body',
        });
        when(() => mockDocumentRef.update(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.updatePost(post);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockDocumentRef.update(any())).called(1);
      });

      test('변경된 필드가 없으면 업데이트를 건너뛰어야 함', () async {
        // Arrange
        final now = DateTime.now();
        final post = Post(
          postId: 'test-post-id',
          title: 'Same Title',
          body: 'Same Body',
          authorId: 'test-author-id',
          authorName: 'Test Author',
          parishId: 'test-parish-id',
          createdAt: now,
          updatedAt: now,
          category: 'community',
          type: 'normal',
          authorRole: 'user',
          authorIsVerified: false,
          status: 'published',
        );

        when(() => mockDocumentRef.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(() => mockDocumentSnapshot.data()).thenReturn({
          'title': 'Same Title',
          'body': 'Same Body',
          'postId': 'test-post-id',
          'authorId': 'test-author-id',
          'authorName': 'Test Author',
          'authorRole': 'user',
          'authorIsVerified': false,
          'category': 'community',
          'type': 'normal',
          'parishId': 'test-parish-id',
          'imageUrls': [],
          'pdfUrls': [],
          'likeCount': 0,
          'commentCount': 0,
          'isPinned': false,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'status': 'published',
        });

        // Act
        final result = await repository.updatePost(post);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verifyNever(() => mockDocumentRef.update(any()));
      });

      test('FirebaseException 발생 시 FirebaseFailure를 반환해야 함', () async {
        // Arrange
        final now = DateTime.now();
        final post = Post(
          postId: 'test-post-id',
          title: 'Updated Title',
          body: 'Updated Body',
          authorId: 'test-author-id',
          authorName: 'Test Author',
          parishId: 'test-parish-id',
          createdAt: now,
          updatedAt: now,
        );

        final firebaseException = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        );

        when(() => mockDocumentRef.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(() => mockDocumentSnapshot.data()).thenReturn({});
        when(() => mockDocumentRef.update(any())).thenThrow(firebaseException);

        // Act
        final result = await repository.updatePost(post);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<FirebaseFailure>());
            expect(failure.code, 'permission-denied');
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });
    });

    group('deletePost', () {
      test('게시글이 성공적으로 삭제되어야 함', () async {
        // Arrange
        const postId = 'test-post-id';

        when(() => mockDocumentRef.delete())
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.deletePost(postId);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockDocumentRef.delete()).called(1);
      });

      test('FirebaseException 발생 시 FirebaseFailure를 반환해야 함', () async {
        // Arrange
        const postId = 'test-post-id';
        final firebaseException = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        );

        when(() => mockDocumentRef.delete()).thenThrow(firebaseException);

        // Act
        final result = await repository.deletePost(postId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<FirebaseFailure>());
            expect(failure.code, 'permission-denied');
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });
    });

    group('getPostById', () {
      test('게시글이 존재할 때 Post를 반환해야 함', () async {
        // Arrange
        const postId = 'test-post-id';
        final now = DateTime.now();
        final postData = {
          'postId': postId,
          'title': 'Test Post',
          'body': 'Test Body',
          'authorId': 'test-author-id',
          'authorName': 'Test Author',
          'parishId': 'test-parish-id',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        };

        when(() => mockDocumentRef.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(() => mockDocumentSnapshot.data()).thenReturn(postData);
        when(() => mockDocumentSnapshot.id).thenReturn(postId);

        // Act
        final result = await repository.getPostById(postId);

        // Assert
        expect(result, isA<Right<Failure, Post?>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (post) {
            expect(post, isNotNull);
            expect(post?.postId, postId);
          },
        );
      });

      test('게시글이 존재하지 않을 때 null을 반환해야 함', () async {
        // Arrange
        const postId = 'non-existent-post-id';

        when(() => mockDocumentRef.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final result = await repository.getPostById(postId);

        // Assert
        expect(result, isA<Right<Failure, Post?>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (post) => expect(post, isNull),
        );
      });

      test('FirebaseException 발생 시 FirebaseFailure를 반환해야 함', () async {
        // Arrange
        const postId = 'test-post-id';
        final firebaseException = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        );

        when(() => mockDocumentRef.get()).thenThrow(firebaseException);

        // Act
        final result = await repository.getPostById(postId);

        // Assert
        expect(result, isA<Left<Failure, Post?>>());
        result.fold(
          (failure) {
            expect(failure, isA<FirebaseFailure>());
            expect(failure.code, 'permission-denied');
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });
    });

    // Note: createComment와 toggleLike는 Transaction을 사용하므로
    // 단위 테스트보다는 통합 테스트에서 검증하는 것이 적절합니다.

    group('isLiked', () {
      test('좋아요가 있으면 true를 반환해야 함', () async {
        // Arrange
        const postId = 'test-post-id';
        const userId = 'test-user-id';

        final mockLikeRef = MockDocumentReference();
        when(() => mockLikesCollection.doc(any())).thenReturn(mockLikeRef);
        when(() => mockLikeRef.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);

        // Act
        final result = await repository.isLiked(
          postId: postId,
          userId: userId,
        );

        // Assert
        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (isLiked) => expect(isLiked, true),
        );
      });

      test('좋아요가 없으면 false를 반환해야 함', () async {
        // Arrange
        const postId = 'test-post-id';
        const userId = 'test-user-id';

        final mockLikeRef = MockDocumentReference();
        when(() => mockLikesCollection.doc(any())).thenReturn(mockLikeRef);
        when(() => mockLikeRef.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final result = await repository.isLiked(
          postId: postId,
          userId: userId,
        );

        // Assert
        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (isLiked) => expect(isLiked, false),
        );
      });
    });

    // Note: searchPosts는 Query를 사용하므로 복잡한 mock이 필요합니다.
    // 통합 테스트에서 검증하는 것이 적절합니다.
  });
}

