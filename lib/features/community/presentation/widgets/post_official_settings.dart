import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';
import '../notifiers/post_form_notifier.dart';

/// 공식 계정 설정 위젯 (공지/핀 옵션)
class PostOfficialSettings extends ConsumerWidget {
  final PostFormState formState;
  final PostFormNotifier notifier;
  final Color primaryColor;

  const PostOfficialSettings({
    super.key,
    required this.formState,
    required this.notifier,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                l10n.community.officialAccountSettings,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 공지로 등록 체크박스
          CheckboxListTile(
            value: formState.isOfficial,
            onChanged: (value) {
              notifier.setIsOfficial(value ?? false);
            },
            title: Text(l10n.community.registerAsNotice),
            subtitle: Text(l10n.community.registerAsNoticeSubtitle),
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: primaryColor,
          ),
          // 핀 처리 체크박스
          CheckboxListTile(
            value: formState.isPinned,
            onChanged: (value) {
              notifier.setIsPinned(value ?? false);
            },
            title: Text(l10n.community.pinToTop),
            subtitle: Text(l10n.community.pinToTopSubtitle),
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }
}
