import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// 프로필 대부모·대자녀 섹션
class ProfileGodparentSection extends StatelessWidget {
  final Color primaryColor;
  final UserEntity? godparent;
  final List<String> godchildren;
  final Map<String, UserEntity> godchildrenMap;
  final VoidCallback onGodparentTap;
  final VoidCallback onAddGodchildTap;
  final VoidCallback onRemoveGodparent;
  final void Function(String userId) onRemoveGodchild;

  const ProfileGodparentSection({
    super.key,
    required this.primaryColor,
    this.godparent,
    required this.godchildren,
    required this.godchildrenMap,
    required this.onGodparentTap,
    required this.onAddGodchildTap,
    required this.onRemoveGodparent,
    required this.onRemoveGodchild,
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
              '代父母・代子・代女',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 대부모 선택
            InkWell(
              onTap: onGodparentTap,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '代父母 (1名のみ)',
                  suffixIcon: const Icon(Icons.chevron_right),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  godparent != null
                      ? '${godparent!.nickname} (${godparent!.email})'
                      : '選択してください',
                  style: TextStyle(
                    color: godparent != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (godparent != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(
                            ClipboardData(text: godparent!.userId),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ユーザーIDをコピーしました'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          'ユーザーID: ${godparent!.userId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onRemoveGodparent,
                      child: const Text('削除'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            // 대자녀 목록
            Row(
              children: [
                Expanded(
                  child: Text(
                    '代子・代女 (${godchildren.length}人)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddGodchildTap,
                  icon: const Icon(Icons.add),
                  label: const Text('追加'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (godchildren.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '登録された代子・代女がありません',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...godchildren.map((userId) {
                final user = godchildrenMap[userId];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: Icon(Icons.person, color: primaryColor, size: 20),
                    ),
                    title: Text(user?.nickname ?? '不明'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user != null) Text(user.email),
                        GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(text: userId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ユーザーIDをコピーしました'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            'ユーザーID: $userId',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.shade300,
                      onPressed: () => onRemoveGodchild(userId),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
