import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/utils/location_utils.dart';
import '../../core/services/logger_service.dart';
import '../../core/data/services/geocoding_service.dart';

/// 사용자 현재 위치 Provider
/// 주의: 이 Provider는 자동으로 권한을 요청하지 않습니다.
/// 화면에서 명시적으로 권한을 요청한 후 사용해야 합니다.
final currentLocationProvider = FutureProvider<Position?>((ref) async {
  try {
    // 위치 서비스 활성화 확인
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.warning('위치 서비스가 비활성화되어 있습니다');
      return null;
    }

    // 위치 권한 확인 (자동 요청하지 않음)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      AppLogger.warning('위치 권한이 없습니다. 화면에서 권한을 요청해야 합니다.');
      return null;
    }

    // 현재 위치 가져오기
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    AppLogger.debug(
      '현재 위치: lat=${position.latitude}, lon=${position.longitude}',
    );
    return position;
  } catch (e, stackTrace) {
    AppLogger.error('위치 정보를 가져오는데 실패했습니다', e, stackTrace);
    return null;
  }
});

/// 사용자 위치 캐시 Provider (한 번 가져온 위치를 캐시)
final cachedLocationProvider = StateProvider<Position?>((ref) => null);

/// GeocodingService Provider
final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

/// 교회 좌표 Provider (주소를 좌표로 변환)
final parishCoordinatesProvider =
    FutureProvider.family<({double lat, double lon})?, Map<String, dynamic>>((
      ref,
      parish,
    ) async {
      // 이미 좌표가 있으면 사용
      final lat = parish['latitude'] as double?;
      final lon = parish['longitude'] as double?;
      if (lat != null && lon != null) {
        return (lat: lat, lon: lon);
      }

      // 주소가 없으면 null 반환
      final address = parish['address'] as String?;
      if (address == null || address.isEmpty) {
        return null;
      }

      // Google Maps Geocoding API를 사용하여 주소를 좌표로 변환
      final geocodingService = ref.watch(geocodingServiceProvider);
      return await geocodingService.addressToCoordinates(address);
    });

/// 교회와의 거리 계산 Provider
final parishDistanceProvider = Provider.family<double?, Map<String, dynamic>>((
  ref,
  parish,
) {
  final locationAsync = ref.watch(currentLocationProvider);
  final cachedLocation = ref.watch(cachedLocationProvider);
  final coordinatesAsync = ref.watch(parishCoordinatesProvider(parish));

  // 캐시된 위치가 있으면 사용, 없으면 비동기 위치 사용
  Position? userPosition;
  if (cachedLocation != null) {
    userPosition = cachedLocation;
  } else {
    userPosition = locationAsync.valueOrNull;
    // 위치를 가져오면 캐시에 저장
    if (userPosition != null) {
      ref.read(cachedLocationProvider.notifier).state = userPosition;
    }
  }

  if (userPosition == null) {
    return null;
  }

  // 교회 좌표 가져오기
  final coordinates = coordinatesAsync.valueOrNull;
  if (coordinates == null) {
    return null;
  }

  // 거리 계산
  final distance = LocationUtils.calculateDistance(
    userPosition.latitude,
    userPosition.longitude,
    coordinates.lat,
    coordinates.lon,
  );

  return distance;
});
