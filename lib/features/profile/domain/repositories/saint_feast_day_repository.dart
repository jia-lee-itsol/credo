import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/saint_feast_day_entity.dart';

/// 성인 축일 Repository 인터페이스
abstract class SaintFeastDayRepository {
  /// 모든 성인 축일 데이터 로드
  Future<Either<Failure, List<SaintFeastDayEntity>>> loadSaintsFeastDays();

  /// 특정 날짜의 성인 축일 가져오기
  Future<Either<Failure, List<SaintFeastDayEntity>>> getSaintsForDate(
    DateTime date,
  );

  /// 오늘의 성인 축일 가져오기
  Future<Either<Failure, List<SaintFeastDayEntity>>> getTodaySaints();
}
