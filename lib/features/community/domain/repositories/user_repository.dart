import '../../data/models/app_user.dart';

/// 사용자 Repository 인터페이스
abstract class UserRepository {
  /// UID로 사용자 조회
  Future<AppUser?> getUserById(String uid);

  /// 사용자 저장 (생성 또는 업데이트)
  Future<void> saveUser(AppUser user);

  /// 사용자 실시간 스트림 (변경사항 감지)
  Stream<AppUser?> watchUser(String uid);
}
