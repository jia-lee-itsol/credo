import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../providers/daily_reflection_provider.dart';

/// 오늘의 묵상 한마디 카드
class DailyReflectionCard extends ConsumerStatefulWidget {
  const DailyReflectionCard({super.key});

  @override
  ConsumerState<DailyReflectionCard> createState() =>
      _DailyReflectionCardState();
}

class _DailyReflectionCardState extends ConsumerState<DailyReflectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });
    _rotationController.repeat();

    try {
      // 캐시 삭제 및 트리거 증가
      await refreshDailyReflection(ref);
      // provider 무효화 후 새 데이터 로드 대기
      ref.invalidate(dailyReflectionProvider);
      await ref.read(dailyReflectionProvider.future);
    } finally {
      if (mounted) {
        _rotationController.stop();
        _rotationController.reset();
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final reflectionAsync = ref.watch(dailyReflectionProvider);
    final locale = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              primaryColor.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 장식용 인용부호 (배경)
              Positioned(
                right: -10,
                bottom: -20,
                child: Icon(
                  Icons.format_quote_rounded,
                  size: 120,
                  color: primaryColor.withValues(alpha: 0.04),
                ),
              ),
              // 메인 콘텐츠
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Row(
                      children: [
                        // 인용 아이콘 컨테이너
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor.withValues(alpha: 0.15),
                                primaryColor.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.format_quote_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // 타이틀
                        Expanded(
                          child: Text(
                            _getTitle(locale.languageCode),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        // 새로고침 버튼 (회전 애니메이션)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: RotationTransition(
                              turns: _rotationController,
                              child: Icon(
                                Icons.refresh_rounded,
                                color: primaryColor.withValues(alpha: 0.7),
                                size: 18,
                              ),
                            ),
                            onPressed: _isRefreshing ? null : _handleRefresh,
                            tooltip: _getRefreshTooltip(locale.languageCode),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // 구분선
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.2),
                            primaryColor.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 묵상 내용
                    reflectionAsync.when(
                      data: (reflection) {
                        if (reflection == null || reflection.isEmpty) {
                          return _buildPlaceholder(theme, primaryColor, locale.languageCode);
                        }
                        return Text(
                          reflection,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF2D2D2D),
                            letterSpacing: 0.1,
                          ),
                        );
                      },
                      loading: () => _buildLoading(theme, primaryColor, locale.languageCode),
                      error: (error, stack) =>
                          _buildPlaceholder(theme, primaryColor, locale.languageCode),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme, Color primaryColor, String languageCode) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: primaryColor.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _getLoadingText(languageCode),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B6B6B),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme, Color primaryColor, String languageCode) {
    return Text(
      _getPlaceholderText(languageCode),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF6B6B6B),
        fontStyle: FontStyle.italic,
        height: 1.6,
      ),
    );
  }

  String _getTitle(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '今日の黙想';
      case 'ko':
        return '오늘의 묵상';
      case 'en':
        return "Today's Reflection";
      case 'zh':
        return '今日默想';
      case 'vi':
        return 'Suy niệm hôm nay';
      case 'es':
        return 'Reflexión de hoy';
      case 'pt':
        return 'Reflexão de hoje';
      default:
        return '今日の黙想';
    }
  }

  String _getLoadingText(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '黙想を準備しています...';
      case 'ko':
        return '묵상을 준비하고 있습니다...';
      case 'en':
        return 'Preparing reflection...';
      case 'zh':
        return '正在准备默想...';
      case 'vi':
        return 'Đang chuẩn bị suy niệm...';
      case 'es':
        return 'Preparando reflexión...';
      case 'pt':
        return 'Preparando reflexão...';
      default:
        return '黙想を準備しています...';
    }
  }

  String _getPlaceholderText(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '今日も主と共に歩みましょう。';
      case 'ko':
        return '오늘도 주님과 함께 걸어갑시다.';
      case 'en':
        return 'Let us walk with the Lord today.';
      case 'zh':
        return '今天也让我们与主同行。';
      case 'vi':
        return 'Hôm nay chúng ta hãy bước đi cùng Chúa.';
      case 'es':
        return 'Caminemos hoy con el Señor.';
      case 'pt':
        return 'Vamos caminhar com o Senhor hoje.';
      default:
        return '今日も主と共に歩みましょう。';
    }
  }

  String _getRefreshTooltip(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '新しい黙想を生成';
      case 'ko':
        return '새로운 묵상 생성';
      case 'en':
        return 'Generate new reflection';
      case 'zh':
        return '生成新的默想';
      case 'vi':
        return 'Tạo suy niệm mới';
      case 'es':
        return 'Generar nueva reflexión';
      case 'pt':
        return 'Gerar nova reflexão';
      default:
        return '新しい黙想を生成';
    }
  }
}
