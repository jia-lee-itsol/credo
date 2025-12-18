import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/logger_service.dart';

/// 네트워크 연결 상태
enum ConnectivityStatus {
  /// 온라인 (인터넷 연결됨)
  online,
  
  /// 오프라인 (인터넷 연결 안 됨)
  offline,
  
  /// 확인 중
  checking,
}

/// 네트워크 연결 상태 Provider
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) async* {
  final connectivity = Connectivity();
  
  // 초기 상태: 확인 중
  yield ConnectivityStatus.checking;
  
  try {
    // 현재 연결 상태 확인
    final result = await connectivity.checkConnectivity();
    yield _mapConnectivityResult(result);
    
    // 연결 상태 변경 감지
    await for (final result in connectivity.onConnectivityChanged) {
      yield _mapConnectivityResult(result);
    }
  } catch (e, stackTrace) {
    AppLogger.error('네트워크 상태 확인 실패', e, stackTrace);
    yield ConnectivityStatus.offline;
  }
});

/// ConnectivityResult를 ConnectivityStatus로 변환
ConnectivityStatus _mapConnectivityResult(List<ConnectivityResult> results) {
  // none이 없으면 온라인
  if (results.contains(ConnectivityResult.none)) {
    AppLogger.debug('네트워크 상태: 오프라인');
    return ConnectivityStatus.offline;
  }
  
  AppLogger.debug('네트워크 상태: 온라인 (${results.join(", ")})');
  return ConnectivityStatus.online;
}

/// 현재 온라인 상태인지 확인하는 Provider
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStatusProvider);
  
  return connectivityAsync.when(
    data: (status) => status == ConnectivityStatus.online,
    loading: () => true, // 로딩 중일 때는 온라인으로 가정
    error: (_, __) => false, // 에러 시 오프라인으로 가정
  );
});

/// 현재 오프라인 상태인지 확인하는 Provider
final isOfflineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStatusProvider);
  
  return connectivityAsync.when(
    data: (status) => status == ConnectivityStatus.offline,
    loading: () => false,
    error: (_, __) => true,
  );
});

