import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/parish/domain/usecases/get_parishes_usecase.dart';
import 'package:credo/features/parish/domain/repositories/parish_repository.dart';
import 'package:credo/features/parish/domain/entities/parish_entity.dart';
import 'package:credo/core/error/failures.dart';

// Mock classes
class MockParishRepository extends Mock implements ParishRepository {}

void main() {
  late MockParishRepository mockRepository;

  setUp(() {
    mockRepository = MockParishRepository();
  });

  group('GetParishesUseCase', () {
    test('교회 목록 조회가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = GetParishesUseCase(mockRepository);
      final testParishes = [
        ParishEntity(
          parishId: 'parish1',
          name: 'Test Parish 1',
          prefecture: 'Tokyo',
          address: 'Address 1',
          latitude: 35.6762,
          longitude: 139.6503,
        ),
        ParishEntity(
          parishId: 'parish2',
          name: 'Test Parish 2',
          prefecture: 'Osaka',
          address: 'Address 2',
          latitude: 34.6937,
          longitude: 135.5023,
        ),
      ];

      when(() => mockRepository.getParishes(
            prefecture: any(named: 'prefecture'),
            massLanguage: any(named: 'massLanguage'),
            limit: any(named: 'limit'),
            lastParishId: any(named: 'lastParishId'),
          )).thenAnswer((_) async => Right(testParishes));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Right<Failure, List<ParishEntity>>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (parishes) {
          expect(parishes, testParishes);
          expect(parishes.length, 2);
        },
      );
      verify(() => mockRepository.getParishes(
            prefecture: null,
            massLanguage: null,
            limit: null,
            lastParishId: null,
          )).called(1);
    });

    test('필터 파라미터가 올바르게 전달되어야 함', () async {
      // Arrange
      final useCase = GetParishesUseCase(mockRepository);
      final testParishes = <ParishEntity>[];

      when(() => mockRepository.getParishes(
            prefecture: any(named: 'prefecture'),
            massLanguage: any(named: 'massLanguage'),
            limit: any(named: 'limit'),
            lastParishId: any(named: 'lastParishId'),
          )).thenAnswer((_) async => Right(testParishes));

      // Act
      await useCase.call(
        prefecture: 'Tokyo',
        massLanguage: 'ja',
        limit: 10,
        lastParishId: 'parish1',
      );

      // Assert
      verify(() => mockRepository.getParishes(
            prefecture: 'Tokyo',
            massLanguage: 'ja',
            limit: 10,
            lastParishId: 'parish1',
          )).called(1);
    });

    test('교회 목록 조회 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = GetParishesUseCase(mockRepository);
      final failure = ServerFailure(message: 'Server error');

      when(() => mockRepository.getParishes(
            prefecture: any(named: 'prefecture'),
            massLanguage: any(named: 'massLanguage'),
            limit: any(named: 'limit'),
            lastParishId: any(named: 'lastParishId'),
          )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Left<Failure, List<ParishEntity>>>());
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('실패가 발생해야 함'),
      );
    });
  });

  group('GetParishByIdUseCase', () {
    test('교회 상세 조회가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = GetParishByIdUseCase(mockRepository);
      final testParish = ParishEntity(
        parishId: 'parish1',
        name: 'Test Parish',
        prefecture: 'Tokyo',
        address: 'Test Address',
        latitude: 35.6762,
        longitude: 139.6503,
      );

      when(() => mockRepository.getParishById(any()))
          .thenAnswer((_) async => Right(testParish));

      // Act
      final result = await useCase.call('parish1');

      // Assert
      expect(result, isA<Right<Failure, ParishEntity>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (parish) => expect(parish, testParish),
      );
      verify(() => mockRepository.getParishById('parish1')).called(1);
    });

    test('교회 상세 조회 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = GetParishByIdUseCase(mockRepository);
      final failure = NotFoundFailure(message: 'Parish not found');

      when(() => mockRepository.getParishById(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call('parish1');

      // Assert
      expect(result, isA<Left<Failure, ParishEntity>>());
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('실패가 발생해야 함'),
      );
    });
  });

  group('SearchParishesUseCase', () {
    test('교회 검색이 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = SearchParishesUseCase(mockRepository);
      final testParishes = [
        ParishEntity(
          parishId: 'parish1',
          name: 'Test Parish',
          prefecture: 'Tokyo',
          address: 'Test Address',
          latitude: 35.6762,
          longitude: 139.6503,
        ),
      ];

      when(() => mockRepository.searchParishes(
            query: any(named: 'query'),
            prefecture: any(named: 'prefecture'),
            massLanguage: any(named: 'massLanguage'),
          )).thenAnswer((_) async => Right(testParishes));

      // Act
      final result = await useCase.call(query: 'Test');

      // Assert
      expect(result, isA<Right<Failure, List<ParishEntity>>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (parishes) {
          expect(parishes, testParishes);
          expect(parishes.length, 1);
        },
      );
      verify(() => mockRepository.searchParishes(
            query: 'Test',
            prefecture: null,
            massLanguage: null,
          )).called(1);
    });

    test('검색 필터 파라미터가 올바르게 전달되어야 함', () async {
      // Arrange
      final useCase = SearchParishesUseCase(mockRepository);
      final testParishes = <ParishEntity>[];

      when(() => mockRepository.searchParishes(
            query: any(named: 'query'),
            prefecture: any(named: 'prefecture'),
            massLanguage: any(named: 'massLanguage'),
          )).thenAnswer((_) async => Right(testParishes));

      // Act
      await useCase.call(
        query: 'Test',
        prefecture: 'Tokyo',
        massLanguage: 'ja',
      );

      // Assert
      verify(() => mockRepository.searchParishes(
            query: 'Test',
            prefecture: 'Tokyo',
            massLanguage: 'ja',
          )).called(1);
    });
  });

  group('GetNearbyParishesUseCase', () {
    test('근처 교회 조회가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = GetNearbyParishesUseCase(mockRepository);
      final testParishes = [
        ParishEntity(
          parishId: 'parish1',
          name: 'Nearby Parish',
          prefecture: 'Tokyo',
          address: 'Nearby Address',
          latitude: 35.6762,
          longitude: 139.6503,
        ),
      ];

      when(() => mockRepository.getNearbyParishes(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
            massLanguage: any(named: 'massLanguage'),
          )).thenAnswer((_) async => Right(testParishes));

      // Act
      final result = await useCase.call(
        latitude: 35.6762,
        longitude: 139.6503,
        radiusKm: 10.0,
      );

      // Assert
      expect(result, isA<Right<Failure, List<ParishEntity>>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (parishes) {
          expect(parishes, testParishes);
          expect(parishes.length, 1);
        },
      );
      verify(() => mockRepository.getNearbyParishes(
            latitude: 35.6762,
            longitude: 139.6503,
            radiusKm: 10.0,
            massLanguage: null,
          )).called(1);
    });

    test('기본 반경이 10.0km로 설정되어야 함', () async {
      // Arrange
      final useCase = GetNearbyParishesUseCase(mockRepository);
      final testParishes = <ParishEntity>[];

      when(() => mockRepository.getNearbyParishes(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
            massLanguage: any(named: 'massLanguage'),
          )).thenAnswer((_) async => Right(testParishes));

      // Act
      await useCase.call(
        latitude: 35.6762,
        longitude: 139.6503,
      );

      // Assert
      verify(() => mockRepository.getNearbyParishes(
            latitude: 35.6762,
            longitude: 139.6503,
            radiusKm: 10.0,
            massLanguage: null,
          )).called(1);
    });
  });

  group('GetFavoriteParishesUseCase', () {
    test('즐겨찾기 교회 목록 조회가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = GetFavoriteParishesUseCase(mockRepository);
      final testParishes = [
        ParishEntity(
          parishId: 'parish1',
          name: 'Favorite Parish',
          prefecture: 'Tokyo',
          address: 'Favorite Address',
          latitude: 35.6762,
          longitude: 139.6503,
        ),
      ];

      when(() => mockRepository.getFavoriteParishes(any()))
          .thenAnswer((_) async => Right(testParishes));

      // Act
      final result = await useCase.call(['parish1', 'parish2']);

      // Assert
      expect(result, isA<Right<Failure, List<ParishEntity>>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (parishes) {
          expect(parishes, testParishes);
          expect(parishes.length, 1);
        },
      );
      verify(() => mockRepository.getFavoriteParishes(['parish1', 'parish2']))
          .called(1);
    });

    test('빈 목록이 전달되면 빈 결과를 반환해야 함', () async {
      // Arrange
      final useCase = GetFavoriteParishesUseCase(mockRepository);
      final testParishes = <ParishEntity>[];

      when(() => mockRepository.getFavoriteParishes(any()))
          .thenAnswer((_) async => Right(testParishes));

      // Act
      final result = await useCase.call([]);

      // Assert
      expect(result, isA<Right<Failure, List<ParishEntity>>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (parishes) => expect(parishes, isEmpty),
      );
    });
  });
}

