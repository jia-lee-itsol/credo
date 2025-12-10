import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/saint_feast_day_entity.dart';
import '../repositories/saint_feast_day_repository.dart';

/// 성인 축일 조회 UseCase
class GetSaintsForDateUseCase {
  final SaintFeastDayRepository _repository;

  GetSaintsForDateUseCase(this._repository);

  Future<Either<Failure, List<SaintFeastDayEntity>>> call(DateTime date) {
    return _repository.getSaintsForDate(date);
  }
}

/// 오늘의 성인 축일 조회 UseCase
class GetTodaySaintsUseCase {
  final SaintFeastDayRepository _repository;

  GetTodaySaintsUseCase(this._repository);

  Future<Either<Failure, List<SaintFeastDayEntity>>> call() {
    return _repository.getTodaySaints();
  }
}
