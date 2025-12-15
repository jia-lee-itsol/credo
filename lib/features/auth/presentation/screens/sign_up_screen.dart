import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../config/routes/app_routes.dart';
import '../widgets/password_field.dart';
import '../widgets/loading_button.dart';
import '../widgets/terms_agreement_checkbox.dart';
import '../../../../core/data/services/parish_service.dart' as core;
import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../../profile/data/providers/saint_feast_day_providers.dart';

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
                  // 닉네임 입력
                  TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: l10n.auth.nickname,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),
                    validator: (value) =>
                        Validators.validateNickname(value, l10n),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

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
                    helperText: l10n.validation.passwordMinLength,
                    validator: (value) =>
                        Validators.validatePassword(value, l10n),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // 비밀번호 확인
                  PasswordField(
                    controller: _confirmPasswordController,
                    labelText: l10n.auth.passwordConfirm,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return l10n.auth.passwordMismatch;
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // 소속 성당 선택
                  InkWell(
                    onTap: () => _showParishSearchBottomSheet(
                      context,
                      ref,
                      primaryColor,
                    ),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.auth.parish,
                        suffixIcon: const Icon(Icons.chevron_right),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        _selectedParishName ?? l10n.auth.selectParish,
                        style: TextStyle(
                          color: _selectedParishName != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 세례명 입력
                  TextFormField(
                    controller: _baptismalNameController,
                    decoration: InputDecoration(
                      labelText: l10n.auth.baptismName,
                      prefixIcon: const Icon(Icons.badge_outlined),
                      hintText: l10n.auth.baptismNameHint,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // 축일 선택
                  InkWell(
                    onTap: () =>
                        _showFeastDayBottomSheet(context, ref, primaryColor),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '守護聖人の祝日（任意）',
                        suffixIcon: const Icon(Icons.chevron_right),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        _selectedFeastDay != null
                            ? '${_selectedFeastDay?.name ?? ''} (${_selectedFeastDay?.month ?? 0}${l10n.profile.month}${_selectedFeastDay?.day ?? 0}${l10n.profile.day})'
                            : _customBaptismalName != null &&
                                  _customFeastMonth != null &&
                                  _customFeastDay != null
                            ? '$_customBaptismalName ($_customFeastMonth${l10n.profile.month}$_customFeastDay${l10n.profile.day})'
                            : l10n.auth.selectFeastDay,
                        style: TextStyle(
                          color: _selectedFeastDay != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
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
            return _ParishSearchSheet(
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
        return _FeastDaySearchSheet(
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

/// 교회 검색 시트
class _ParishSearchSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final Color primaryColor;
  final String? selectedParishId;
  final void Function(String parishId, String parishName) onParishSelected;

  const _ParishSearchSheet({
    required this.scrollController,
    required this.primaryColor,
    this.selectedParishId,
    required this.onParishSelected,
  });

  @override
  ConsumerState<_ParishSearchSheet> createState() => _ParishSearchSheetState();
}

class _ParishSearchSheetState extends ConsumerState<_ParishSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final allParishesAsync = ref.watch(core.allParishesProvider);

    return Column(
      children: [
        // 핸들
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),

        // 타이틀
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.auth.selectParishTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 검색바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.search.parishSearchHint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        const SizedBox(height: 16),

        // 교회 목록
        Expanded(
          child: allParishesAsync.when(
            data: (allParishesMap) {
              final allParishes = <Map<String, dynamic>>[];
              allParishesMap.forEach((dioceseId, parishes) {
                for (final parish in parishes) {
                  final parishId = '$dioceseId-${parish['name']}';
                  allParishes.add({...parish, 'parishId': parishId});
                }
              });

              // 검색 필터링
              final filteredParishes = _searchQuery.isEmpty
                  ? allParishes
                  : allParishes.where((parish) {
                      final name = (parish['name'] as String? ?? '')
                          .toLowerCase();
                      final address = (parish['address'] as String? ?? '')
                          .toLowerCase();
                      final query = _searchQuery.toLowerCase();
                      return name.contains(query) || address.contains(query);
                    }).toList();

              if (filteredParishes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.search.noResults,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: widget.scrollController,
                itemCount: filteredParishes.length,
                itemBuilder: (context, index) {
                  final parish = filteredParishes[index];
                  final name = parish['name'] as String? ?? '';
                  final address = parish['address'] as String? ?? '';
                  final parishId = parish['parishId'] as String? ?? '';
                  final isSelected = widget.selectedParishId == parishId;

                  return ListTile(
                    key: ValueKey(parishId),
                    leading: CircleAvatar(
                      backgroundColor: widget.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.church,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: widget.primaryColor)
                        : Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                    onTap: () => widget.onParishSelected(parishId, name),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) {
              final l10n = ref.read(appLocalizationsSyncProvider);
              return Center(child: Text('${l10n.common.error}: $error'));
            },
          ),
        ),
      ],
    );
  }
}

/// 축일 검색 시트
class _FeastDaySearchSheet extends ConsumerStatefulWidget {
  final Color primaryColor;
  final String? selectedFeastDayId;
  final String? customBaptismalName;
  final int? customFeastMonth;
  final int? customFeastDay;
  final void Function(SaintFeastDayModel saint) onFeastDaySelected;
  final void Function(String baptismalName, int month, int day) onCustomInput;

  const _FeastDaySearchSheet({
    required this.primaryColor,
    this.selectedFeastDayId,
    this.customBaptismalName,
    this.customFeastMonth,
    this.customFeastDay,
    required this.onFeastDaySelected,
    required this.onCustomInput,
  });

  @override
  ConsumerState<_FeastDaySearchSheet> createState() =>
      _FeastDaySearchSheetState();
}

class _FeastDaySearchSheetState extends ConsumerState<_FeastDaySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final allSaintsAsync = ref.watch(_allSaintsProvider);

    return Column(
      children: [
        // 핸들
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),

        // 타이틀
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.auth.selectFeastDayTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 검색바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.search.saintSearchHint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        const SizedBox(height: 16),

        // 성인 목록
        Expanded(
          child: allSaintsAsync.when(
            data: (allSaints) {
              // 검색 필터링
              final filteredSaints = _searchQuery.isEmpty
                  ? allSaints
                  : allSaints.where((saint) {
                      final name = saint.name.toLowerCase();
                      final nameEn = saint.nameEn?.toLowerCase() ?? '';
                      final query = _searchQuery.toLowerCase();
                      return name.contains(query) || nameEn.contains(query);
                    }).toList();

              if (filteredSaints.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.search.noResults,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final isCustomSelected =
                  widget.customBaptismalName != null &&
                  widget.customFeastMonth != null &&
                  widget.customFeastDay != null;

              return ListView(
                children: [
                  // 기타 옵션
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: widget.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'その他（直接入力）',
                      style: TextStyle(
                        fontWeight: isCustomSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: isCustomSelected
                        ? Text(
                            '${widget.customBaptismalName} (${widget.customFeastMonth}${l10n.profile.month}${widget.customFeastDay}${l10n.profile.day})',
                            style: theme.textTheme.bodySmall,
                          )
                        : Text(l10n.profile.directInputTitle),
                    trailing: isCustomSelected
                        ? Icon(Icons.check, color: widget.primaryColor)
                        : Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                    onTap: () => _showCustomInputDialog(context, theme),
                  ),
                  const Divider(),
                  // 성인 목록
                  ...filteredSaints.map((saint) {
                    final feastDayId = '${saint.month}-${saint.day}';
                    final isSelected = widget.selectedFeastDayId == feastDayId;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: widget.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          Icons.celebration,
                          color: widget.primaryColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        saint.name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${saint.month}${l10n.profile.month}${saint.day}${l10n.profile.day}',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: widget.primaryColor)
                          : null,
                      onTap: () => widget.onFeastDaySelected(saint),
                    );
                  }),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) {
              final l10n = ref.read(appLocalizationsSyncProvider);
              return Center(child: Text('${l10n.common.error}: $error'));
            },
          ),
        ),
      ],
    );
  }

  void _showCustomInputDialog(BuildContext context, ThemeData theme) {
    final baptismalNameController = TextEditingController(
      text: widget.customBaptismalName ?? '',
    );
    final monthController = TextEditingController(
      text: widget.customFeastMonth?.toString() ?? '',
    );
    final dayController = TextEditingController(
      text: widget.customFeastDay?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(dialogL10n.profile.directInputDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: baptismalNameController,
                  decoration: InputDecoration(
                    labelText: dialogL10n.auth.baptismName,
                    hintText: dialogL10n.auth.baptismNameHint,
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: monthController,
                        decoration: InputDecoration(
                          labelText: dialogL10n.profile.month,
                          hintText: '1-12',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: dayController,
                        decoration: InputDecoration(
                          labelText: dialogL10n.profile.day,
                          hintText: '1-31',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogL10n.common.cancel),
            ),
            TextButton(
              onPressed: () {
                final baptismalName = baptismalNameController.text.trim();
                final monthStr = monthController.text.trim();
                final dayStr = dayController.text.trim();

                if (baptismalName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(dialogL10n.validation.baptismNameRequired),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final month = int.tryParse(monthStr);
                final day = int.tryParse(dayStr);

                if (month == null || month < 1 || month > 12) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(dialogL10n.validation.monthInvalid),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (day == null || day < 1 || day > 31) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(dialogL10n.validation.dayInvalid),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                widget.onCustomInput(baptismalName, month, day);
                Navigator.pop(dialogContext);
              },
              child: Text(dialogL10n.common.save),
            ),
          ],
        );
      },
    );
  }
}

/// 모든 성인 목록 Provider
final _allSaintsProvider = FutureProvider<List<SaintFeastDayModel>>((
  ref,
) async {
  final repository = ref.read(saintFeastDayRepositoryProvider);
  final result = await repository.loadSaintsFeastDays();
  return result.fold(
    (_) => <SaintFeastDayModel>[],
    (saints) => saints
        .map(
          (saint) => SaintFeastDayModel(
            month: saint.month,
            day: saint.day,
            name: saint.name,
            nameEn: saint.nameEnglish,
            type: saint.type,
            isJapanese: saint.isJapanese,
            greeting: saint.greeting,
            description: saint.description,
          ),
        )
        .toList(),
  );
});
