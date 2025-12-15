import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

/// 신고 Repository 인터페이스
abstract class ReportRepository {
  /// 신고 생성
  Future<Either<Failure, String>> createReport({
    required String targetType, // "post" | "comment" | "user"
    required String targetId,
    required String reason,
    required String reporterId,
  });
}
