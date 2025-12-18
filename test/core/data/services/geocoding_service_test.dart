import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/core/data/services/geocoding_service.dart';

// Mock classes
class MockDio extends Mock implements Dio {}

void main() {
  late GeocodingService service;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    service = GeocodingService(dio: mockDio);
  });

  group('GeocodingService - addressToCoordinates', () {
    test('주소를 좌표로 변환 성공 시 좌표를 반환해야 함', () async {
      // Arrange
      final response = Response(
        data: {
          'results': [
            {
              'geometry': {
                'location': {
                  'lat': 35.6762,
                  'lng': 139.6503,
                }
              }
            }
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      // Act
      final result = await service.addressToCoordinates('東京都千代田区');

      // Assert
      expect(result, isNotNull);
      expect(result?.lat, 35.6762);
      expect(result?.lon, 139.6503);
      verify(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('결과가 없으면 null을 반환해야 함', () async {
      // Arrange
      final response = Response(
        data: {
          'results': [],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      // Act
      final result = await service.addressToCoordinates('존재하지 않는 주소');

      // Assert
      expect(result, isNull);
    });

    test('geometry가 없으면 null을 반환해야 함', () async {
      // Arrange
      final response = Response(
        data: {
          'results': [
            {
              'geometry': null,
            }
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      // Act
      final result = await service.addressToCoordinates('주소');

      // Assert
      expect(result, isNull);
    });

    test('location이 없으면 null을 반환해야 함', () async {
      // Arrange
      final response = Response(
        data: {
          'results': [
            {
              'geometry': {},
            }
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      // Act
      final result = await service.addressToCoordinates('주소');

      // Assert
      expect(result, isNull);
    });

    test('에러 발생 시 null을 반환해야 함', () async {
      // Arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Network error',
      ));

      // Act
      final result = await service.addressToCoordinates('주소');

      // Assert
      expect(result, isNull);
    });

    test('statusCode가 200이 아니면 null을 반환해야 함', () async {
      // Arrange
      final response = Response(
        data: {},
        statusCode: 400,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      // Act
      final result = await service.addressToCoordinates('주소');

      // Assert
      expect(result, isNull);
    });
  });

  group('GeocodingService - coordinatesToAddress', () {
    test('좌표를 주소로 변환 성공 시 주소를 반환해야 함', () async {
      // Arrange
      final response = Response(
        data: {
          'results': [
            {
              'formatted_address': '東京都千代田区丸の内1-1-1',
            }
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      // Act
      final result = await service.coordinatesToAddress(35.6762, 139.6503);

      // Assert
      expect(result, '東京都千代田区丸の内1-1-1');
      verify(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('결과가 없으면 null을 반환해야 함', () async {
      // Arrange
      final response = Response(
        data: {
          'results': [],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      // Act
      final result = await service.coordinatesToAddress(0.0, 0.0);

      // Assert
      expect(result, isNull);
    });

    test('formatted_address가 없으면 null을 반환해야 함', () async {
      // Arrange
      final response = Response(
        data: {
          'results': [
            {},
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      // Act
      final result = await service.coordinatesToAddress(35.6762, 139.6503);

      // Assert
      expect(result, isNull);
    });

    test('에러 발생 시 null을 반환해야 함', () async {
      // Arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Network error',
      ));

      // Act
      final result = await service.coordinatesToAddress(35.6762, 139.6503);

      // Assert
      expect(result, isNull);
    });

    test('statusCode가 200이 아니면 null을 반환해야 함', () async {
      // Arrange
      final response = Response(
        data: {},
        statusCode: 400,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => response);

      // Act
      final result = await service.coordinatesToAddress(35.6762, 139.6503);

      // Assert
      expect(result, isNull);
    });
  });
}

