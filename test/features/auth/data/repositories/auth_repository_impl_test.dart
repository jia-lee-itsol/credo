import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:credo/features/auth/domain/entities/user_entity.dart';
import 'package:credo/core/error/failures.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    repository = AuthRepositoryImpl(auth: mockAuth, firestore: mockFirestore);
  });

  group('AuthRepositoryImpl', () {
    group('getCurrentUser', () {
      test('로그인된 사용자가 있으면 UserEntity를 반환해야 함', () async {
        // Arrange
        final mockUser = MockUser();
        when(() => mockUser.uid).thenReturn('test-uid');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        // Firestore 문서 모킹
        final mockDoc = MockDocumentSnapshot();
        final mockDocRef = MockDocumentReference();
        final mockCollection = MockCollectionReference();

        when(
          () => mockFirestore.collection('users'),
        ).thenReturn(mockCollection);
        when(() => mockCollection.doc('test-uid')).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDoc);
        when(() => mockDoc.exists).thenReturn(true);
        when(() => mockDoc.data()).thenReturn({
          'nickname': 'Test User',
          'email': 'test@example.com',
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
        });
        when(() => mockDoc.id).thenReturn('test-uid');

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Right<Failure, UserEntity?>>());
        result.fold((failure) => fail('실패가 발생하지 않아야 함'), (user) {
          expect(user, isNotNull);
          expect(user?.userId, 'test-uid');
        });
      });

      test('로그인된 사용자가 없으면 null을 반환해야 함', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Right<Failure, UserEntity?>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (user) => expect(user, isNull),
        );
      });
    });

    group('signOut', () {
      test('로그아웃이 성공하면 Right를 반환해야 함', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockAuth.signOut()).called(1);
      });

      test('로그아웃 실패 시 Failure를 반환해야 함', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenThrow(
          FirebaseException(
            plugin: 'auth',
            code: 'unknown',
            message: 'Sign out failed',
          ),
        );

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<FirebaseFailure>());
        }, (_) => fail('실패가 발생해야 함'));
      });
    });
  });
}

// Additional mock classes for Firestore
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}
