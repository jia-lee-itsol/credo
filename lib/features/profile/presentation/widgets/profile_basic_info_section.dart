import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/validators.dart';

/// 프로필 기본 정보 섹션
class ProfileBasicInfoSection extends StatelessWidget {
  final TextEditingController nicknameController;
  final String? email;
  final String? userId;
  final String? baptismalName;

  const ProfileBasicInfoSection({
    super.key,
    required this.nicknameController,
    this.email,
    this.userId,
    this.baptismalName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本情報',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 닉네임 입력
            TextFormField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: 'ニックネーム',
                hintText: 'ニックネームを入力してください',
              ),
              validator: Validators.validateNickname,
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            // 이메일 (읽기 전용)
            TextFormField(
              initialValue: email ?? '',
              decoration: const InputDecoration(labelText: 'メールアドレス'),
              enabled: false,
            ),
            const SizedBox(height: 8),
            Text(
              'メールアドレスは変更できません',
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
                        const SnackBar(
                          content: Text('ユーザーIDをコピーしました'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
              child: TextFormField(
                initialValue: userId ?? '',
                decoration: const InputDecoration(labelText: 'ユーザーID'),
                enabled: false,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ユーザーIDは変更できません（長押しでコピー）',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // 세례명 (읽기 전용)
            TextFormField(
              initialValue: baptismalName ?? '未設定',
              decoration: const InputDecoration(labelText: '洗礼名'),
              enabled: false,
            ),
            const SizedBox(height: 8),
            Text(
              '洗礼名は変更できません',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
