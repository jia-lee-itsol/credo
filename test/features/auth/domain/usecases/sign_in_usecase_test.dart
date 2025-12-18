import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:credo/features/auth/domain/repositories/auth_repository.dart';
import 'package:credo/features/auth/domain/entities/user_entity.dart';
import 'package:credo/core/error/failures.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('SignInWithEmailUseCase', () {
    test('이메일 로그인이 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = SignInWithEmailUseCase(mockRepository);
      final testUser = UserEntity(
        userId: 'user1',
        nickname: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase.call(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result, isA<Right<Failure, UserEntity>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (user) => expect(user, testUser),
      );
      verify(() => mockRepository.signInWithEmail(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    test('이메일 로그인 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = SignInWithEmailUseCase(mockRepository);
      final failure = AuthFailure(message: 'Invalid credentials');

      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('실패가 발생해야 함'),
      );
    });
  });

  group('SignInWithGoogleUseCase', () {
    test('Google 로그인이 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = SignInWithGoogleUseCase(mockRepository);
      final testUser = UserEntity(
        userId: 'user1',
        nickname: 'Google User',
        email: 'google@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Right<Failure, UserEntity>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (user) => expect(user, testUser),
      );
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });

    test('Google 로그인 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = SignInWithGoogleUseCase(mockRepository);
      final failure = AuthFailure(message: 'Google sign in failed');

      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('실패가 발생해야 함'),
      );
    });
  });

  group('SignInWithAppleUseCase', () {
    test('Apple 로그인이 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = SignInWithAppleUseCase(mockRepository);
      final testUser = UserEntity(
        userId: 'user1',
        nickname: 'Apple User',
        email: 'apple@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRepository.signInWithApple())
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Right<Failure, UserEntity>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (user) => expect(user, testUser),
      );
      verify(() => mockRepository.signInWithApple()).called(1);
    });

    test('Apple 로그인 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = SignInWithAppleUseCase(mockRepository);
      final failure = AuthFailure(message: 'Apple sign in failed');

      when(() => mockRepository.signInWithApple())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('실패가 발생해야 함'),
      );
    });
  });

  group('SignOutUseCase', () {
    test('로그아웃이 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = SignOutUseCase(mockRepository);

      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Right<Failure, void>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (_) {},
      );
      verify(() => mockRepository.signOut()).called(1);
    });

    test('로그아웃 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = SignOutUseCase(mockRepository);
      final failure = ServerFailure(message: 'Sign out failed');

      when(() => mockRepository.signOut())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('실패가 발생해야 함'),
      );
    });
  });

  group('GetCurrentUserUseCase', () {
    test('현재 사용자 조회가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = GetCurrentUserUseCase(mockRepository);
      final testUser = UserEntity(
        userId: 'user1',
        nickname: 'Current User',
        email: 'current@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Right<Failure, UserEntity?>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (user) => expect(user, testUser),
      );
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('로그인된 사용자가 없으면 null을 반환해야 함', () async {
      // Arrange
      final useCase = GetCurrentUserUseCase(mockRepository);

      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Right<Failure, UserEntity?>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (user) => expect(user, isNull),
      );
    });

    test('현재 사용자 조회 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = GetCurrentUserUseCase(mockRepository);
      final failure = ServerFailure(message: 'Failed to get current user');

      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Left<Failure, UserEntity?>>());
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('실패가 발생해야 함'),
      );
    });
  });
}

