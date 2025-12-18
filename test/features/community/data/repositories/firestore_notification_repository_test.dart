import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/community/data/repositories/firestore_notification_repository.dart';
import 'package:credo/features/community/data/models/notification.dart';
import 'package:credo/core/error/failures.dart';
import 'package:credo/features/community/domain/failures/community_failures.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// Note: Firestore의 sealed 클래스는 직접 상속할 수 없으므로
// mocktail의 Mock을 사용하여 인터페이스를 구현합니다.

void main() {
  late FirestoreNotificationRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocumentRef;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocumentRef = MockDocumentReference();
    repository = FirestoreNotificationRepository(firestore: mockFirestore);

    // 기본 설정
    when(() => mockFirestore.collection('notifications'))
        .thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocumentRef);
  });

  group('FirestoreNotificationRepository', () {
    group('createNotification', () {
      test('알림 생성이 성공하면 notificationId를 반환해야 함', () async {
        // Arrange
        const notificationId = 'test-notification-id';
        final notification = AppNotification(
          notificationId: '',
          userId: 'test-user-id',
          type: 'notice',
          title: 'Test Title',
          body: 'Test Body',
          isRead: false,
          createdAt: DateTime.now(),
        );

        when(() => mockCollection.doc()).thenReturn(mockDocumentRef);
        when(() => mockDocumentRef.id).thenReturn(notificationId);
        when(() => mockDocumentRef.set(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.createNotification(notification);

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (id) => expect(id, notificationId),
        );
        verify(() => mockDocumentRef.set(any())).called(1);
      });

      test('FirebaseException 발생 시 FirebaseFailure를 반환해야 함', () async {
        // Arrange
        final notification = AppNotification(
          notificationId: '',
          userId: 'test-user-id',
          type: 'notice',
          title: 'Test Title',
          body: 'Test Body',
          isRead: false,
          createdAt: DateTime.now(),
        );
        final firebaseException = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        );

        when(() => mockCollection.doc()).thenReturn(mockDocumentRef);
        when(() => mockDocumentRef.id).thenReturn('test-id');
        when(() => mockDocumentRef.set(any())).thenThrow(firebaseException);

        // Act
        final result = await repository.createNotification(notification);

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

      test('일반 예외 발생 시 NotificationCreationFailure를 반환해야 함', () async {
        // Arrange
        final notification = AppNotification(
          notificationId: '',
          userId: 'test-user-id',
          type: 'notice',
          title: 'Test Title',
          body: 'Test Body',
          isRead: false,
          createdAt: DateTime.now(),
        );

        when(() => mockCollection.doc()).thenReturn(mockDocumentRef);
        when(() => mockDocumentRef.id).thenReturn('test-id');
        when(() => mockDocumentRef.set(any()))
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.createNotification(notification);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<NotificationCreationFailure>());
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });
    });
  });
}

