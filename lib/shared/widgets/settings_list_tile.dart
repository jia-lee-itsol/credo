import 'package:flutter/material.dart';

/// 설정 항목용 공통 ListTile 위젯
/// 아이콘 + 타이틀 + 서브타이틀(옵션) + chevron 형태
class SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color primaryColor;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.primaryColor,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
