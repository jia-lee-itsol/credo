/// 서버 예외
class ServerException implements Exception {
  final String? message;
  final int? statusCode;

  const ServerException({
    this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// 네트워크 예외
class NetworkException implements Exception {
  final String? message;

  const NetworkException({this.message});

  @override
  String toString() => 'NetworkException: $message';
}

/// 캐시 예외
class CacheException implements Exception {
  final String? message;

  const CacheException({this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// 인증 예외
class AuthException implements Exception {
  final String? message;
  final String? code;

  const AuthException({
    this.message,
    this.code,
  });

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

/// 유효성 검사 예외
class ValidationException implements Exception {
  final String message;
  final String? field;

  const ValidationException({
    required this.message,
    this.field,
  });

  @override
  String toString() => 'ValidationException: $message (field: $field)';
}

/// 데이터 없음 예외
class NotFoundException implements Exception {
  final String? message;

  const NotFoundException({this.message});

  @override
  String toString() => 'NotFoundException: $message';
}

/// 위치 권한 예외
class LocationPermissionException implements Exception {
  final String? message;

  const LocationPermissionException({this.message});

  @override
  String toString() => 'LocationPermissionException: $message';
}
