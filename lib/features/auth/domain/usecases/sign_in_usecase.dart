import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// 이메일 로그인 UseCase
class SignInWithEmailUseCase {
  final AuthRepository _repository;

  SignInWithEmailUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}

/// Google 로그인 UseCase
class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() {
    return _repository.signInWithGoogle();
  }
}

/// Apple 로그인 UseCase
class SignInWithAppleUseCase {
  final AuthRepository _repository;

  SignInWithAppleUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() {
    return _repository.signInWithApple();
  }
}

/// 로그아웃 UseCase
class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.signOut();
  }
}

/// 현재 사용자 조회 UseCase
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, UserEntity?>> call() {
    return _repository.getCurrentUser();
  }
}
