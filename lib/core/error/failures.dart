import 'package:equatable/equatable.dart';

/// 에러 베이스 클래스
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// 서버 에러
class ServerFailure extends Failure {
  const ServerFailure({super.message = '서버 오류가 발생했습니다.', super.code});
}

/// 네트워크 에러
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = '네트워크 연결을 확인해주세요.', super.code});
}

/// 캐시 에러
class CacheFailure extends Failure {
  const CacheFailure({super.message = '캐시 오류가 발생했습니다.', super.code});
}

/// 인증 에러
class AuthFailure extends Failure {
  const AuthFailure({super.message = '인증에 실패했습니다.', super.code});
}

/// 권한 에러
class PermissionFailure extends Failure {
  const PermissionFailure({super.message = '권한이 없습니다.', super.code});
}

/// 위치 권한 에러
class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure({
    super.message = '위치 권한이 필요합니다.',
    super.code,
  });
}

/// 유효성 검사 에러
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// 데이터 없음 에러
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = '데이터를 찾을 수 없습니다.', super.code});
}

/// Firebase 에러
class FirebaseFailure extends Failure {
  const FirebaseFailure({super.message = 'Firebase 오류가 발생했습니다.', super.code});
}

/// 구현되지 않은 기능 에러
class NotImplementedFailure extends Failure {
  const NotImplementedFailure({required super.message, super.code});
}

/// 알 수 없는 에러
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = '알 수 없는 오류가 발생했습니다.', super.code});
}
