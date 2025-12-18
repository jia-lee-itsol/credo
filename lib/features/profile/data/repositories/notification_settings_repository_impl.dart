import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import '../models/notification_settings.dart';

/// 알림 설정 Repository 구현체
class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
  final FirebaseFirestore _firestore;

  NotificationSettingsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, NotificationSettings>> getSettings(
    String userId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notificationSettings')
          .doc('settings')
          .get();

      if (!doc.exists) {
        // 기본 설정 반환
        return const Right(NotificationSettings());
      }

      final settings = NotificationSettings.fromFirestore(doc);
      return Right(settings);
    } on FirebaseException catch (e) {
      AppLogger.error('알림 설정 조회 실패: $e', e);
      return Left(
        FirebaseFailure(
          message: e.message ?? '알림 설정을 불러오는데 실패했습니다',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('알림 설정 조회 실패: $e', e, stackTrace);
      return Left(
        ServerFailure(message: '알림 설정을 불러오는데 실패했습니다: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(
    String userId,
    NotificationSettings settings,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notificationSettings')
          .doc('settings')
          .set(
            settings.copyWith(updatedAt: DateTime.now()).toFirestore(),
            SetOptions(merge: true),
          );

      AppLogger.profile('알림 설정 저장 완료: userId=$userId');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.error('알림 설정 저장 실패: $e', e);
      return Left(
        FirebaseFailure(
          message: e.message ?? '알림 설정을 저장하는데 실패했습니다',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('알림 설정 저장 실패: $e', e, stackTrace);
      return Left(
        ServerFailure(message: '알림 설정을 저장하는데 실패했습니다: $e'),
      );
    }
  }

  @override
  Stream<NotificationSettings> watchSettings(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notificationSettings')
        .doc('settings')
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return const NotificationSettings();
      }
      return NotificationSettings.fromFirestore(doc);
    });
  }
}

