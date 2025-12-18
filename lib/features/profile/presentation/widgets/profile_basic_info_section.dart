import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/app_localizations.dart';

/// 프로필 기본 정보 섹션
class ProfileBasicInfoSection extends ConsumerWidget {
  final TextEditingController nicknameController;
  final String? email;
  final String? userId;
  final String? baptismalName;
  final int? feastDayMonth;
  final int? feastDayDay;
  final void Function(int?) onMonthChanged;
  final void Function(int?) onDayChanged;

  const ProfileBasicInfoSection({
    super.key,
    required this.nicknameController,
    this.email,
    this.userId,
    this.baptismalName,
    this.feastDayMonth,
    this.feastDayDay,
    required this.onMonthChanged,
    required this.onDayChanged,
  });

  int _getDaysInMonth(int month) {
    const daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.profile.basicInfo.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 닉네임 입력
            TextFormField(
              controller: nicknameController,
              decoration: InputDecoration(
                labelText: l10n.auth.nickname,
                hintText: l10n.validation.nicknameRequired,
              ),
              validator: (value) => Validators.validateNickname(value, l10n),
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            // 이메일 (읽기 전용)
            TextFormField(
              initialValue: email ?? '',
              decoration: InputDecoration(labelText: l10n.auth.email),
              enabled: false,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profile.basicInfo.emailCannotChange,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // 유저 ID (읽기 전용)
            GestureDetector(
              onLongPress: userId != null
                  ? () {
                      Clipboard.setData(ClipboardData(text: userId!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.profile.userIdCopied),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
              child: TextFormField(
                initialValue: userId ?? '',
                decoration: InputDecoration(labelText: l10n.profile.userId),
                enabled: false,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profile.basicInfo.userIdCannotChange,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // 세례명 (읽기 전용)
            TextFormField(
              initialValue: baptismalName ?? l10n.common.notSet,
              decoration: InputDecoration(labelText: l10n.auth.baptismName),
              enabled: false,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profile.basicInfo.baptismNameCannotChange,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // 축일 - 월/일 선택
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: feastDayMonth,
                    decoration: InputDecoration(
                      labelText: l10n.profile.month,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...List.generate(12, (i) => i + 1).map(
                        (m) => DropdownMenuItem(value: m, child: Text('$m')),
                      ),
                    ],
                    onChanged: onMonthChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: feastDayDay,
                    decoration: InputDecoration(
                      labelText: l10n.profile.day,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...List.generate(
                        feastDayMonth != null
                            ? _getDaysInMonth(feastDayMonth!)
                            : 31,
                        (i) => i + 1,
                      ).map(
                        (d) => DropdownMenuItem(value: d, child: Text('$d')),
                      ),
                    ],
                    onChanged: onDayChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
