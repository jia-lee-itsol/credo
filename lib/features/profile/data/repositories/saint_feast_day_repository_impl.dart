import 'package:dartz/dartz.dart';
import '../../../../core/data/services/saint_feast_day_service.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/saint_feast_day_entity.dart';
import '../../domain/repositories/saint_feast_day_repository.dart';
import '../models/saint_feast_day_model.dart';

/// 성인 축일 Repository 구현체
class SaintFeastDayRepositoryImpl implements SaintFeastDayRepository {
  @override
  Future<Either<Failure, List<SaintFeastDayEntity>>>
  loadSaintsFeastDays() async {
    try {
      final data = await SaintFeastDayService.loadSaintsFeastDays();
      final allSaints = [...data.saints, ...data.japaneseSaints];
      final entities = allSaints.map((saint) => saint.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: '성인 축일 데이터를 불러오는데 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SaintFeastDayEntity>>> getSaintsForDate(
    DateTime date,
  ) async {
    try {
      // GPT를 사용하여 성인 검색 (기본 언어: 일본어)
      final saints = await SaintFeastDayService.getSaintsForDateFromChatGPT(
        date,
        'ja',
      );
      final entities = saints.map((saint) => saint.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: '성인 축일을 불러오는데 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SaintFeastDayEntity>>> getTodaySaints() async {
    try {
      // GPT를 사용하여 오늘의 성인 검색 (기본 언어: 일본어)
      final saints = await SaintFeastDayService.getTodaySaints(languageCode: 'ja');
      final entities = saints.map((saint) => saint.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: '오늘의 성인 축일을 불러오는데 실패했습니다: $e'));
    }
  }
}
