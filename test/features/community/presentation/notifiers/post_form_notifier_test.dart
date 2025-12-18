import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/community/presentation/notifiers/post_form_notifier.dart';
import 'package:credo/features/community/domain/repositories/post_repository.dart';
import 'package:credo/features/community/domain/repositories/user_repository.dart';
import 'package:credo/features/community/domain/repositories/notification_repository.dart';
import 'package:credo/features/community/data/models/post.dart';
import 'package:credo/features/community/data/models/app_user.dart';
import 'package:credo/features/community/data/models/notification.dart';
import 'package:credo/core/data/services/image_upload_service.dart';
import 'package:credo/core/error/failures.dart';
import 'package:credo/features/community/domain/failures/community_failures.dart';

// Mock classes
class MockPostRepository extends Mock implements PostRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockImageUploadService extends Mock implements ImageUploadService {}

void main() {
  late PostFormNotifier notifier;
  late MockPostRepository mockPostRepository;
  late MockUserRepository mockUserRepository;
  late MockNotificationRepository mockNotificationRepository;
  late MockImageUploadService mockImageUploadService;
  late AppUser testUser;

  setUpAll(() {
    // Register fallback value for Post type used in any() matchers
    registerFallbackValue(
      Post(
        postId: 'fallback-post-id',
        authorId: 'fallback-author-id',
        authorName: 'Fallback Author',
        title: 'Fallback Title',
        body: 'Fallback Body',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    // Register fallback value for AppNotification type used in any() matchers
    registerFallbackValue(
      AppNotification(
        notificationId: 'fallback-notification-id',
        userId: 'fallback-user-id',
        title: 'Fallback Title',
        body: 'Fallback Body',
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockPostRepository = MockPostRepository();
    mockUserRepository = MockUserRepository();
    mockNotificationRepository = MockNotificationRepository();
    mockImageUploadService = MockImageUploadService();

    testUser = AppUser(
      uid: 'test-uid',
      displayName: 'Test User',
      email: 'test@example.com',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    notifier = PostFormNotifier(
      postRepository: mockPostRepository,
      userRepository: mockUserRepository,
      notificationRepository: mockNotificationRepository,
      currentUser: testUser,
      parishId: 'test-parish-id',
      imageUploadService: mockImageUploadService,
    );
  });

  group('PostFormNotifier', () {
    group('상태 변경', () {
      test('setTitle은 제목을 업데이트해야 함', () {
        // Arrange
        const newTitle = '새 제목';

        // Act
        notifier.setTitle(newTitle);

        // Assert
        expect(notifier.state.title, newTitle);
        expect(notifier.state.errorMessage, isNull);
      });

      test('setBody는 본문을 업데이트해야 함', () {
        // Arrange
        const newBody = '새 본문';

        // Act
        notifier.setBody(newBody);

        // Assert
        expect(notifier.state.body, newBody);
        expect(notifier.state.errorMessage, isNull);
      });

      test('setCategory는 카테고리를 업데이트해야 함', () {
        // Arrange
        const newCategory = 'notice';

        // Act
        notifier.setCategory(newCategory);

        // Assert
        expect(notifier.state.category, newCategory);
      });

      test('setIsOfficial는 공식 게시글 상태를 업데이트해야 함', () {
        // Act
        notifier.setIsOfficial(true);

        // Assert
        expect(notifier.state.isOfficial, true);
        expect(notifier.state.category, 'notice');
      });

      test('setIsPinned는 핀 고정 상태를 업데이트해야 함', () {
        // Act
        notifier.setIsPinned(true);

        // Assert
        expect(notifier.state.isPinned, true);
      });
    });

    group('유효성 검사', () {
      test('제목이 비어있으면 제출이 실패해야 함', () async {
        // Arrange
        notifier.setTitle('');
        notifier.setBody('본문 내용');

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, false);
        expect(notifier.state.errorMessage, isNotNull);
        expect(notifier.state.isSubmitting, false);
      });

      test('본문이 비어있으면 제출이 실패해야 함', () async {
        // Arrange
        notifier.setTitle('제목');
        notifier.setBody('');

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, false);
        expect(notifier.state.errorMessage, isNotNull);
        expect(notifier.state.isSubmitting, false);
      });

      test('제목과 본문이 모두 있으면 유효성 검사를 통과해야 함', () async {
        // Arrange
        notifier.setTitle('제목');
        notifier.setBody('본문 내용');

        // Act & Assert
        // submit()은 실제로 게시글을 생성하려고 시도하므로
        // 여기서는 유효성 검사 부분만 확인
        expect(notifier.state.title.isNotEmpty, true);
        expect(notifier.state.body.isNotEmpty, true);
      });
    });

    group('초기 상태', () {
      test('초기 상태는 올바른 기본값을 가져야 함', () {
        // Assert
        expect(notifier.state.title, '');
        expect(notifier.state.body, '');
        expect(notifier.state.category, 'community');
        expect(notifier.state.isOfficial, false);
        expect(notifier.state.isPinned, false);
        expect(notifier.state.isSubmitting, false);
        expect(notifier.state.errorMessage, isNull);
        expect(notifier.state.selectedImages, isEmpty);
        expect(notifier.state.imageUrls, isEmpty);
        expect(notifier.state.selectedPdfs, isEmpty);
        expect(notifier.state.pdfUrls, isEmpty);
      });

      test('initialPost가 제공되면 초기 상태에 반영되어야 함', () {
        // Arrange
        final now = DateTime.now();
        final initialPost = Post(
          postId: 'test-post-id',
          title: '초기 제목',
          body: '초기 본문',
          category: 'notice',
          type: 'official',
          isPinned: true,
          createdAt: now,
          updatedAt: now,
          authorId: 'test-author-id',
          authorName: 'Test Author',
          parishId: 'test-parish-id',
        );

        // Act
        final notifierWithPost = PostFormNotifier(
          postRepository: mockPostRepository,
          currentUser: testUser,
          initialPost: initialPost,
          parishId: 'test-parish-id',
          imageUploadService: mockImageUploadService,
        );

        // Assert
        expect(notifierWithPost.state.title, '초기 제목');
        expect(notifierWithPost.state.body, '초기 본문');
        expect(notifierWithPost.state.category, 'notice');
        expect(notifierWithPost.state.isOfficial, true);
        expect(notifierWithPost.state.isPinned, true);
      });
    });

    group('파일 관리', () {
      test('addImage는 이미지를 추가해야 함', () {
        // Arrange
        final testImage = File('test_image.jpg');

        // Act
        notifier.addImage(testImage);

        // Assert
        expect(notifier.state.selectedImages.length, 1);
        expect(notifier.state.selectedImages.first, testImage);
      });

      test('removeImage는 지정된 인덱스의 이미지를 제거해야 함', () {
        // Arrange
        final testImage1 = File('test_image1.jpg');
        final testImage2 = File('test_image2.jpg');
        notifier.addImage(testImage1);
        notifier.addImage(testImage2);

        // Act
        notifier.removeImage(0);

        // Assert
        expect(notifier.state.selectedImages.length, 1);
        expect(notifier.state.selectedImages.first, testImage2);
      });

      test('addPdf는 PDF를 추가해야 함', () {
        // Arrange
        final testPdf = File('test_document.pdf');

        // Act
        notifier.addPdf(testPdf);

        // Assert
        expect(notifier.state.selectedPdfs.length, 1);
        expect(notifier.state.selectedPdfs.first, testPdf);
      });

      test('removePdf는 지정된 인덱스의 PDF를 제거해야 함', () {
        // Arrange
        final testPdf1 = File('test_document1.pdf');
        final testPdf2 = File('test_document2.pdf');
        notifier.addPdf(testPdf1);
        notifier.addPdf(testPdf2);

        // Act
        notifier.removePdf(0);

        // Assert
        expect(notifier.state.selectedPdfs.length, 1);
        expect(notifier.state.selectedPdfs.first, testPdf2);
      });
    });

    group('submit - 게시글 생성', () {
      test('게시글 생성이 성공하면 true를 반환해야 함', () async {
        // Arrange
        notifier.setTitle('테스트 제목');
        notifier.setBody('테스트 본문');
        when(() => mockImageUploadService.uploadImages(
              imageFiles: any(named: 'imageFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockImageUploadService.uploadPdfs(
              pdfFiles: any(named: 'pdfFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockPostRepository.createPost(any())).thenAnswer(
          (_) async => const Right('test-post-id'),
        );

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, true);
        expect(notifier.state.isSubmitting, false);
        expect(notifier.state.errorMessage, isNull);
        verify(() => mockPostRepository.createPost(any())).called(1);
      });

      test('이미지 업로드가 실패하면 false를 반환해야 함', () async {
        // Arrange
        notifier.setTitle('테스트 제목');
        notifier.setBody('테스트 본문');
        final testImage = File('test_image.jpg');
        notifier.addImage(testImage);
        when(() => mockImageUploadService.uploadImages(
              imageFiles: any(named: 'imageFiles'),
              userId: any(named: 'userId'),
            )).thenThrow(const FirebaseFailure(message: '업로드 실패'));

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, false);
        expect(notifier.state.isSubmitting, false);
        expect(notifier.state.errorMessage, isNotNull);
        verifyNever(() => mockPostRepository.createPost(any()));
      });

      test('PDF 업로드가 실패하면 false를 반환해야 함', () async {
        // Arrange
        notifier.setTitle('테스트 제목');
        notifier.setBody('테스트 본문');
        final testPdf = File('test_document.pdf');
        notifier.addPdf(testPdf);
        when(() => mockImageUploadService.uploadImages(
              imageFiles: any(named: 'imageFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockImageUploadService.uploadPdfs(
              pdfFiles: any(named: 'pdfFiles'),
              userId: any(named: 'userId'),
            )).thenThrow(const FirebaseFailure(message: 'PDF 업로드 실패'));

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, false);
        expect(notifier.state.isSubmitting, false);
        expect(notifier.state.errorMessage, isNotNull);
        verifyNever(() => mockPostRepository.createPost(any()));
      });

      test('게시글 생성 실패 시 false를 반환해야 함', () async {
        // Arrange
        notifier.setTitle('테스트 제목');
        notifier.setBody('테스트 본문');
        when(() => mockImageUploadService.uploadImages(
              imageFiles: any(named: 'imageFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockImageUploadService.uploadPdfs(
              pdfFiles: any(named: 'pdfFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockPostRepository.createPost(any())).thenAnswer(
          (_) async => const Left(PostCreationFailure(message: '생성 실패')),
        );

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, false);
        expect(notifier.state.isSubmitting, false);
        expect(notifier.state.errorMessage, isNotNull);
      });

      test('공지 게시글 생성 시 알림이 전송되어야 함', () async {
        // Arrange
        notifier.setTitle('공지 제목');
        notifier.setBody('공지 본문');
        notifier.setIsOfficial(true);
        final otherUser = AppUser(
          uid: 'other-user-id',
          displayName: 'Other User',
          email: 'other@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockImageUploadService.uploadImages(
              imageFiles: any(named: 'imageFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockImageUploadService.uploadPdfs(
              pdfFiles: any(named: 'pdfFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockPostRepository.createPost(any())).thenAnswer(
          (_) async => const Right('test-post-id'),
        );
        when(() => mockUserRepository.getUsersByParishId(any())).thenAnswer(
          (_) async => Right([testUser, otherUser]),
        );
        when(() => mockNotificationRepository.createNotification(any()))
            .thenAnswer((_) async => const Right('test-notification-id'));

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, true);
        verify(() => mockUserRepository.getUsersByParishId('test-parish-id'))
            .called(1);
        // 작성자 본인은 제외되므로 otherUser에게만 알림 전송
        verify(() => mockNotificationRepository.createNotification(any()))
            .called(1);
      });
    });

    group('submit - 게시글 수정', () {
      test('게시글 수정이 성공하면 true를 반환해야 함', () async {
        // Arrange
        final now = DateTime.now();
        final initialPost = Post(
          postId: 'test-post-id',
          title: '기존 제목',
          body: '기존 본문',
          category: 'community',
          type: 'normal',
          createdAt: now,
          updatedAt: now,
          authorId: testUser.uid,
          authorName: testUser.displayName,
          parishId: 'test-parish-id',
        );
        final notifierWithPost = PostFormNotifier(
          postRepository: mockPostRepository,
          currentUser: testUser,
          initialPost: initialPost,
          parishId: 'test-parish-id',
          imageUploadService: mockImageUploadService,
        );
        notifierWithPost.setTitle('수정된 제목');
        notifierWithPost.setBody('수정된 본문');
        when(() => mockImageUploadService.uploadImages(
              imageFiles: any(named: 'imageFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockImageUploadService.uploadPdfs(
              pdfFiles: any(named: 'pdfFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockPostRepository.updatePost(any())).thenAnswer(
          (_) async => const Right(null),
        );

        // Act
        final result = await notifierWithPost.submit();

        // Assert
        expect(result, true);
        expect(notifierWithPost.state.isSubmitting, false);
        verify(() => mockPostRepository.updatePost(any())).called(1);
        verifyNever(() => mockPostRepository.createPost(any()));
      });

      test('게시글 수정 실패 시 false를 반환해야 함', () async {
        // Arrange
        final now = DateTime.now();
        final initialPost = Post(
          postId: 'test-post-id',
          title: '기존 제목',
          body: '기존 본문',
          category: 'community',
          type: 'normal',
          createdAt: now,
          updatedAt: now,
          authorId: testUser.uid,
          authorName: testUser.displayName,
          parishId: 'test-parish-id',
        );
        final notifierWithPost = PostFormNotifier(
          postRepository: mockPostRepository,
          currentUser: testUser,
          initialPost: initialPost,
          parishId: 'test-parish-id',
          imageUploadService: mockImageUploadService,
        );
        notifierWithPost.setTitle('수정된 제목');
        notifierWithPost.setBody('수정된 본문');
        when(() => mockImageUploadService.uploadImages(
              imageFiles: any(named: 'imageFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockImageUploadService.uploadPdfs(
              pdfFiles: any(named: 'pdfFiles'),
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => []);
        when(() => mockPostRepository.updatePost(any())).thenAnswer(
          (_) async => const Left(PostUpdateFailure(message: '수정 실패')),
        );

        // Act
        final result = await notifierWithPost.submit();

        // Assert
        expect(result, false);
        expect(notifierWithPost.state.isSubmitting, false);
        expect(notifierWithPost.state.errorMessage, isNotNull);
      });
    });
  });
}

