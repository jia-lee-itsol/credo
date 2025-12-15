import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/logger_service.dart';

/// 성경 텍스트 라이선스 상태 Provider
/// Firestore의 app_settings 컬렉션에서 bibleTextLicensed 필드를 확인합니다.
final bibleLicenseStatusProvider = StreamProvider<bool>((ref) {
  return FirebaseFirestore.instance
      .collection('app_settings')
      .doc('bible_license')
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) {
          AppLogger.warning(
            '[BibleLicenseProvider] app_settings/bible_license 문서가 존재하지 않습니다. 기본값 false를 반환합니다.',
          );
          return false;
        }

        final data = snapshot.data();
        final isLicensed = data?['bibleTextLicensed'] as bool? ?? false;

        AppLogger.debug('[BibleLicenseProvider] 라이선스 상태: $isLicensed');

        return isLicensed;
      })
      .handleError((error, stackTrace) {
        // 권한 오류 등 에러 발생 시 기본값 false 반환 (에러를 로깅만 하고 계속 진행)
        AppLogger.warning(
          '[BibleLicenseProvider] 라이선스 상태 확인 실패, 기본값 false 사용: $error',
        );
        return false;
      });
});

/// 성경 텍스트 라이선스 상태 (동기 버전)
/// StreamProvider의 현재 값을 반환합니다.
final bibleLicenseStatusSyncProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(bibleLicenseStatusProvider);
  return asyncValue.when(
    data: (isLicensed) => isLicensed,
    loading: () => false, // 로딩 중일 때는 기본값 false 반환
    error: (error, stackTrace) {
      AppLogger.error(
        '[BibleLicenseProvider] 동기 버전 에러: $error',
        error,
        stackTrace,
      );
      return false;
    },
  );
});
