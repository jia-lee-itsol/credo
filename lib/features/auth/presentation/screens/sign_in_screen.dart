import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../config/routes/app_routes.dart';
import '../widgets/password_field.dart';
import '../widgets/loading_button.dart';
import '../widgets/auth_logo_header.dart';
import '../widgets/social_login_button.dart';
import '../widgets/divider_with_text.dart';
import '../widgets/password_reset_dialog.dart';

/// 로그인 화면
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 저장된 이메일 불러오기
  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (mounted) {
        setState(() {
          _rememberMe = rememberMe;
          if (savedEmail != null && rememberMe) {
            _emailController.text = savedEmail;
          }
        });
      }
    } catch (e) {
      // 에러 무시
    }
  }

  /// 이메일 저장
  Future<void> _saveEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      // 에러 무시
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final backgroundColor = ref.watch(liturgyBackgroundColorProvider);

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // 키보드 이외의 영역을 탭하면 키보드 숨김
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 로고 헤더
                  AuthLogoHeader(
                    primaryColor: primaryColor,
                    backgroundColor: backgroundColor,
                    subtitle: '信仰でつながる',
                  ),

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
                    validator: Validators.validatePassword,
                    onFieldSubmitted: (_) => _signIn(),
                  ),
                  const SizedBox(height: 8),

                  // 나의 정보 저장 체크박스
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                        activeColor: primaryColor,
                      ),
                      const Text('メールアドレスを保存'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 비밀번호 찾기
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      child: const Text('パスワードをお忘れですか？'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 로그인 버튼
                  LoadingButton(
                    onPressed: _signIn,
                    label: 'ログイン',
                    backgroundColor: primaryColor,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // 구분선
                  const DividerWithText(text: 'または'),
                  const SizedBox(height: 24),

                  // 소셜 로그인 버튼
                  SocialLoginButton(
                    type: SocialLoginType.google,
                    onPressed: _signInWithGoogle,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),
                  SocialLoginButton(
                    type: SocialLoginType.apple,
                    onPressed: _signInWithApple,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 32),

                  // 회원가입 링크
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'アカウントをお持ちでないですか？',
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(AppRoutes.signUp);
                        },
                        child: const Text('新規登録'),
                      ),
                    ],
                  ),

                  // 게스트로 계속하기
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.home);
                    },
                    child: const Text('ゲストとして続ける'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (user) async {
          if (!mounted) return;
          // 나의 정보 저장
          await _saveEmail();
          // authStateProvider가 자동으로 업데이트됨
          if (!mounted) return;
          context.go(AppRoutes.home);
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ログインに失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.signInWithGoogle();

      result.fold(
        (failure) {
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
          if (mounted) {
            context.go(AppRoutes.home);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Googleログインに失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.signInWithApple();

      result.fold(
        (failure) {
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
          if (mounted) {
            context.go(AppRoutes.home);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appleログインに失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      // 이메일 입력 다이얼로그 표시
      final result = await PasswordResetDialog.show(context);
      if (result == null || result.isEmpty) {
        return;
      }
      _resetPasswordForEmail(result);
    } else {
      _resetPasswordForEmail(email);
    }
  }

  Future<void> _resetPasswordForEmail(String email) async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.sendPasswordResetEmail(email);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('パスワードリセットメールを送信しました'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('パスワードリセットメールの送信に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
