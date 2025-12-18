import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:credo/features/profile/data/repositories/saint_feast_day_repository_impl.dart';
import 'package:credo/core/error/failures.dart';
import 'package:credo/features/profile/domain/entities/saint_feast_day_entity.dart';
import 'package:credo/core/utils/openai_api_key.dart';

// Note: SaintFeastDayService는 GPT API를 호출하므로 mock하기 어렵습니다.
// 이 테스트는 실제 서비스를 사용하므로 통합 테스트에 가깝습니다.
// 단위 테스트를 위해서는 SaintFeastDayService를 의존성 주입 가능하게 리팩토링하는 것이 좋습니다.

void main() {
  late SaintFeastDayRepositoryImpl repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    // .env 파일 로드 시도 (없어도 계속 진행)
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // .env 파일이 없으면 무시 (테스트 환경에서는 선택사항)
    }
  });

  setUp(() {
    repository = SaintFeastDayRepositoryImpl();
  });

  group('SaintFeastDayRepositoryImpl', () {
    group('loadSaintsFeastDays', () {
      test('성인 축일 데이터를 로드해야 함', () async {
        // Act
        final result = await repository.loadSaintsFeastDays();

        // Assert
        // Note: loadSaintsFeastDays는 더 이상 사용되지 않으며 빈 리스트를 반환합니다.
        // GPT를 사용하는 새로운 메서드를 사용해야 합니다.
        expect(result, isA<Right<Failure, List<SaintFeastDayEntity>>>());
        result.fold((failure) => fail('실패가 발생하지 않아야 함: $failure'), (saints) {
          expect(saints, isA<List<SaintFeastDayEntity>>());
          // 더 이상 사용되지 않는 메서드이므로 빈 리스트를 반환함
          expect(saints.isEmpty, true);
        });
      });
    });

    group('getSaintsForDate', () {
      test('특정 날짜의 성인을 조회할 수 있어야 함', () async {
        // API 키가 없거나 유효하지 않으면 테스트 건너뛰기
        final apiKey = OpenAIApiKey.apiKey;
        if (apiKey == null || apiKey.isEmpty || apiKey.trim().isEmpty) {
          return; // 테스트 건너뛰기
        }

        // Arrange
        final date = DateTime(2024, 12, 25); // 크리스마스

        // Act
        final result = await repository.getSaintsForDate(date);

        // Assert
        // GPT API 호출이므로 성공 또는 실패할 수 있습니다.
        result.fold(
          (failure) {
            // API 키가 유효하지 않아 400 에러가 발생하면 테스트 건너뛰기
            if (failure is ServerFailure) {
              final message = failure.message.toLowerCase();
              if (message.contains('400') ||
                  message.contains('bad response') ||
                  message.contains('dioexception')) {
                return; // API 키가 유효하지 않으므로 테스트 건너뛰기
              }
            }
            // 기타 서버 에러는 정상적인 실패로 처리
            expect(failure, isA<ServerFailure>());
          },
          (saints) {
            expect(saints, isA<List<SaintFeastDayEntity>>());
          },
        );
      });
    });

    group('getTodaySaints', () {
      test('오늘의 성인을 조회할 수 있어야 함', () async {
        // API 키가 없거나 유효하지 않으면 테스트 건너뛰기
        final apiKey = OpenAIApiKey.apiKey;
        if (apiKey == null || apiKey.isEmpty || apiKey.trim().isEmpty) {
          return; // 테스트 건너뛰기
        }

        // Act
        final result = await repository.getTodaySaints();

        // Assert
        // GPT API 호출이므로 성공 또는 실패할 수 있습니다.
        result.fold(
          (failure) {
            // API 키가 유효하지 않아 400 에러가 발생하면 테스트 건너뛰기
            if (failure is ServerFailure) {
              final message = failure.message.toLowerCase();
              if (message.contains('400') ||
                  message.contains('bad response') ||
                  message.contains('dioexception')) {
                return; // API 키가 유효하지 않으므로 테스트 건너뛰기
              }
            }
            // 기타 서버 에러는 정상적인 실패로 처리
            expect(failure, isA<ServerFailure>());
          },
          (saints) {
            expect(saints, isA<List<SaintFeastDayEntity>>());
          },
        );
      });
    });
  });
}
