import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../core/services/logger_service.dart';

/// AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// 인증 상태 Provider (Stream)
final authStateStreamProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// 인증 상태 Provider (State)
final authStateProvider = StateProvider<UserEntity?>((ref) {
  final authStateAsync = ref.watch(authStateStreamProvider);
  return authStateAsync.valueOrNull;
});

/// 로그인 여부 확인 Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider);
  final isAuthenticated = user != null;
  AppLogger.auth('isAuthenticatedProvider: $isAuthenticated');
  if (user != null) {
    AppLogger.auth(
      '현재 사용자: userId=${user.userId}, email=${user.email}, nickname=${user.nickname}',
    );
  } else {
    AppLogger.auth('사용자가 null입니다');
  }
  return isAuthenticated;
});

/// 현재 사용자 Provider
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider);
});
