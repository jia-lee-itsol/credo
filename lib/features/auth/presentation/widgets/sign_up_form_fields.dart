import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/app_localizations.dart';
import 'password_field.dart';

/// 회원가입 기본 입력 필드 위젯
class SignUpFormFields extends StatelessWidget {
  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController baptismalNameController;
  final AppLocalizations l10n;

  const SignUpFormFields({
    super.key,
    required this.nicknameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.baptismalNameController,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 닉네임 입력
        TextFormField(
          controller: nicknameController,
          decoration: InputDecoration(
            labelText: l10n.auth.nickname,
            prefixIcon: const Icon(Icons.person_outlined),
          ),
          validator: (value) => Validators.validateNickname(value, l10n),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // 이메일 입력
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: l10n.auth.email,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => Validators.validateEmail(value, l10n),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // 비밀번호 입력
        PasswordField(
          controller: passwordController,
          labelText: l10n.auth.password,
          helperText: l10n.validation.passwordMinLength,
          validator: (value) => Validators.validatePassword(value, l10n),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // 비밀번호 확인
        PasswordField(
          controller: confirmPasswordController,
          labelText: l10n.auth.passwordConfirm,
          validator: (value) {
            if (value != passwordController.text) {
              return l10n.auth.passwordMismatch;
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // 세례명 입력
        TextFormField(
          controller: baptismalNameController,
          decoration: InputDecoration(
            labelText: l10n.auth.baptismName,
            prefixIcon: const Icon(Icons.badge_outlined),
            hintText: l10n.auth.baptismNameHint,
          ),
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}

