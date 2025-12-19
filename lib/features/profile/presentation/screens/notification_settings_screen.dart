import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/data/services/push_notification_service.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../data/models/notification_settings.dart';
import '../../data/providers/notification_settings_providers.dart';

/// 알림 설정 화면
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isSaving = false;
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profile.notificationSettings)),
        body: Center(child: Text(l10n.profile.loginRequired)),
      );
    }

    final settingsAsync = ref.watch(
      notificationSettingsProvider(currentUser.userId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile.notificationSettings)),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsContent(
          context,
          theme,
          primaryColor,
          l10n,
          currentUser.userId,
          settings,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    AppLocalizations l10n,
    String userId,
    NotificationSettings settings,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 전체 알림 ON/OFF
        Card(
          child: SwitchListTile(
            title: Text(l10n.profile.notifications.enabled),
            subtitle: Text(l10n.profile.notifications.enabledDescription),
            value: settings.enabled,
            activeThumbColor: primaryColor,
            onChanged: _isSaving
                ? null
                : (value) {
                    _updateSettings(userId, settings.copyWith(enabled: value));
                  },
          ),
        ),

        const SizedBox(height: 16),

        // 알림 카테고리별 설정
        if (settings.enabled) ...[
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.campaign, color: primaryColor),
                  title: Text(l10n.profile.notifications.categories),
                  enabled: false,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(l10n.profile.notifications.notices),
                  subtitle: Text(l10n.profile.notifications.noticesDescription),
                  value: settings.notices,
                  activeThumbColor: primaryColor,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          _updateSettings(
                            userId,
                            settings.copyWith(notices: value),
                          );
                        },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(l10n.profile.notifications.comments),
                  subtitle: Text(
                    l10n.profile.notifications.commentsDescription,
                  ),
                  value: settings.comments,
                  activeThumbColor: primaryColor,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          _updateSettings(
                            userId,
                            settings.copyWith(comments: value),
                          );
                        },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(l10n.profile.notifications.likes),
                  subtitle: Text(l10n.profile.notifications.likesDescription),
                  value: settings.likes,
                  activeThumbColor: primaryColor,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          _updateSettings(
                            userId,
                            settings.copyWith(likes: value),
                          );
                        },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(l10n.profile.notifications.dailyMass),
                  subtitle: Text(
                    l10n.profile.notifications.dailyMassDescription,
                  ),
                  value: settings.dailyMass,
                  activeThumbColor: primaryColor,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          _updateSettings(
                            userId,
                            settings.copyWith(dailyMass: value),
                          );
                        },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 조용한 시간 설정
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.bedtime, color: primaryColor),
                  title: Text(l10n.profile.notifications.quietHours),
                  subtitle: Text(
                    l10n.profile.notifications.quietHoursDescription,
                  ),
                  value: settings.quietHoursEnabled,
                  activeThumbColor: primaryColor,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          _updateSettings(
                            userId,
                            settings.copyWith(quietHoursEnabled: value),
                          );
                        },
                ),
                if (settings.quietHoursEnabled) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker(
                            context,
                            theme,
                            primaryColor,
                            l10n,
                            l10n.profile.notifications.quietHoursStart,
                            settings.quietHoursStart,
                            (hour) {
                              _updateSettings(
                                userId,
                                settings.copyWith(quietHoursStart: hour),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('〜', style: theme.textTheme.titleLarge),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimePicker(
                            context,
                            theme,
                            primaryColor,
                            l10n,
                            l10n.profile.notifications.quietHoursEnd,
                            settings.quietHoursEnd,
                            (hour) {
                              _updateSettings(
                                userId,
                                settings.copyWith(quietHoursEnd: hour),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 32),

        // FCM 테스트 버튼
        Card(
          child: ListTile(
            leading: Icon(Icons.send, color: primaryColor),
            title: Text(l10n.profile.notifications.testNotification),
            subtitle: Text(l10n.profile.notifications.testNotificationDescription),
            trailing: _isTesting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
            onTap: _isTesting ? null : _sendTestNotification,
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    AppLocalizations l10n,
    String label,
    int hour,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSaving
              ? null
              : () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: hour, minute: 0),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(primary: primaryColor),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    onChanged(picked.hour);
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: theme.textTheme.bodyLarge,
                ),
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateSettings(
    String userId,
    NotificationSettings newSettings,
  ) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final repository = ref.read(notificationSettingsRepositoryProvider);
    final result = await repository.saveSettings(userId, newSettings);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    final l10n = ref.read(appLocalizationsSyncProvider);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profile.notifications.saved),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  Future<void> _sendTestNotification() async {
    if (_isTesting) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isTesting = true;
    });

    final l10n = ref.read(appLocalizationsSyncProvider);
    final service = PushNotificationService();

    // 테스트 알림 전에 FCM 토큰 갱신 및 저장 시도
    final tokenRefreshed = await service.refreshAndSaveToken(currentUser.userId);
    if (!tokenRefreshed) {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
      });

      // iOS 시뮬레이터에서는 푸시 알림이 작동하지 않음
      final errorMessage = Theme.of(context).platform == TargetPlatform.iOS
          ? 'iOS 시뮬레이터에서는 푸시 알림을 테스트할 수 없습니다. 실제 기기에서 테스트해주세요.'
          : 'FCM 토큰을 가져올 수 없습니다. 알림 권한을 확인하고 앱을 재시작해주세요.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final result = await service.sendTestNotification();

    if (!mounted) return;

    setState(() {
      _isTesting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? l10n.profile.notifications.testNotificationSent),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
