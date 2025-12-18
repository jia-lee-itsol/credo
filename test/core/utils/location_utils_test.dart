import 'package:flutter_test/flutter_test.dart';
import 'package:credo/core/utils/location_utils.dart';

void main() {
  group('LocationUtils - calculateDistance', () {
    test('같은 좌표는 0km를 반환해야 함', () {
      // Act
      final distance = LocationUtils.calculateDistance(
        35.6762,
        139.6503,
        35.6762,
        139.6503,
      );

      // Assert
      expect(distance, closeTo(0.0, 0.01));
    });

    test('도쿄와 오사카 간 거리를 계산해야 함', () {
      // Arrange
      // 도쿄: 35.6762, 139.6503
      // 오사카: 34.6937, 135.5023
      // 실제 거리: 약 400km

      // Act
      final distance = LocationUtils.calculateDistance(
        35.6762,
        139.6503,
        34.6937,
        135.5023,
      );

      // Assert
      expect(distance, greaterThan(350));
      expect(distance, lessThan(450));
    });

    test('서로 다른 좌표 간 거리를 정확히 계산해야 함', () {
      // Arrange
      // 서울: 37.5665, 126.9780
      // 부산: 35.1796, 129.0756
      // 실제 거리: 약 325km

      // Act
      final distance = LocationUtils.calculateDistance(
        37.5665,
        126.9780,
        35.1796,
        129.0756,
      );

      // Assert
      expect(distance, greaterThan(300));
      expect(distance, lessThan(350));
    });
  });

  group('LocationUtils - formatDistance', () {
    test('1km 미만은 미터 단위로 표시해야 함', () {
      // Act
      final formatted = LocationUtils.formatDistance(0.5);

      // Assert
      expect(formatted, '500m');
    });

    test('1km 이상 10km 미만은 소수점 1자리로 표시해야 함', () {
      // Act
      final formatted = LocationUtils.formatDistance(5.7);

      // Assert
      expect(formatted, '5.7km');
    });

    test('10km 이상은 정수로 표시해야 함', () {
      // Act
      final formatted = LocationUtils.formatDistance(15.8);

      // Assert
      expect(formatted, '16km');
    });

    test('0.1km 미만도 미터 단위로 표시해야 함', () {
      // Act
      final formatted = LocationUtils.formatDistance(0.05);

      // Assert
      expect(formatted, '50m');
    });
  });

  group('LocationUtils - getDistanceLabel', () {
    test('0.5km 미만은 "徒歩圏内"를 반환해야 함', () {
      // Act
      final label = LocationUtils.getDistanceLabel(0.3);

      // Assert
      expect(label, '徒歩圏内');
    });

    test('0.5km 이상 2km 미만은 "近く"를 반환해야 함', () {
      // Act
      final label = LocationUtils.getDistanceLabel(1.0);

      // Assert
      expect(label, '近く');
    });

    test('2km 이상 10km 미만은 "周辺"를 반환해야 함', () {
      // Act
      final label = LocationUtils.getDistanceLabel(5.0);

      // Assert
      expect(label, '周辺');
    });

    test('10km 이상은 "遠方"을 반환해야 함', () {
      // Act
      final label = LocationUtils.getDistanceLabel(15.0);

      // Assert
      expect(label, '遠方');
    });
  });

  group('LocationUtils - isValidCoordinate', () {
    test('유효한 좌표는 true를 반환해야 함', () {
      // Act & Assert
      expect(LocationUtils.isValidCoordinate(35.6762, 139.6503), isTrue);
      expect(LocationUtils.isValidCoordinate(0.0, 0.0), isTrue);
      expect(LocationUtils.isValidCoordinate(-90.0, -180.0), isTrue);
      expect(LocationUtils.isValidCoordinate(90.0, 180.0), isTrue);
    });

    test('null 좌표는 false를 반환해야 함', () {
      // Act & Assert
      expect(LocationUtils.isValidCoordinate(null, 139.6503), isFalse);
      expect(LocationUtils.isValidCoordinate(35.6762, null), isFalse);
      expect(LocationUtils.isValidCoordinate(null, null), isFalse);
    });

    test('위도가 범위를 벗어나면 false를 반환해야 함', () {
      // Act & Assert
      expect(LocationUtils.isValidCoordinate(91.0, 139.6503), isFalse);
      expect(LocationUtils.isValidCoordinate(-91.0, 139.6503), isFalse);
    });

    test('경도가 범위를 벗어나면 false를 반환해야 함', () {
      // Act & Assert
      expect(LocationUtils.isValidCoordinate(35.6762, 181.0), isFalse);
      expect(LocationUtils.isValidCoordinate(35.6762, -181.0), isFalse);
    });
  });

  group('LocationUtils - isInJapan', () {
    test('일본 내 좌표는 true를 반환해야 함', () {
      // Act & Assert
      expect(LocationUtils.isInJapan(35.6762, 139.6503), isTrue); // 도쿄
      expect(LocationUtils.isInJapan(34.6937, 135.5023), isTrue); // 오사카
      expect(LocationUtils.isInJapan(43.0642, 141.3469), isTrue); // 삿포로
    });

    test('일본 밖 좌표는 false를 반환해야 함', () {
      // Act & Assert
      expect(LocationUtils.isInJapan(37.5665, 126.9780), isFalse); // 서울
      expect(LocationUtils.isInJapan(40.7128, -74.0060), isFalse); // 뉴욕
      expect(LocationUtils.isInJapan(51.5074, -0.1278), isFalse); // 런던
    });

    test('일본 경계 좌표도 true를 반환해야 함', () {
      // Act & Assert
      expect(LocationUtils.isInJapan(24.0, 122.0), isTrue);
      expect(LocationUtils.isInJapan(46.0, 154.0), isTrue);
    });

    test('일본 경계 밖 좌표는 false를 반환해야 함', () {
      // Act & Assert
      expect(LocationUtils.isInJapan(23.9, 122.0), isFalse);
      expect(LocationUtils.isInJapan(46.1, 154.0), isFalse);
      expect(LocationUtils.isInJapan(35.0, 121.9), isFalse);
      expect(LocationUtils.isInJapan(35.0, 154.1), isFalse);
    });
  });
}

