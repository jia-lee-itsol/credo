import 'package:flutter/material.dart';

/// 이용약관 동의 체크박스 위젯
class TermsAgreementCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color primaryColor;

  const TermsAgreementCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (newValue) => onChanged(newValue ?? false),
          activeColor: primaryColor,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(text: ''),
                  TextSpan(
                    text: '利用規約',
                    style: TextStyle(
                      color: primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' と '),
                  TextSpan(
                    text: 'プライバシーポリシー',
                    style: TextStyle(
                      color: primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' に同意します'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

