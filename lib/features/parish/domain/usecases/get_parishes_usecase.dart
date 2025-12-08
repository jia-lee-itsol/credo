import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/parish_entity.dart';
import '../repositories/parish_repository.dart';

/// 교회 목록 조회 UseCase
class GetParishesUseCase {
  final ParishRepository _repository;

  GetParishesUseCase(this._repository);

  Future<Either<Failure, List<ParishEntity>>> call({
    String? prefecture,
    String? massLanguage,
    int? limit,
    String? lastParishId,
  }) {
    return _repository.getParishes(
      prefecture: prefecture,
      massLanguage: massLanguage,
      limit: limit,
      lastParishId: lastParishId,
    );
  }
}

/// 교회 상세 조회 UseCase
class GetParishByIdUseCase {
  final ParishRepository _repository;

  GetParishByIdUseCase(this._repository);

  Future<Either<Failure, ParishEntity>> call(String parishId) {
    return _repository.getParishById(parishId);
  }
}

/// 교회 검색 UseCase
class SearchParishesUseCase {
  final ParishRepository _repository;

  SearchParishesUseCase(this._repository);

  Future<Either<Failure, List<ParishEntity>>> call({
    required String query,
    String? prefecture,
    String? massLanguage,
  }) {
    return _repository.searchParishes(
      query: query,
      prefecture: prefecture,
      massLanguage: massLanguage,
    );
  }
}

/// 근처 교회 조회 UseCase
class GetNearbyParishesUseCase {
  final ParishRepository _repository;

  GetNearbyParishesUseCase(this._repository);

  Future<Either<Failure, List<ParishEntity>>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? massLanguage,
  }) {
    return _repository.getNearbyParishes(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      massLanguage: massLanguage,
    );
  }
}

/// 즐겨찾기 교회 목록 조회 UseCase
class GetFavoriteParishesUseCase {
  final ParishRepository _repository;

  GetFavoriteParishesUseCase(this._repository);

  Future<Either<Failure, List<ParishEntity>>> call(List<String> parishIds) {
    return _repository.getFavoriteParishes(parishIds);
  }
}
