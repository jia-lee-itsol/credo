import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/community/data/repositories/firestore_user_repository.dart';
import 'package:credo/features/community/data/models/app_user.dart';
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
  late FirestoreUserRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocumentRef;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocumentRef = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    repository = FirestoreUserRepository(firestore: mockFirestore);

    // 기본 설정
    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocumentRef);
  });

  group('FirestoreUserRepository', () {
    group('getUserById', () {
      test('사용자가 존재할 때 AppUser를 반환해야 함', () async {
        // Arrange
        const uid = 'test-uid';
        final userData = {
          'uid': uid,
          'email': 'test@example.com',
          'displayName': 'Test User',
          'nickname': 'testuser',
          'createdAt': Timestamp.now(),
        };

        when(
          () => mockDocumentRef.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(() => mockDocumentSnapshot.data()).thenReturn(userData);
        when(() => mockDocumentSnapshot.id).thenReturn(uid);

        // Act
        final result = await repository.getUserById(uid);

        // Assert
        expect(result, isA<Right<Failure, AppUser?>>());
        result.fold((failure) => fail('실패가 발생하지 않아야 함'), (user) {
          expect(user, isNotNull);
          expect(user?.uid, uid);
          expect(user?.email, 'test@example.com');
        });
        verify(() => mockDocumentRef.get()).called(1);
      });

      test('사용자가 존재하지 않을 때 null을 반환해야 함', () async {
        // Arrange
        const uid = 'non-existent-uid';

        when(
          () => mockDocumentRef.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final result = await repository.getUserById(uid);

        // Assert
        expect(result, isA<Right<Failure, AppUser?>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (user) => expect(user, isNull),
        );
      });

      test('FirebaseException 발생 시 FirebaseFailure를 반환해야 함', () async {
        // Arrange
        const uid = 'test-uid';
        final firebaseException = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        );

        when(() => mockDocumentRef.get()).thenThrow(firebaseException);

        // Act
        final result = await repository.getUserById(uid);

        // Assert
        expect(result, isA<Left<Failure, AppUser?>>());
        result.fold((failure) {
          expect(failure, isA<FirebaseFailure>());
          expect(failure.code, 'permission-denied');
        }, (_) => fail('실패가 발생해야 함'));
      });

      test('일반 예외 발생 시 UserNotFoundFailure를 반환해야 함', () async {
        // Arrange
        const uid = 'test-uid';

        when(
          () => mockDocumentRef.get(),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.getUserById(uid);

        // Assert
        expect(result, isA<Left<Failure, AppUser?>>());
        result.fold((failure) {
          expect(failure, isA<UserNotFoundFailure>());
        }, (_) => fail('실패가 발생해야 함'));
      });
    });

    group('saveUser', () {
      test('사용자 저장이 성공하면 Right를 반환해야 함', () async {
        // Arrange
        final now = DateTime.now();
        final user = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: now,
          updatedAt: now,
        );

        when(
          () => mockDocumentRef.set(any(), any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.saveUser(user);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(
          () => mockDocumentRef.set(
            any(that: isA<Map<String, dynamic>>()),
            any(),
          ),
        ).called(1);
      });

      test('FirebaseException 발생 시 FirebaseFailure를 반환해야 함', () async {
        // Arrange
        final now = DateTime.now();
        final user = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: now,
          updatedAt: now,
        );
        final firebaseException = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        );

        when(
          () => mockDocumentRef.set(any(), any()),
        ).thenThrow(firebaseException);

        // Act
        final result = await repository.saveUser(user);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<FirebaseFailure>());
          expect(failure.code, 'permission-denied');
        }, (_) => fail('실패가 발생해야 함'));
      });

      test('일반 예외 발생 시 UserSaveFailure를 반환해야 함', () async {
        // Arrange
        final now = DateTime.now();
        final user = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: now,
          updatedAt: now,
        );

        when(
          () => mockDocumentRef.set(any(), any()),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.saveUser(user);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<UserSaveFailure>());
        }, (_) => fail('실패가 발생해야 함'));
      });
    });
  });
}
