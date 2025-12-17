import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/error/failures.dart';
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
    final l10n = ref.watch(appLocalizationsSyncProvider);

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
                    subtitle: l10n.auth.subtitle,
                  ),

                  // 이메일 입력
                  TextFormField(
                    controller: _emailController,
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
                    controller: _passwordController,
                    labelText: l10n.auth.password,
                    validator: (value) =>
                        Validators.validatePassword(value, l10n),
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
                      Text(l10n.auth.saveEmail),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 비밀번호 찾기
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      child: Text(l10n.auth.forgotPassword),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 로그인 버튼
                  LoadingButton(
                    onPressed: _signIn,
                    label: l10n.auth.signIn,
                    backgroundColor: primaryColor,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // 구분선
                  DividerWithText(text: l10n.common.or),
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
                        l10n.auth.noAccount,
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(AppRoutes.signUp);
                        },
                        child: Text(l10n.auth.signUp),
                      ),
                    ],
                  ),

                  // 게스트로 계속하기
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.home);
                    },
                    child: Text(l10n.auth.continueAsGuest),
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
            final l10n = ref.read(appLocalizationsSyncProvider);
            final errorMessage = _getLocalizedErrorMessage(failure, l10n);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
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
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.auth.signInFailed),
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
            final l10n = ref.read(appLocalizationsSyncProvider);
            final errorMessage = _getLocalizedErrorMessage(failure, l10n);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        (user) async {
          if (mounted) {
            // authStateProvider가 자동으로 업데이트됨
            context.go(AppRoutes.home);
          }
        },
      );
    } catch (e) {
      // 예상치 못한 에러 로깅
      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.auth.signInFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
            final l10n = ref.read(appLocalizationsSyncProvider);
            final errorMessage = _getLocalizedErrorMessage(failure, l10n);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
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
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.auth.appleSignInFailed),
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
            final l10n = ref.read(appLocalizationsSyncProvider);
            final errorMessage = _getLocalizedErrorMessage(failure, l10n);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) {
          if (mounted) {
            final l10n = ref.read(appLocalizationsSyncProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.auth.passwordResetEmailSent),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.auth.passwordResetEmailFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Failure 메시지를 다국어 메시지로 변환
  String _getLocalizedErrorMessage(Failure failure, AppLocalizations l10n) {
    // 하드코딩된 일본어 메시지를 다국어 키로 매핑
    final message = failure.message;

    if (message.contains('Googleログインがキャンセルされました')) {
      return l10n.auth.googleSignInCanceled;
    } else if (message.contains('Googleログインに失敗しました')) {
      return l10n.auth.googleSignInFailed;
    } else if (message.contains('Google認証情報の取得に失敗しました')) {
      return l10n.auth.googleAuthInfoFailed;
    } else if (message.contains('Googleログイン中にエラーが発生しました')) {
      // 에러 메시지에서 실제 에러 추출
      final errorMatch = RegExp(r': (.+)$').firstMatch(message);
      final error = errorMatch?.group(1) ?? message;
      return l10n.auth.googleSignInError(error);
    } else if (message.contains('Appleログインに失敗しました')) {
      return l10n.auth.appleSignInFailed;
    } else if (message.contains('Appleログインがキャンセルされました')) {
      return l10n.auth.appleSignInCanceled;
    }

    // 매핑되지 않은 메시지는 그대로 반환
    return message;
  }
}
