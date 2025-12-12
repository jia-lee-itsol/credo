import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/app_user.dart';

/// 사용자 Repository 인터페이스
abstract class UserRepository {
  /// UID로 사용자 조회
  Future<Either<Failure, AppUser?>> getUserById(String uid);

  /// 사용자 저장 (생성 또는 업데이트)
  Future<Either<Failure, void>> saveUser(AppUser user);

  /// 사용자 실시간 스트림 (변경사항 감지)
  Stream<AppUser?> watchUser(String uid);

  /// displayName으로 사용자 검색
  Future<Either<Failure, List<AppUser>>> searchUsersByDisplayName(
    String displayName,
  );

  /// 성당 소속 사용자 목록 조회
  Future<Either<Failure, List<AppUser>>> getUsersByParishId(String parishId);
}
