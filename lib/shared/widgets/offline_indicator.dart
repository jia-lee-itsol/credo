import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import '../../core/utils/app_localizations.dart';

/// 오프라인 상태 표시 위젯
/// 화면 상단에 오프라인 상태일 때 배너를 표시합니다.
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);

    if (!isOffline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade700,
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.common.offlineMode ?? '오프라인 모드',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 동기화 상태 표시 위젯
class SyncStatusIndicator extends ConsumerWidget {
  final bool isSyncing;
  final String? syncMessage;

  const SyncStatusIndicator({
    super.key,
    this.isSyncing = false,
    this.syncMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isSyncing) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade700,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              syncMessage ?? '동기화 중...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

