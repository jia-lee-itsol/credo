import 'package:flutter/material.dart';

/// 텍스트가 있는 구분선 위젯
class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Divider(color: theme.colorScheme.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text, style: theme.textTheme.bodySmall),
        ),
        Expanded(child: Divider(color: theme.colorScheme.outline)),
      ],
    );
  }
}

