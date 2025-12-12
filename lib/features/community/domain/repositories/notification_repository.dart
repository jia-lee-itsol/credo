import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/notification.dart';

/// 알림 Repository 인터페이스
abstract class NotificationRepository {
  /// 알림 생성
  Future<Either<Failure, String>> createNotification(
    AppNotification notification,
  );

  /// 사용자의 알림 목록 조회 (스트림)
  Stream<List<AppNotification>> watchNotifications(String userId);

  /// 알림 읽음 처리
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// 모든 알림 읽음 처리
  Future<Either<Failure, void>> markAllAsRead(String userId);

  /// 알림 삭제
  Future<Either<Failure, void>> deleteNotification(String notificationId);
}
