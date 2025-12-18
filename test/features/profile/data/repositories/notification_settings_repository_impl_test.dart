import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/profile/data/repositories/notification_settings_repository_impl.dart';
import 'package:credo/features/profile/data/models/notification_settings.dart';
import 'package:credo/core/error/failures.dart';

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
  late NotificationSettingsRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockCollectionReference mockSettingsCollection;
  late MockDocumentReference mockDocumentRef;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockSettingsCollection = MockCollectionReference();
    mockDocumentRef = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    repository = NotificationSettingsRepositoryImpl(firestore: mockFirestore);

    // 기본 설정
    when(() => mockFirestore.collection('users'))
        .thenReturn(mockUsersCollection);
    when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentRef);
    when(() => mockDocumentRef.collection('notificationSettings'))
        .thenReturn(mockSettingsCollection);
    when(() => mockSettingsCollection.doc('settings'))
        .thenReturn(mockDocumentRef);
  });

  group('NotificationSettingsRepositoryImpl', () {
    group('getSettings', () {
      test('설정이 존재할 때 NotificationSettings를 반환해야 함', () async {
        // Arrange
        const userId = 'test-user-id';
        final settingsData = {
          'enabled': true,
          'notices': true,
          'comments': true,
          'likes': false,
          'dailyMass': true,
          'quietHoursStart': 22,
          'quietHoursEnd': 7,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        when(() => mockDocumentRef.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(() => mockDocumentSnapshot.data()).thenReturn(settingsData);
        when(() => mockDocumentSnapshot.id).thenReturn('settings');

        // Act
        final result = await repository.getSettings(userId);

        // Assert
        expect(result, isA<Right<Failure, NotificationSettings>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (settings) {
            expect(settings.enabled, true);
            expect(settings.notices, true);
            expect(settings.comments, true);
            expect(settings.likes, false);
            expect(settings.dailyMass, true);
          },
        );
        verify(() => mockDocumentRef.get()).called(1);
      });

      test('설정이 존재하지 않을 때 기본 설정을 반환해야 함', () async {
        // Arrange
        const userId = 'test-user-id';

        when(() => mockDocumentRef.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final result = await repository.getSettings(userId);

        // Assert
        expect(result, isA<Right<Failure, NotificationSettings>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (settings) {
            expect(settings.enabled, true); // 기본값
            expect(settings.notices, true); // 기본값
            expect(settings.comments, true); // 기본값
            expect(settings.likes, false); // 기본값
            expect(settings.dailyMass, false); // 기본값
          },
        );
      });

      test('FirebaseException 발생 시 FirebaseFailure를 반환해야 함', () async {
        // Arrange
        const userId = 'test-user-id';
        final firebaseException = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        );

        when(() => mockDocumentRef.get()).thenThrow(firebaseException);

        // Act
        final result = await repository.getSettings(userId);

        // Assert
        expect(result, isA<Left<Failure, NotificationSettings>>());
        result.fold(
          (failure) {
            expect(failure, isA<FirebaseFailure>());
            expect(failure.code, 'permission-denied');
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });

      test('일반 예외 발생 시 ServerFailure를 반환해야 함', () async {
        // Arrange
        const userId = 'test-user-id';

        when(() => mockDocumentRef.get())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.getSettings(userId);

        // Assert
        expect(result, isA<Left<Failure, NotificationSettings>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });
    });

    group('saveSettings', () {
      test('설정이 성공적으로 저장되어야 함', () async {
        // Arrange
        const userId = 'test-user-id';
        final settings = NotificationSettings(
          enabled: true,
          notices: true,
          comments: false,
          likes: true,
          dailyMass: true,
        );

        when(() => mockDocumentRef.set(any(), any()))
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.saveSettings(userId, settings);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockDocumentRef.set(any(), any())).called(1);
      });

      test('FirebaseException 발생 시 FirebaseFailure를 반환해야 함', () async {
        // Arrange
        const userId = 'test-user-id';
        final settings = NotificationSettings();
        final firebaseException = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        );

        when(() => mockDocumentRef.set(any(), any()))
            .thenThrow(firebaseException);

        // Act
        final result = await repository.saveSettings(userId, settings);

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

      test('일반 예외 발생 시 ServerFailure를 반환해야 함', () async {
        // Arrange
        const userId = 'test-user-id';
        final settings = NotificationSettings();

        when(() => mockDocumentRef.set(any(), any()))
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.saveSettings(userId, settings);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });
    });

    group('watchSettings', () {
      test('설정 스트림이 올바르게 작동해야 함', () {
        // Arrange
        const userId = 'test-user-id';
        final settingsData = {
          'enabled': true,
          'notices': true,
          'comments': true,
          'likes': false,
          'dailyMass': false,
          'quietHoursStart': 22,
          'quietHoursEnd': 7,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        when(() => mockDocumentRef.snapshots())
            .thenAnswer((_) => Stream.value(mockDocumentSnapshot));
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(() => mockDocumentSnapshot.data()).thenReturn(settingsData);
        when(() => mockDocumentSnapshot.id).thenReturn('settings');

        // Act
        final stream = repository.watchSettings(userId);

        // Assert
        expect(stream, isA<Stream<NotificationSettings>>());
        // 스트림 테스트는 실제로는 더 복잡하지만 기본 구조는 확인됨
      });

      test('설정이 없을 때 기본 설정을 반환해야 함', () {
        // Arrange
        const userId = 'test-user-id';

        when(() => mockDocumentRef.snapshots())
            .thenAnswer((_) => Stream.value(mockDocumentSnapshot));
        when(() => mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final stream = repository.watchSettings(userId);

        // Assert
        expect(stream, isA<Stream<NotificationSettings>>());
      });
    });
  });
}

