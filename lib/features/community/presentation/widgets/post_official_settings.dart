import 'package:flutter/material.dart';
import '../notifiers/post_form_notifier.dart';

/// 공식 계정 설정 위젯 (공지/핀 옵션)
class PostOfficialSettings extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                '公式アカウント設定',
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
            title: const Text('お知らせとして登録'),
            subtitle: const Text('教会メンバー全員に通知されます'),
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
            title: const Text('上部に固定'),
            subtitle: const Text('投稿リストの最上部に表示されます'),
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
