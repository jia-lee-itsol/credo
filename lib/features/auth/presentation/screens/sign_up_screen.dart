import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../config/routes/app_routes.dart';
import '../widgets/password_field.dart';
import '../widgets/loading_button.dart';
import '../widgets/terms_agreement_checkbox.dart';

/// 회원가입 화면
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = true;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 닉네임 입력
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: 'ニックネーム',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: Validators.validateNickname,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // 이메일 입력
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // 비밀번호 입력
                PasswordField(
                  controller: _passwordController,
                  helperText: '8文字以上で入力してください',
                  validator: Validators.validatePassword,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // 비밀번호 확인
                PasswordField(
                  controller: _confirmPasswordController,
                  labelText: 'パスワード（確認）',
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'パスワードが一致しません';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                // 이용약관 동의
                TermsAgreementCheckbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value;
                    });
                  },
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 24),

                // 회원가입 버튼
                LoadingButton(
                  onPressed: _signUp,
                  label: 'アカウントを作成',
                  backgroundColor: primaryColor,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),

                // 로그인 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('すでにアカウントをお持ちですか？', style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('ログイン'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    debugPrint('🔵 [SignUp] 회원가입 버튼 클릭됨');

    if (!_formKey.currentState!.validate()) {
      debugPrint('🔴 [SignUp] 폼 검증 실패');
      return;
    }
    debugPrint('✅ [SignUp] 폼 검증 통과');

    if (!_agreeToTerms) {
      debugPrint('🔴 [SignUp] 이용약관 미동의');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('利用規約とプライバシーポリシーに同意してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    debugPrint('✅ [SignUp] 이용약관 동의 확인');

    debugPrint('🟡 [SignUp] 로딩 상태: true로 변경');
    setState(() {
      _isLoading = true;
    });
    debugPrint('🟡 [SignUp] 현재 로딩 상태: $_isLoading');

    try {
      debugPrint('🟡 [SignUp] Repository 가져오기 시작');
      final repository = ref.read(authRepositoryProvider);
      debugPrint('🟡 [SignUp] signUpWithEmail 호출 시작');
      debugPrint('🟡 [SignUp] 이메일: ${_emailController.text.trim()}');
      debugPrint('🟡 [SignUp] 닉네임: ${_nicknameController.text.trim()}');

      final result = await repository.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nickname: _nicknameController.text.trim(),
      );

      debugPrint('🟢 [SignUp] signUpWithEmail 완료');
      debugPrint('🟢 [SignUp] 결과 타입: ${result.runtimeType}');

      if (!mounted) {
        debugPrint('🔴 [SignUp] Widget이 unmount됨');
        return;
      }

      debugPrint('🟡 [SignUp] 로딩 상태: false로 변경 시작');
      // 로딩 상태를 먼저 false로 설정
      setState(() {
        _isLoading = false;
      });
      debugPrint('🟢 [SignUp] 로딩 상태: false로 변경 완료');
      debugPrint('🟢 [SignUp] 현재 로딩 상태: $_isLoading');

      result.fold(
        (failure) {
          debugPrint('🔴 [SignUp] 회원가입 실패: ${failure.message}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (user) {
          debugPrint('🟢 [SignUp] 회원가입 성공!');
          debugPrint('🟢 [SignUp] 사용자 ID: ${user.userId}');
          debugPrint('🟢 [SignUp] 사용자 이메일: ${user.email}');

          if (mounted) {
            debugPrint('🟢 [SignUp] 스낵바 표시 시작');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('アカウントを作成しました'),
                backgroundColor: Colors.green,
              ),
            );
            debugPrint('🟢 [SignUp] 스낵바 표시 완료');

            debugPrint('🟢 [SignUp] 페이지 이동 스케줄링');
            // 다음 프레임에서 페이지 이동 (로딩 상태가 UI에 반영된 후)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              debugPrint('🟢 [SignUp] addPostFrameCallback 실행됨');
              if (mounted) {
                debugPrint('🟢 [SignUp] 로그인 페이지로 이동 시작');
                context.go(AppRoutes.signIn);
                debugPrint('🟢 [SignUp] 로그인 페이지로 이동 완료');
              } else {
                debugPrint('🔴 [SignUp] 페이지 이동 시도했지만 Widget이 unmount됨');
              }
            });
          } else {
            debugPrint('🔴 [SignUp] 성공했지만 Widget이 unmount됨');
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('🔴 [SignUp] 예외 발생: $e');
      debugPrint('🔴 [SignUp] 스택 트레이스: $stackTrace');
      if (mounted) {
        debugPrint('🟡 [SignUp] 예외 처리: 로딩 상태 false로 변경');
        setState(() {
          _isLoading = false;
        });
        debugPrint('🟢 [SignUp] 예외 처리: 로딩 상태 변경 완료');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('登録に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    debugPrint('🔵 [SignUp] _signUp 함수 종료');
    debugPrint('🔵 [SignUp] 최종 로딩 상태: $_isLoading');
  }
}
