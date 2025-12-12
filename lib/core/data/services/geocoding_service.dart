import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/logger_service.dart';

/// Google Maps Geocoding API를 사용한 주소-좌표 변환 서비스
class GeocodingService {
  String get _apiKey {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GOOGLE_MAPS_API_KEY가 .env 파일에 설정되지 않았습니다.');
    }
    return key;
  }

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  final Dio _dio;

  GeocodingService({Dio? dio}) : _dio = dio ?? Dio();

  /// 주소를 좌표로 변환
  Future<({double lat, double lon})?> addressToCoordinates(
    String address,
  ) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'address': address,
          'key': _apiKey,
          'language': 'ja', // 일본어로 결과 반환
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final location =
              results.first['geometry']?['location'] as Map<String, dynamic>?;
          if (location != null) {
            final lat = location['lat'] as double;
            final lng = location['lng'] as double;
            AppLogger.debug('주소 변환 성공: $address -> ($lat, $lng)');
            return (lat: lat, lon: lng);
          }
        }
      }

      AppLogger.warning('주소를 좌표로 변환 실패: $address - 결과 없음');
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('주소를 좌표로 변환 실패: $address', e, stackTrace);
      return null;
    }
  }

  /// 좌표를 주소로 변환 (역지오코딩)
  Future<String?> coordinatesToAddress(double lat, double lon) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'latlng': '$lat,$lon',
          'key': _apiKey,
          'language': 'ja',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final formattedAddress =
              results.first['formatted_address'] as String?;
          return formattedAddress;
        }
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error('좌표를 주소로 변환 실패: ($lat, $lon)', e, stackTrace);
      return null;
    }
  }
}
