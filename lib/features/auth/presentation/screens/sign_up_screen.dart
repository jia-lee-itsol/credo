import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../config/routes/app_routes.dart';
import '../widgets/loading_button.dart';
import '../widgets/terms_agreement_checkbox.dart';
import '../widgets/sign_up_form_fields.dart';
import '../widgets/sign_up_parish_selector.dart';
import '../widgets/sign_up_feast_day_selector.dart';
import '../widgets/parish_search_sheet.dart';
import '../widgets/feast_day_search_sheet.dart';
import '../../../../core/data/models/saint_feast_day_model.dart';

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
  final _baptismalNameController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = true;
  String? _selectedParishId;
  String? _selectedParishName;
  String? _selectedFeastDayId;
  SaintFeastDayModel? _selectedFeastDay;
  String? _customBaptismalName;
  int? _customFeastMonth;
  int? _customFeastDay;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _baptismalNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.auth.signUp)),
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
                  // 기본 입력 필드
                  SignUpFormFields(
                    nicknameController: _nicknameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    baptismalNameController: _baptismalNameController,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 16),

                  // 소속 성당 선택
                  SignUpParishSelector(
                    selectedParishName: _selectedParishName,
                    onTap: () => _showParishSearchBottomSheet(
                      context,
                      ref,
                      primaryColor,
                    ),
                    l10n: l10n,
                  ),
                  const SizedBox(height: 16),

                  // 축일 선택
                  SignUpFeastDaySelector(
                    selectedFeastDay: _selectedFeastDay,
                    customBaptismalName: _customBaptismalName,
                    customFeastMonth: _customFeastMonth,
                    customFeastDay: _customFeastDay,
                    onTap: () => _showFeastDayBottomSheet(context, ref, primaryColor),
                    l10n: l10n,
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
                    label: l10n.auth.createAccount,
                    backgroundColor: primaryColor,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // 로그인 링크
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'すでにアカウントをお持ちですか？',
                        style: theme.textTheme.bodyMedium,
                      ),
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
      ),
    );
  }

  Future<void> _signUp() async {
    AppLogger.auth('회원가입 버튼 클릭됨');

    if (!_formKey.currentState!.validate()) {
      AppLogger.warning('폼 검증 실패');
      return;
    }
    AppLogger.auth('폼 검증 통과');

    if (!_agreeToTerms) {
      AppLogger.warning('이용약관 미동의');
      final l10n = ref.read(appLocalizationsSyncProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.auth.termsRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    AppLogger.auth('이용약관 동의 확인');

    AppLogger.debug('로딩 상태: true로 변경');
    setState(() {
      _isLoading = true;
    });
    AppLogger.debug('현재 로딩 상태: $_isLoading');

    try {
      AppLogger.debug('Repository 가져오기 시작');
      final repository = ref.read(authRepositoryProvider);
      AppLogger.auth('signUpWithEmail 호출 시작');
      AppLogger.auth('이메일: ${_emailController.text.trim()}');
      AppLogger.auth('닉네임: ${_nicknameController.text.trim()}');

      // 세례명 결정: 직접 입력한 세례명이 있으면 우선 사용, 없으면 목록에서 선택한 성인 이름 사용
      String? finalBaptismalName;
      if (_customBaptismalName != null && _customBaptismalName!.isNotEmpty) {
        finalBaptismalName = _customBaptismalName;
      } else if (_baptismalNameController.text.trim().isNotEmpty) {
        finalBaptismalName = _baptismalNameController.text.trim();
      } else if (_selectedFeastDay != null) {
        finalBaptismalName = _selectedFeastDay!.name;
      }

      // 축일 ID 결정: 커스텀 입력이 있으면 사용, 없으면 선택한 축일 ID 사용
      String? finalFeastDayId;
      if (_customFeastMonth != null && _customFeastDay != null) {
        finalFeastDayId = '$_customFeastMonth-$_customFeastDay';
      } else {
        finalFeastDayId = _selectedFeastDayId;
      }

      final result = await repository.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nickname: _nicknameController.text.trim(),
        mainParishId: _selectedParishId,
        baptismalName: finalBaptismalName,
        feastDayId: finalFeastDayId,
      );

      AppLogger.auth('signUpWithEmail 완료');
      AppLogger.debug('결과 타입: ${result.runtimeType}');

      if (!mounted) {
        AppLogger.warning('Widget이 unmount됨');
        return;
      }

      AppLogger.debug('로딩 상태: false로 변경 시작');
      // 로딩 상태를 먼저 false로 설정
      setState(() {
        _isLoading = false;
      });
      AppLogger.debug('로딩 상태: false로 변경 완료');
      AppLogger.debug('현재 로딩 상태: $_isLoading');

      result.fold(
        (failure) {
          AppLogger.error('회원가입 실패: ${failure.message}', failure);
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
          AppLogger.auth('회원가입 성공!');
          AppLogger.auth('사용자 ID: ${user.userId}');
          AppLogger.auth('사용자 이메일: ${user.email}');

          if (mounted) {
            AppLogger.debug('스낵바 표시 시작');
            final l10n = ref.read(appLocalizationsSyncProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.auth.accountCreated),
                backgroundColor: Colors.green,
              ),
            );
            AppLogger.debug('스낵바 표시 완료');

            AppLogger.debug('페이지 이동 스케줄링');
            // 다음 프레임에서 페이지 이동 (로딩 상태가 UI에 반영된 후)
            // 회원가입 성공 시 로그인 페이지로 이동 (자동 로그인하지 않음)
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              AppLogger.debug('addPostFrameCallback 실행됨');
              if (mounted) {
                AppLogger.auth('로그인 페이지로 이동 시작');
                // 회원가입 후 로그아웃하여 자동 로그인 방지
                final repository = ref.read(authRepositoryProvider);
                await repository.signOut();
                if (mounted) {
                  context.go(AppRoutes.signIn);
                  AppLogger.auth('로그인 페이지로 이동 완료');
                }
              } else {
                AppLogger.warning('페이지 이동 시도했지만 Widget이 unmount됨');
              }
            });
          } else {
            AppLogger.warning('성공했지만 Widget이 unmount됨');
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('예외 발생: $e', e, stackTrace);
      if (mounted) {
        AppLogger.debug('예외 처리: 로딩 상태 false로 변경');
        setState(() {
          _isLoading = false;
        });
        AppLogger.debug('예외 처리: 로딩 상태 변경 완료');
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.auth.signUpFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    AppLogger.auth('_signUp 함수 종료');
    AppLogger.debug('최종 로딩 상태: $_isLoading');
  }

  void _showParishSearchBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return ParishSearchSheet(
              scrollController: scrollController,
              primaryColor: primaryColor,
              selectedParishId: _selectedParishId,
              onParishSelected: (parishId, parishName) {
                setState(() {
                  _selectedParishId = parishId;
                  _selectedParishName = parishName;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showFeastDayBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FeastDaySearchSheet(
          primaryColor: primaryColor,
          selectedFeastDayId: _selectedFeastDayId,
          customBaptismalName: _customBaptismalName,
          customFeastMonth: _customFeastMonth,
          customFeastDay: _customFeastDay,
          onFeastDaySelected: (saint) {
            setState(() {
              _selectedFeastDay = saint;
              _selectedFeastDayId = '${saint.month}-${saint.day}';
              _customBaptismalName = null;
              _customFeastMonth = null;
              _customFeastDay = null;
            });
            Navigator.pop(context);
          },
          onCustomInput: (baptismalName, month, day) {
            setState(() {
              _customBaptismalName = baptismalName;
              _customFeastMonth = month;
              _customFeastDay = day;
              _selectedFeastDay = null;
              _selectedFeastDayId = 'custom-$month-$day';
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
