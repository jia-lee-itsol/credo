import 'dart:math' as math;

/// 위치 관련 유틸리티
class LocationUtils {
  LocationUtils._();

  /// 두 좌표 간 거리 계산 (Haversine formula)
  /// 반환값: 킬로미터
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // 지구 반지름 (km)

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  /// 거리 포맷팅
  static String formatDistance(double distanceKm, {String locale = 'ja'}) {
    if (distanceKm < 1) {
      final meters = (distanceKm * 1000).round();
      return '${meters}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  /// 거리에 따른 표시 레이블 (일본어)
  static String getDistanceLabel(double distanceKm) {
    if (distanceKm < 0.5) {
      return '徒歩圏内';
    } else if (distanceKm < 2) {
      return '近く';
    } else if (distanceKm < 10) {
      return '周辺';
    } else {
      return '遠方';
    }
  }

  /// 위도/경도 유효성 검사
  static bool isValidCoordinate(double? lat, double? lon) {
    if (lat == null || lon == null) return false;
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }

  /// 일본 내 좌표인지 확인 (대략적인 범위)
  static bool isInJapan(double lat, double lon) {
    // 일본의 대략적인 좌표 범위
    // 북위 24~46도, 동경 122~154도
    return lat >= 24 && lat <= 46 && lon >= 122 && lon <= 154;
  }
}
