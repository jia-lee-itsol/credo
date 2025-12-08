import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/domain/entities/user_entity.dart';

/// 인증 상태 Provider
/// TODO: 실제 인증 구현 시 AuthRepository와 연결
final authStateProvider = StateProvider<UserEntity?>((ref) {
  // 현재는 null로 설정 (로그인하지 않은 상태)
  // 실제 구현 시 AuthRepository의 authStateChanges 스트림을 사용
  return null;
});

/// 로그인 여부 확인 Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider);
  return user != null;
});

/// 현재 사용자 Provider
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider);
});
