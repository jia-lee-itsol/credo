import 'package:dartz/dartz.dart';
import '../../../../core/data/services/parish_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/location_utils.dart';
import '../../domain/entities/parish_entity.dart';
import '../../domain/repositories/parish_repository.dart';
import '../models/parish_model.dart';

/// 교회 Repository 구현체
class ParishRepositoryImpl implements ParishRepository {
  @override
  Future<Either<Failure, List<ParishEntity>>> getParishes({
    String? prefecture,
    String? massLanguage,
    int? limit,
    String? lastParishId,
  }) async {
    try {
      final allParishes = await ParishService.loadAllParishes();
      final List<ParishEntity> entities = [];

      for (final dioceseParishes in allParishes.values) {
        for (final parishData in dioceseParishes) {
          // prefecture 필터
          if (prefecture != null) {
            final parishPrefecture = parishData['prefecture'] as String? ?? '';
            if (parishPrefecture != prefecture) continue;
          }

          // massLanguage 필터
          if (massLanguage != null) {
            final massTimes = parishData['mass_times'] as List<dynamic>? ?? [];
            final hasLanguage = massTimes.any((mt) {
              final mtMap = mt as Map<String, dynamic>;
              return mtMap['language'] == massLanguage;
            });
            if (!hasLanguage) continue;
          }

          // ParishModel로 변환
          final parishId = '${parishData['diocese']}-${parishData['name']}';
          final model = _mapToParishModel(parishData, parishId);
          entities.add(model.toEntity());
        }
      }

      // limit 적용
      final result = limit != null && limit > 0
          ? entities.take(limit).toList()
          : entities;

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: '교회 목록을 불러오는데 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, ParishEntity>> getParishById(String parishId) async {
    try {
      final parishData = await ParishService.getParishById(parishId);
      if (parishData == null) {
        return Left(NotFoundFailure(message: '교회를 찾을 수 없습니다'));
      }

      final model = _mapToParishModel(parishData, parishId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: '교회 정보를 불러오는데 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ParishEntity>>> searchParishes({
    required String query,
    String? prefecture,
    String? massLanguage,
  }) async {
    try {
      final results = await ParishService.searchParishes(query);
      final List<ParishEntity> entities = [];

      for (final parishData in results) {
        // prefecture 필터
        if (prefecture != null) {
          final parishPrefecture = parishData['prefecture'] as String? ?? '';
          if (parishPrefecture != prefecture) continue;
        }

        // massLanguage 필터
        if (massLanguage != null) {
          final massTimes = parishData['mass_times'] as List<dynamic>? ?? [];
          final hasLanguage = massTimes.any((mt) {
            final mtMap = mt as Map<String, dynamic>;
            return mtMap['language'] == massLanguage;
          });
          if (!hasLanguage) continue;
        }

        final parishId = '${parishData['diocese']}-${parishData['name']}';
        final model = _mapToParishModel(parishData, parishId);
        entities.add(model.toEntity());
      }

      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: '교회 검색에 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ParishEntity>>> getNearbyParishes({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? massLanguage,
  }) async {
    try {
      final allParishes = await ParishService.loadAllParishes();
      final List<ParishEntity> entities = [];

      for (final dioceseParishes in allParishes.values) {
        for (final parishData in dioceseParishes) {
          final parishLat = (parishData['latitude'] as num?)?.toDouble() ?? 0.0;
          final parishLng =
              (parishData['longitude'] as num?)?.toDouble() ?? 0.0;

          // 거리 계산
          final distance = LocationUtils.calculateDistance(
            latitude,
            longitude,
            parishLat,
            parishLng,
          );

          if (distance > radiusKm) continue;

          // massLanguage 필터
          if (massLanguage != null) {
            final massTimes = parishData['mass_times'] as List<dynamic>? ?? [];
            final hasLanguage = massTimes.any((mt) {
              final mtMap = mt as Map<String, dynamic>;
              return mtMap['language'] == massLanguage;
            });
            if (!hasLanguage) continue;
          }

          final parishId = '${parishData['diocese']}-${parishData['name']}';
          final model = _mapToParishModel(parishData, parishId);
          entities.add(model.toEntity());
        }
      }

      // 거리순 정렬
      entities.sort((a, b) {
        final distA = LocationUtils.calculateDistance(
          latitude,
          longitude,
          a.latitude,
          a.longitude,
        );
        final distB = LocationUtils.calculateDistance(
          latitude,
          longitude,
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });

      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: '근처 교회를 불러오는데 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ParishEntity>>> getFavoriteParishes(
    List<String> parishIds,
  ) async {
    try {
      final List<ParishEntity> entities = [];

      for (final parishId in parishIds) {
        final result = await getParishById(parishId);
        result.fold((failure) => null, (entity) => entities.add(entity));
      }

      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: '즐겨찾기 교회를 불러오는데 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MassTimeEntity>>> getMassTimes(
    String parishId,
  ) async {
    try {
      final result = await getParishById(parishId);
      return result.fold(
        (failure) => Left(failure),
        (entity) => Right(entity.massTimes),
      );
    } catch (e) {
      return Left(ServerFailure(message: '미사 시간을 불러오는데 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getPrefectures() async {
    try {
      final allParishes = await ParishService.loadAllParishes();
      final Set<String> prefectures = {};

      for (final dioceseParishes in allParishes.values) {
        for (final parishData in dioceseParishes) {
          final prefecture = parishData['prefecture'] as String?;
          if (prefecture != null && prefecture.isNotEmpty) {
            prefectures.add(prefecture);
          }
        }
      }

      return Right(prefectures.toList()..sort());
    } catch (e) {
      return Left(ServerFailure(message: '도도부현 목록을 불러오는데 실패했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addFavoriteParish(String parishId) {
    // 이 기능은 auth repository에서 처리
    return Future.value(
      Left(NotImplementedFailure(message: '이 기능은 auth repository에서 처리됩니다')),
    );
  }

  @override
  Future<Either<Failure, void>> removeFavoriteParish(String parishId) {
    // 이 기능은 auth repository에서 처리
    return Future.value(
      Left(NotImplementedFailure(message: '이 기능은 auth repository에서 처리됩니다')),
    );
  }

  /// Map 데이터를 ParishModel로 변환
  ParishModel _mapToParishModel(Map<String, dynamic> data, String parishId) {
    final massTimes = (data['mass_times'] as List<dynamic>? ?? []).map((mt) {
      final mtMap = mt as Map<String, dynamic>;
      return MassTimeModel(
        massId: mtMap['mass_id'] as String? ?? '',
        parishId: parishId,
        weekday: mtMap['weekday'] as int? ?? 0,
        time: mtMap['time'] as String? ?? '00:00',
        language: mtMap['language'] as String? ?? 'ja',
        note: mtMap['note'] as String?,
      );
    }).toList();

    return ParishModel(
      parishId: parishId,
      name: data['name'] as String? ?? '',
      prefecture: data['prefecture'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      officialSite: data['official_site'] as String?,
      hasOfficialAccount: data['has_official_account'] as bool? ?? false,
      nearestStation: data['nearest_station'] as String?,
      imageUrl: data['image_url'] as String?,
      massTimes: massTimes,
    );
  }
}
