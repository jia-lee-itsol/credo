import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/failures/community_failures.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification.dart' as models;

/// Firestore를 사용한 알림 Repository 구현
class FirestoreNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _firestore;

  FirestoreNotificationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, String>> createNotification(
    models.AppNotification notification,
  ) async {
    try {
      AppLogger.notification(
        '알림 생성: userId=${notification.userId}, type=${notification.type}',
      );

      final docRef = _firestore.collection('notifications').doc();
      final notificationData = notification
          .copyWith(notificationId: docRef.id)
          .toFirestore();

      await docRef.set(notificationData);

      AppLogger.notification('✅ 알림 생성 완료: ${docRef.id}');
      return Right(docRef.id);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('알림 생성 실패: $e', e, stackTrace);
      return Left(
        FirebaseFailure(message: e.message ?? '알림 생성 실패', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('알림 생성 실패: $e', e, stackTrace);
      return Left(NotificationCreationFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<models.AppNotification>> watchNotifications(String userId) {
    try {
      AppLogger.notification('watchNotifications 호출: userId=$userId');
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            AppLogger.notification(
              '알림 조회: ${snapshot.docs.length}개 (userId=$userId)',
            );
            final notifications = snapshot.docs
                .map((doc) {
                  try {
                    final notification = models.AppNotification.fromFirestore(
                      doc,
                    );
                    AppLogger.notification(
                      '알림 파싱 성공: id=${notification.notificationId}, type=${notification.type}, title=${notification.title}',
                    );
                    return notification;
                  } catch (e, stackTrace) {
                    AppLogger.error(
                      '알림 파싱 에러 (docId: ${doc.id}): $e',
                      e,
                      stackTrace,
                    );
                    AppLogger.error('알림 문서 데이터: ${doc.data()}', null);
                    return null;
                  }
                })
                .whereType<models.AppNotification>()
                .toList();

            // 클라이언트에서 생성 시간순 정렬 (최신순)
            notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return notifications.take(50).toList();
          })
          .handleError((error, stackTrace) {
            AppLogger.error(
              'watchNotifications 스트림 에러: $error',
              error,
              stackTrace,
            );
            return <models.AppNotification>[];
          });
    } catch (e, stackTrace) {
      AppLogger.error('watchNotifications 초기화 에러: $e', e, stackTrace);
      return Stream.value(<models.AppNotification>[]);
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.error('알림 읽음 처리 실패: $e', e);
      return Left(
        FirebaseFailure(message: e.message ?? '알림 읽음 처리 실패', code: e.code),
      );
    } catch (e) {
      AppLogger.error('알림 읽음 처리 실패: $e', e);
      return Left(NotificationUpdateFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.error('모든 알림 읽음 처리 실패: $e', e);
      return Left(
        FirebaseFailure(message: e.message ?? '모든 알림 읽음 처리 실패', code: e.code),
      );
    } catch (e) {
      AppLogger.error('모든 알림 읽음 처리 실패: $e', e);
      return Left(NotificationUpdateFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.error('알림 삭제 실패: $e', e);
      return Left(
        FirebaseFailure(message: e.message ?? '알림 삭제 실패', code: e.code),
      );
    } catch (e) {
      AppLogger.error('알림 삭제 실패: $e', e);
      return Left(NotificationDeleteFailure(message: e.toString()));
    }
  }
}
