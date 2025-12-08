import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/parish_entity.dart';

/// 교회 Repository 인터페이스
abstract class ParishRepository {
  /// 교회 목록 조회
  Future<Either<Failure, List<ParishEntity>>> getParishes({
    String? prefecture,
    String? massLanguage,
    int? limit,
    String? lastParishId,
  });

  /// 교회 상세 조회
  Future<Either<Failure, ParishEntity>> getParishById(String parishId);

  /// 교회 검색
  Future<Either<Failure, List<ParishEntity>>> searchParishes({
    required String query,
    String? prefecture,
    String? massLanguage,
  });

  /// 근처 교회 조회
  Future<Either<Failure, List<ParishEntity>>> getNearbyParishes({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? massLanguage,
  });

  /// 즐겨찾기 교회 목록 조회
  Future<Either<Failure, List<ParishEntity>>> getFavoriteParishes(
    List<String> parishIds,
  );

  /// 교회 미사 시간 조회
  Future<Either<Failure, List<MassTimeEntity>>> getMassTimes(String parishId);

  /// 도도부현 목록 조회
  Future<Either<Failure, List<String>>> getPrefectures();

  /// 교회 즐겨찾기 추가
  Future<Either<Failure, void>> addFavoriteParish(String parishId);

  /// 교회 즐겨찾기 제거
  Future<Either<Failure, void>> removeFavoriteParish(String parishId);
}
