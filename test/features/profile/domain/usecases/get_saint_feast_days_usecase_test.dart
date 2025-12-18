import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/profile/domain/usecases/get_saint_feast_days_usecase.dart';
import 'package:credo/features/profile/domain/repositories/saint_feast_day_repository.dart';
import 'package:credo/features/profile/domain/entities/saint_feast_day_entity.dart';
import 'package:credo/core/error/failures.dart';

// Mock classes
class MockSaintFeastDayRepository extends Mock
    implements SaintFeastDayRepository {}

void main() {
  late MockSaintFeastDayRepository mockRepository;

  setUp(() {
    mockRepository = MockSaintFeastDayRepository();
  });

  group('GetSaintsForDateUseCase', () {
    test('특정 날짜의 성인 축일 조회가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = GetSaintsForDateUseCase(mockRepository);
      final testDate = DateTime(2024, 12, 25);
      final testSaints = [
        SaintFeastDayEntity(
          month: 12,
          day: 25,
          name: 'イエス・キリストの降誕',
          nameEnglish: 'The Nativity of the Lord',
          type: 'solemnity',
          greeting: 'Merry Christmas',
        ),
      ];

      when(() => mockRepository.getSaintsForDate(any()))
          .thenAnswer((_) async => Right(testSaints));

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result, isA<Right<Failure, List<SaintFeastDayEntity>>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (saints) {
          expect(saints, testSaints);
          expect(saints.length, 1);
          expect(saints.first.name, 'イエス・キリストの降誕');
        },
      );
      verify(() => mockRepository.getSaintsForDate(testDate)).called(1);
    });

    test('여러 성인 축일이 있으면 모두 반환해야 함', () async {
      // Arrange
      final useCase = GetSaintsForDateUseCase(mockRepository);
      final testDate = DateTime(2024, 1, 1);
      final testSaints = [
        SaintFeastDayEntity(
          month: 1,
          day: 1,
          name: '神の母聖マリア',
          nameEnglish: 'Mary, Mother of God',
          type: 'solemnity',
          greeting: 'Happy New Year',
        ),
        SaintFeastDayEntity(
          month: 1,
          day: 1,
          name: '聖バジリオ',
          nameEnglish: 'Saint Basil',
          type: 'memorial',
          greeting: 'Greetings',
        ),
      ];

      when(() => mockRepository.getSaintsForDate(any()))
          .thenAnswer((_) async => Right(testSaints));

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result, isA<Right<Failure, List<SaintFeastDayEntity>>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (saints) {
          expect(saints, testSaints);
          expect(saints.length, 2);
        },
      );
    });

    test('성인 축일이 없으면 빈 목록을 반환해야 함', () async {
      // Arrange
      final useCase = GetSaintsForDateUseCase(mockRepository);
      final testDate = DateTime(2024, 6, 15);
      final testSaints = <SaintFeastDayEntity>[];

      when(() => mockRepository.getSaintsForDate(any()))
          .thenAnswer((_) async => Right(testSaints));

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result, isA<Right<Failure, List<SaintFeastDayEntity>>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (saints) => expect(saints, isEmpty),
      );
    });

    test('성인 축일 조회 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = GetSaintsForDateUseCase(mockRepository);
      final testDate = DateTime(2024, 12, 25);
      final failure = CacheFailure(message: 'Failed to load saints');

      when(() => mockRepository.getSaintsForDate(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result, isA<Left<Failure, List<SaintFeastDayEntity>>>());
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('실패가 발생해야 함'),
      );
    });
  });

  group('GetTodaySaintsUseCase', () {
    test('오늘의 성인 축일 조회가 성공하면 Right를 반환해야 함', () async {
      // Arrange
      final useCase = GetTodaySaintsUseCase(mockRepository);
      final testSaints = [
        SaintFeastDayEntity(
          month: DateTime.now().month,
          day: DateTime.now().day,
          name: '今日の聖人',
          nameEnglish: "Today's Saint",
          type: 'memorial',
          greeting: 'Greetings',
        ),
      ];

      when(() => mockRepository.getTodaySaints())
          .thenAnswer((_) async => Right(testSaints));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Right<Failure, List<SaintFeastDayEntity>>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (saints) {
          expect(saints, testSaints);
          expect(saints.length, 1);
        },
      );
      verify(() => mockRepository.getTodaySaints()).called(1);
    });

    test('오늘 성인 축일이 없으면 빈 목록을 반환해야 함', () async {
      // Arrange
      final useCase = GetTodaySaintsUseCase(mockRepository);
      final testSaints = <SaintFeastDayEntity>[];

      when(() => mockRepository.getTodaySaints())
          .thenAnswer((_) async => Right(testSaints));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Right<Failure, List<SaintFeastDayEntity>>>());
      result.fold(
        (failure) => fail('실패가 발생하지 않아야 함'),
        (saints) => expect(saints, isEmpty),
      );
    });

    test('오늘의 성인 축일 조회 실패 시 Failure를 반환해야 함', () async {
      // Arrange
      final useCase = GetTodaySaintsUseCase(mockRepository);
      final failure = CacheFailure(message: 'Failed to load today saints');

      when(() => mockRepository.getTodaySaints())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Left<Failure, List<SaintFeastDayEntity>>>());
      result.fold(
        (f) => expect(f, failure),
        (value) => fail('실패가 발생해야 함'),
      );
    });
  });
}

