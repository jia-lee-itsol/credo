import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../../../core/data/services/openai_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../providers/saint_feast_day_providers.dart';

/// 성인 축일 모달
class SaintFeastDayModal extends ConsumerStatefulWidget {
  final SaintFeastDayModel saint;
  final String? userBaptismalName;

  const SaintFeastDayModal({
    super.key,
    required this.saint,
    this.userBaptismalName,
  });

  @override
  ConsumerState<SaintFeastDayModal> createState() => _SaintFeastDayModalState();
}

class _SaintFeastDayModalState extends ConsumerState<SaintFeastDayModal> {
  String? _celebrationMessage;
  bool _isLoadingMessage = false;

  @override
  void initState() {
    super.initState();
    _loadCelebrationMessage();
  }

  Future<void> _loadCelebrationMessage() async {
    setState(() {
      _isLoadingMessage = true;
    });

    try {
      final locale = ref.read(localeProvider);
      final saintName = widget.saint.getName(locale.languageCode);
      final openAIService = OpenAIService();

      final message = await openAIService.generateFeastDayMessage(
        saintName: saintName,
        userBaptismalName: widget.userBaptismalName,
        language: locale.languageCode,
      );

      if (mounted) {
        setState(() {
          _celebrationMessage = message;
          _isLoadingMessage = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('축하 메시지 생성 실패: $e', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoadingMessage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final locale = ref.watch(localeProvider);
    final saintName = widget.saint.getName(locale.languageCode);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 이미지 영역
              Container(
                width: double.infinity,
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // 성인 이미지 또는 아이콘
                    Center(child: _buildSaintImage(context, ref, theme)),
                    // 축일 배지
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.saints.feastDay,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 내용 영역
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 성인 이름
                    Text(
                      saintName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 세례명 일치 표시
                    if (widget.userBaptismalName != null &&
                        _isNameMatch(saintName, widget.userBaptismalName!))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.celebration,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.saints.yourBaptismalName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // 축일 정보
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(
                            widget.saint.month,
                            widget.saint.day,
                            locale.languageCode,
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(
                              widget.saint.type,
                              theme,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getTypeLabel(widget.saint.type, l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getTypeColor(widget.saint.type, theme),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 인사말
                    if (widget.saint.greeting.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.saint.greeting,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],

                    // 설명
                    if (widget.saint.description != null &&
                        widget.saint.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.saint.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],

                    // GPT 축하 메시지
                    if (_celebrationMessage != null || _isLoadingMessage) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                            width: 1,
                          ),
                        ),
                        child: _isLoadingMessage
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.saints.generatingMessage ??
                                        '축하 메시지를 생성하고 있습니다...',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.celebration,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _celebrationMessage ?? '',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            height: 1.6,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // 닫기 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.common.close),
                      ),
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

  /// 이름이 일치하는지 확인 (대소문자 무시, 부분 일치)
  bool _isNameMatch(String saintName, String baptismalName) {
    final normalizedSaint = saintName.toLowerCase().trim();
    final normalizedBaptism = baptismalName.toLowerCase().trim();

    // 정확히 일치하거나, 성인 이름에 세례명이 포함되거나, 세례명에 성인 이름이 포함되는 경우
    return normalizedSaint == normalizedBaptism ||
        normalizedSaint.contains(normalizedBaptism) ||
        normalizedBaptism.contains(normalizedSaint);
  }

  /// 축일 타입에 따른 색상 반환
  Color _getTypeColor(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'solemnity':
        return Colors.red;
      case 'feast':
        return Colors.orange;
      case 'memorial':
      default:
        return theme.colorScheme.primary;
    }
  }

  /// 축일 타입에 따른 라벨 반환
  String _getTypeLabel(String type, AppLocalizations l10n) {
    switch (type.toLowerCase()) {
      case 'solemnity':
        return l10n.saints.solemnity;
      case 'feast':
        return l10n.saints.feast;
      case 'memorial':
      default:
        return l10n.saints.memorial;
    }
  }

  /// 날짜 포맷 (다국어 지원)
  String _formatDate(int month, int day, String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '$month月$day日';
      case 'ko':
        return '$month월 $day일';
      case 'en':
        return '${_getMonthName(month, languageCode)} $day';
      case 'zh':
        return '$month月$day日';
      case 'vi':
        return 'Ngày $day tháng $month';
      case 'es':
        return '$day de ${_getMonthName(month, languageCode)}';
      case 'pt':
        return '$day de ${_getMonthName(month, languageCode)}';
      default:
        return '$month/$day';
    }
  }

  /// 월 이름 반환
  String _getMonthName(int month, String languageCode) {
    final monthNames = {
      'en': [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ],
      'es': [
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre',
      ],
      'pt': [
        'janeiro',
        'fevereiro',
        'março',
        'abril',
        'maio',
        'junho',
        'julho',
        'agosto',
        'setembro',
        'outubro',
        'novembro',
        'dezembro',
      ],
    };

    final names = monthNames[languageCode];
    if (names != null && month >= 1 && month <= 12) {
      return names[month - 1];
    }
    return month.toString();
  }

  /// 성인 이미지 빌드
  Widget _buildSaintImage(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final imageUrlAsync = ref.watch(saintImageUrlProvider(widget.saint));

    return imageUrlAsync.when(
      data: (imageUrl) {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  // 에러 로깅
                  AppLogger.error(
                    '[CachedNetworkImage] 이미지 로드 실패: $url',
                    error is Exception ? error : Exception(error.toString()),
                    StackTrace.current,
                  );
                  return Container(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Image.asset(
                        'assets/icons/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
                httpHeaders: const {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                },
              ),
            ),
          );
        }
        // 이미지가 없으면 앱 로고 표시
        return Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Image.asset('assets/icons/logo.png', fit: BoxFit.contain),
          ),
        );
      },
      loading: () => Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      ),
      error: (_, _) => Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Image.asset('assets/icons/logo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}
