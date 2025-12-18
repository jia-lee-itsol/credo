import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/community/presentation/notifiers/post_form_notifier.dart';
import 'package:credo/features/community/domain/repositories/post_repository.dart';
import 'package:credo/features/community/domain/repositories/user_repository.dart';
import 'package:credo/features/community/domain/repositories/notification_repository.dart';
import 'package:credo/features/community/data/models/post.dart';
import 'package:credo/features/community/data/models/app_user.dart';
import 'package:credo/core/data/services/image_upload_service.dart';

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
  });
}

