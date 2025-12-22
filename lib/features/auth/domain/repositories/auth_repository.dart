import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// 인증 Repository 인터페이스
abstract class AuthRepository {
  /// 현재 로그인된 사용자 조회
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// 이메일/비밀번호로 회원가입
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
    String? mainParishId,
    String? baptismalName,
    String? feastDayId,
  });

  /// 이메일/비밀번호로 로그인
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Google 로그인
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Apple 로그인
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// 로그아웃
  Future<Either<Failure, void>> signOut();

  /// 비밀번호 재설정 이메일 전송
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// 사용자 프로필 업데이트
  Future<Either<Failure, UserEntity>> updateProfile({
    String? nickname,
    String? mainParishId,
    List<String>? preferredLanguages,
    List<String>? favoriteParishIds,
    String? profileImageUrl,
    String? feastDayId,
    String? baptismalName,
    DateTime? baptismDate,
    DateTime? confirmationDate,
    List<String>? godchildren,
    String? godparentId,
  });

  /// 이메일, userId 또는 nickname으로 사용자 검색
  Future<Either<Failure, UserEntity?>> searchUser({
    String? email,
    String? userId,
    String? nickname,
  });

  /// 닉네임 중복 체크
  Future<Either<Failure, bool>> checkNicknameAvailable({
    required String nickname,
    String? excludeUserId, // 현재 사용자 ID (프로필 업데이트 시 제외)
  });

  /// 인증 상태 스트림
  Stream<UserEntity?> get authStateChanges;

  /// 사용자 삭제
  Future<Either<Failure, void>> deleteAccount();
}
