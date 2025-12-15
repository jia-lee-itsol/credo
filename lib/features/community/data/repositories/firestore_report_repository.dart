import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/failures/community_failures.dart';
import '../../domain/repositories/report_repository.dart';
import '../models/report.dart';

/// Firestore를 사용한 신고 Repository 구현
class FirestoreReportRepository implements ReportRepository {
  final FirebaseFirestore _firestore;

  FirestoreReportRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, String>> createReport({
    required String targetType,
    required String targetId,
    required String reason,
    required String reporterId,
  }) async {
    try {
      AppLogger.community(
        '신고 생성: targetType=$targetType, targetId=$targetId, reporterId=$reporterId',
      );

      // 동일 유저가 동일 targetId를 짧은 시간(5분) 내에 반복 신고하는지 확인
      try {
        final fiveMinutesAgo = DateTime.now().subtract(
          const Duration(minutes: 5),
        );
        final recentReportsQuery = await _firestore
            .collection('reports')
            .where('targetType', isEqualTo: targetType)
            .where('targetId', isEqualTo: targetId)
            .where('reporterId', isEqualTo: reporterId)
            .where(
              'createdAt',
              isGreaterThan: Timestamp.fromDate(fiveMinutesAgo),
            )
            .limit(1)
            .get();

        if (recentReportsQuery.docs.isNotEmpty) {
          AppLogger.warning('⚠️ 짧은 시간 내 중복 신고 시도 감지');
          return const Left(
            ReportCreationFailure(
              message: '同じコンテンツを短時間に複数回通報することはできません。しばらくしてから再度お試しください。',
            ),
          );
        }
      } on FirebaseException catch (e) {
        // 인덱스가 아직 빌딩 중인 경우 임시로 중복 체크를 건너뜀
        if (e.code == 'failed-precondition' &&
            e.message?.contains('index') == true) {
          AppLogger.warning('⚠️ 인덱스가 아직 빌딩 중입니다. 중복 체크를 건너뜁니다.');
          // 인덱스가 완료될 때까지 중복 체크를 건너뛰고 신고 진행
        } else {
          // 다른 에러는 다시 throw
          rethrow;
        }
      }

      // 신고 문서 생성
      final docRef = _firestore.collection('reports').doc();
      final report = Report(
        reportId: docRef.id,
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        reporterId: reporterId,
        createdAt: DateTime.now(),
      );

      await docRef.set(report.toFirestore());

      AppLogger.community('✅ 신고 생성 완료: ${docRef.id}');
      return Right(docRef.id);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('신고 생성 실패: $e', e, stackTrace);
      return Left(
        FirebaseFailure(message: e.message ?? '신고 생성 실패', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('신고 생성 실패: $e', e, stackTrace);
      return Left(ReportCreationFailure(message: e.toString()));
    }
  }
}
