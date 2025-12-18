import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import '../repositories/notification_settings_repository_impl.dart';
import '../models/notification_settings.dart';

/// 알림 설정 Repository Provider
final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
  return NotificationSettingsRepositoryImpl();
});

/// 사용자의 알림 설정 Provider
final notificationSettingsProvider =
    StreamProvider.family<NotificationSettings, String>((ref, userId) {
  final repository = ref.watch(notificationSettingsRepositoryProvider);
  return repository.watchSettings(userId);
});

/// 사용자의 알림 설정 (Future) Provider
final notificationSettingsFutureProvider =
    FutureProvider.family<NotificationSettings, String>((ref, userId) async {
  final repository = ref.watch(notificationSettingsRepositoryProvider);
  final result = await repository.getSettings(userId);
  return result.fold(
    (failure) => const NotificationSettings(),
    (settings) => settings,
  );
});

