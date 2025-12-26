import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/liturgical_reading_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/utils/share_utils.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/login_required_dialog.dart';
import '../widgets/daily_mass_disclaimer_card.dart';
import '../widgets/daily_mass_header.dart';
import '../widgets/daily_mass_liturgical_day_card.dart';
import '../widgets/daily_mass_no_data_card.dart';
import '../widgets/daily_mass_readings.dart';
import '../widgets/daily_mass_meditation_tips.dart';
import '../widgets/daily_mass_comments.dart';
import '../widgets/daily_mass_comment_input.dart';

/// 매일미사 화면
class DailyMassScreen extends ConsumerStatefulWidget {
  const DailyMassScreen({super.key});

  @override
  ConsumerState<DailyMassScreen> createState() => _DailyMassScreenState();
}

class _DailyMassScreenState extends ConsumerState<DailyMassScreen> {
  DateTime? _selectedDate;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final primaryColor = ref.read(liturgyPrimaryColorProvider);
    final testDate = ref.read(testDateOverrideProvider);
    final initialDate = _selectedDate ?? testDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2033, 12, 31),
      locale: const Locale('ja', 'JP'),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);
    final testDate = ref.watch(testDateOverrideProvider);

    // 선택한 날짜가 있으면 사용, 없으면 테스트 날짜 또는 오늘 날짜
    final displayDate = _selectedDate ?? testDate ?? DateTime.now();
    final currentLocale = ref.watch(localeProvider);
    final dateFormat = DateFormat.yMMMEd(currentLocale.languageCode);

    // 날짜를 문자열로 변환하여 Provider family 키로 사용 (무한 반복 방지)
    final dateKey =
        '${displayDate.year}-${displayDate.month.toString().padLeft(2, '0')}-${displayDate.day.toString().padLeft(2, '0')}';
    
    // Provider를 watch하되, 에러 발생 시 재시도 가능하도록 처리
    final liturgicalDayAsync = ref.watch(liturgicalDayProvider(dateKey));

    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.navigation.dailyMass),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareDailyMassReading(context, ref, displayDate),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.myPage);
              },
              child: CircleAvatar(
                key: ValueKey(currentUser?.profileImageUrl ?? 'no-image'),
                radius: 22,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                backgroundImage: currentUser?.profileImageUrl != null
                    ? NetworkImage(currentUser!.profileImageUrl!)
                    : null,
                child: currentUser?.profileImageUrl == null
                    ? Icon(Icons.person, size: 24, color: primaryColor)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: liturgicalDayAsync.when(
        data: (liturgicalDay) {
          final dateKey =
              '${displayDate.year}-${displayDate.month.toString().padLeft(2, '0')}-${displayDate.day.toString().padLeft(2, '0')}';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 면책 조항
                    DailyMassDisclaimerCard(l10n: l10n),

                    const SizedBox(height: 16),

                    // 날짜 헤더 (데이트피커 포함)
                    DailyMassHeader(
                      date: dateFormat.format(displayDate),
                      primaryColor: primaryColor,
                      onDateTap: () => _selectDate(context),
                    ),

                    const SizedBox(height: 16),

                    // 전례일 정보
                    if (liturgicalDay != null) ...[
                      DailyMassLiturgicalDayCard(
                        theme: theme,
                        primaryColor: primaryColor,
                        day: liturgicalDay,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 24),
                      DailyMassReadings(
                        primaryColor: primaryColor,
                        day: liturgicalDay,
                        l10n: l10n,
                        dateKey: dateKey,
                      ),
                    ] else
                      DailyMassNoDataCard(
                        theme: theme,
                        primaryColor: primaryColor,
                        l10n: l10n,
                      ),

                    const SizedBox(height: 24),

                    // 묵상 방법 안내 및 팁 섹션
                    DailyMassMeditationTips(
                      theme: theme,
                      primaryColor: primaryColor,
                      l10n: l10n,
                    ),

                    const SizedBox(height: 24),

                    // 댓글 섹션
                    DailyMassComments(
                      theme: theme,
                      primaryColor: primaryColor,
                      dateKey: dateKey,
                      l10n: l10n,
                    ),
                  ],
                ),
              ),
              // 댓글 입력 필드 (로그인한 사용자만 표시)
              if (currentUser != null)
                DailyMassCommentInput(
                  commentController: _commentController,
                  scrollController: _scrollController,
                  primaryColor: primaryColor,
                  dateKey: dateKey,
                  l10n: l10n,
                  onSubmit: () => _handleSubmitComment(
                    context,
                    primaryColor,
                    dateKey,
                  ),
                )
              else
                DailyMassLoginPrompt(
                  primaryColor: primaryColor,
                  l10n: l10n,
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          AppLogger.error('[DailyMassScreen] ERROR: $error', error, stackTrace);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('${l10n.common.error}: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(liturgicalDayProvider(dateKey)),
                  child: Text(l10n.common.retry),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _shareDailyMassReading(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) async {
    try {
      final l10n = ref.read(appLocalizationsSyncProvider);
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final liturgicalDayAsync = ref.read(
        liturgicalDayProvider(dateKey),
      );

      String? readingTitle;

      liturgicalDayAsync.whenData((liturgicalDay) {
        if (liturgicalDay != null) {
          readingTitle = liturgicalDay.name;
          // 첫 번째 독서 제목을 사용
          if (liturgicalDay.readings.first.title.isNotEmpty) {
            readingTitle = '${liturgicalDay.name} - ${liturgicalDay.readings.first.title}';
          }
        }
      });

      await ShareUtils.shareDailyMassReading(
        context: context,
        date: date,
        readingTitle: readingTitle,
        readingText: null,
        l10n: l10n,
      );
    } catch (e) {
      if (context.mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.common.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmitComment(
    BuildContext context,
    Color primaryColor,
    String dateKey,
  ) async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      LoginRequiredDialog.show(context, primaryColor: primaryColor);
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.auth.loginRequired)));
      }
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    // async gap 이전에 저장
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = ref.read(appLocalizationsSyncProvider);

    try {
      await FirebaseFirestore.instance
          .collection('daily_meditation_comments')
          .doc(dateKey)
          .collection('comments')
          .add({
            'authorId': currentUser.userId,
            'authorName': currentUser.displayName,
            'content': content,
            'createdAt': FieldValue.serverTimestamp(),
          });

      _commentController.clear();
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.community.shareMeditation)),
      );
      // 댓글 섹션으로 스크롤
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error('댓글 작성 실패: $e', e, stackTrace);
      if (!mounted) return;
      String errorMessage = l10n.mass.prayer.errorOccurred;
      if (e.toString().contains('permission-denied')) {
        errorMessage = l10n.mass.prayer.permissionDenied;
      } else if (e.toString().contains('network')) {
        errorMessage = l10n.mass.prayer.networkError;
      }
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
