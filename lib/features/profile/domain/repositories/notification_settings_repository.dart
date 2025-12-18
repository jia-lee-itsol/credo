import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/notification_settings.dart';

/// 알림 설정 Repository 인터페이스
abstract class NotificationSettingsRepository {
  /// 사용자의 알림 설정 가져오기
  Future<Either<Failure, NotificationSettings>> getSettings(String userId);

  /// 사용자의 알림 설정 저장
  Future<Either<Failure, void>> saveSettings(
    String userId,
    NotificationSettings settings,
  );

  /// 사용자의 알림 설정 스트림
  Stream<NotificationSettings> watchSettings(String userId);
}

