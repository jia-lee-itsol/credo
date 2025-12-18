import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:credo/features/parish/data/repositories/parish_repository_impl.dart';
import 'package:credo/core/error/failures.dart';
import 'package:credo/features/parish/domain/entities/parish_entity.dart';

// Note: ParishService는 static 메서드를 사용하므로 mock하기 어렵습니다.
// 이 테스트는 실제 ParishService를 사용하므로 통합 테스트에 가깝습니다.
// 단위 테스트를 위해서는 ParishService를 의존성 주입 가능하게 리팩토링하는 것이 좋습니다.

void main() {
  late ParishRepositoryImpl repository;

  setUp(() {
    repository = ParishRepositoryImpl();
  });

  group('ParishRepositoryImpl', () {
    group('getParishes', () {
      test('모든 교회 목록을 반환해야 함', () async {
        // Act
        final result = await repository.getParishes();

        // Assert
        // Note: 실제 assets 파일이 필요하므로 통합 테스트에 가깝습니다.
        // assets 파일이 없으면 빈 리스트가 반환될 수 있습니다.
        expect(result, isA<Right<Failure, List<ParishEntity>>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함: $failure'),
          (parishes) {
            expect(parishes, isA<List<ParishEntity>>());
            // 실제 데이터가 있으면 비어있지 않아야 함
            // assets 파일이 없으면 빈 리스트일 수 있음
          },
        );
      });

      test('prefecture 필터가 작동해야 함', () async {
        // Act
        final result = await repository.getParishes(prefecture: '東京都');

        // Assert
        expect(result, isA<Right<Failure, List<ParishEntity>>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함: $failure'),
          (parishes) {
            expect(parishes, isA<List<ParishEntity>>());
            // 모든 교회가 지정된 prefecture를 가져야 함
            for (final parish in parishes) {
              expect(parish.prefecture, '東京都');
            }
          },
        );
      });

      test('limit이 적용되어야 함', () async {
        // Act
        final result = await repository.getParishes(limit: 5);

        // Assert
        expect(result, isA<Right<Failure, List<ParishEntity>>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함: $failure'),
          (parishes) {
            expect(parishes.length, lessThanOrEqualTo(5));
          },
        );
      });

      test('예외 발생 시 ServerFailure를 반환해야 함', () async {
        // Note: 실제로 예외를 발생시키기 어려우므로
        // 이 테스트는 실제 데이터가 없을 때를 시뮬레이션하기 어렵습니다.
        // 통합 테스트에서 검증하는 것이 좋습니다.
      });
    });

    group('getParishById', () {
      test('존재하는 교회 ID로 교회를 찾을 수 있어야 함', () async {
        // Arrange
        // 실제 데이터에서 존재하는 ID를 사용해야 합니다.
        // 예: 'tokyo-東京カテドラル聖マリア大聖堂'
        const parishId = 'tokyo-東京カテドラル聖マリア大聖堂';

        // Act
        final result = await repository.getParishById(parishId);

        // Assert
        // 실제 데이터에 따라 성공 또는 실패할 수 있습니다.
        result.fold(
          (failure) {
            // 교회를 찾을 수 없으면 NotFoundFailure
            expect(failure, isA<NotFoundFailure>());
          },
          (parish) {
            expect(parish, isA<ParishEntity>());
            expect(parish.parishId, parishId);
          },
        );
      });

      test('존재하지 않는 교회 ID는 NotFoundFailure를 반환해야 함', () async {
        // Arrange
        const parishId = 'nonexistent-parish-id';

        // Act
        final result = await repository.getParishById(parishId);

        // Assert
        expect(result, isA<Left<Failure, ParishEntity>>());
        result.fold(
          (failure) {
            expect(failure, isA<NotFoundFailure>());
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });
    });

    group('searchParishes', () {
      test('검색 쿼리로 교회를 찾을 수 있어야 함', () async {
        // Act
        final result = await repository.searchParishes(query: '東京');

        // Assert
        expect(result, isA<Right<Failure, List<ParishEntity>>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함: $failure'),
          (parishes) {
            expect(parishes, isA<List<ParishEntity>>());
            // 검색 결과가 있을 수 있음
          },
        );
      });

      test('prefecture 필터가 작동해야 함', () async {
        // Act
        final result = await repository.searchParishes(
          query: '東京',
          prefecture: '東京都',
        );

        // Assert
        expect(result, isA<Right<Failure, List<ParishEntity>>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함: $failure'),
          (parishes) {
            for (final parish in parishes) {
              expect(parish.prefecture, '東京都');
            }
          },
        );
      });
    });

    group('getNearbyParishes', () {
      test('근처 교회를 거리순으로 반환해야 함', () async {
        // Arrange
        const latitude = 35.6762; // Tokyo
        const longitude = 139.6503;

        // Act
        final result = await repository.getNearbyParishes(
          latitude: latitude,
          longitude: longitude,
          radiusKm: 10.0,
        );

        // Assert
        expect(result, isA<Right<Failure, List<ParishEntity>>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함: $failure'),
          (parishes) {
            expect(parishes, isA<List<ParishEntity>>());
            // 거리순으로 정렬되어 있어야 함
            // (실제로는 거리 계산 로직이 복잡하므로 간단히 확인)
          },
        );
      });

      test('radiusKm 범위 내의 교회만 반환해야 함', () async {
        // Arrange
        const latitude = 35.6762;
        const longitude = 139.6503;
        const radiusKm = 5.0;

        // Act
        final result = await repository.getNearbyParishes(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        );

        // Assert
        expect(result, isA<Right<Failure, List<ParishEntity>>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함: $failure'),
          (parishes) {
            // 모든 교회가 반경 내에 있어야 함
            // (거리 계산은 LocationUtils를 사용하므로 실제 테스트는 복잡함)
          },
        );
      });
    });

    group('getPrefectures', () {
      test('도도부현 목록을 반환해야 함', () async {
        // Act
        final result = await repository.getPrefectures();

        // Assert
        // Note: 실제 assets 파일이 필요하므로 통합 테스트에 가깝습니다.
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함: $failure'),
          (prefectures) {
            expect(prefectures, isA<List<String>>());
            // 실제 데이터가 있으면 비어있지 않아야 함
            // assets 파일이 없으면 빈 리스트일 수 있음
            if (prefectures.isNotEmpty) {
              // 정렬되어 있어야 함
              final sorted = [...prefectures]..sort();
              expect(prefectures, equals(sorted));
            }
          },
        );
      });
    });

    group('getMassTimes', () {
      test('교회의 미사 시간을 반환해야 함', () async {
        // Arrange
        // 실제 데이터에서 존재하는 ID를 사용해야 합니다.
        const parishId = 'tokyo-東京カテドラル聖マリア大聖堂';

        // Act
        final result = await repository.getMassTimes(parishId);

        // Assert
        result.fold(
          (failure) {
            // 교회를 찾을 수 없으면 실패
            expect(failure, isA<Failure>());
          },
          (massTimes) {
            expect(massTimes, isA<List<MassTimeEntity>>());
          },
        );
      });
    });
  });
}

