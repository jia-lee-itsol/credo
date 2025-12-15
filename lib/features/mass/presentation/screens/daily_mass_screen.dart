import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/data/services/liturgical_reading_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/bible_license_provider.dart';
import '../../../../shared/providers/meditation_guide_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/expandable_content_card.dart';
import '../../../../shared/widgets/login_required_dialog.dart';

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
    final dateFormat = DateFormat('yyyy年M月d日 (E)', 'ja');

    // 날짜를 문자열로 변환하여 Provider family 키로 사용 (무한 반복 방지)
    final dateKey =
        '${displayDate.year}-${displayDate.month.toString().padLeft(2, '0')}-${displayDate.day.toString().padLeft(2, '0')}';
    final liturgicalDayAsync = ref.watch(liturgicalDayProvider(dateKey));

    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.mass.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.myPage);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                backgroundImage: currentUser?.profileImageUrl != null
                    ? NetworkImage(currentUser!.profileImageUrl!)
                    : null,
                child: currentUser?.profileImageUrl == null
                    ? Icon(Icons.person, size: 20, color: primaryColor)
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
                    _buildDisclaimerCard(theme, l10n),

                    const SizedBox(height: 16),

                    // 날짜 헤더 (데이트피커 포함)
                    _buildDateHeader(
                      context,
                      theme,
                      primaryColor,
                      dateFormat.format(displayDate),
                    ),

                    const SizedBox(height: 16),

                    // 전례일 정보
                    if (liturgicalDay != null) ...[
                      _buildLiturgicalDayCard(
                        theme,
                        primaryColor,
                        liturgicalDay,
                        l10n,
                      ),
                      const SizedBox(height: 24),
                      _buildReadingsSection(
                        primaryColor,
                        liturgicalDay,
                        l10n,
                        dateKey,
                      ),
                    ] else
                      _buildNoDataCard(theme, primaryColor, l10n),

                    const SizedBox(height: 24),

                    // 댓글 섹션
                    _buildCommentsSection(theme, primaryColor, dateKey),
                  ],
                ),
              ),
              // 댓글 입력 필드 (로그인한 사용자만 표시)
              if (currentUser != null)
                _buildCommentInput(context, theme, primaryColor, dateKey, l10n)
              else
                _buildLoginPrompt(context, theme, primaryColor),
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

  Widget _buildDisclaimerCard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Text(
        l10n.mass.bibleNotice,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDateHeader(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    String date,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              date,
              style: theme.textTheme.titleMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_month, color: primaryColor),
            onPressed: () => _selectDate(context),
            tooltip: '날짜 선택',
          ),
        ],
      ),
    );
  }

  Widget _buildLiturgicalDayCard(
    ThemeData theme,
    Color primaryColor,
    LiturgicalDay day,
    AppLocalizations l10n,
  ) {
    final liturgicalColor = _getLiturgicalColor(day.color);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: liturgicalColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: liturgicalColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              color: liturgicalColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.name.isNotEmpty
                      ? day.name
                      : _getDefaultDayName(day, l10n),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSeasonName(day.season),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: liturgicalColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getColorName(day.color),
              style: TextStyle(
                color: liturgicalColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsSection(
    Color primaryColor,
    LiturgicalDay day,
    AppLocalizations l10n,
    String dateKey,
  ) {
    final readings = day.readings;
    // Firestore의 app_settings/bible_license 문서에서 라이선스 상태 확인
    final isBibleTextLicensed = ref.watch(bibleLicenseStatusSyncProvider);
    // 현재 로케일 가져오기
    final currentLocale = ref.watch(localeProvider);
    final languageCode = currentLocale.languageCode;

    return Column(
      children: [
        // 제1독서 묵상 가이드
        _buildMeditationCard(
          primaryColor: primaryColor,
          title: l10n.mass.prayer.meditationGuideTitle('firstReading'),
          icon: Icons.menu_book,
          reference: readings.first.reference,
          readingType: 'firstReading',
          dateKey: dateKey,
          languageCode: languageCode,
          isBibleTextLicensed: isBibleTextLicensed,
          titleText: readings.first.title,
        ),

        // 화답송 묵상 가이드 (있는 경우만 표시)
        if (readings.psalm != null && readings.psalm!.reference.isNotEmpty)
          _buildMeditationCard(
            primaryColor: primaryColor,
            title: l10n.mass.prayer.meditationGuideTitle('psalm'),
            icon: Icons.library_music,
            reference: readings.psalm!.reference,
            readingType: 'psalm',
            dateKey: dateKey,
            languageCode: languageCode,
            isBibleTextLicensed: isBibleTextLicensed,
            titleText: readings.psalm!.title,
          ),

        // 제2독서 묵상 가이드 (있는 경우)
        if (readings.second != null)
          _buildMeditationCard(
            primaryColor: primaryColor,
            title: l10n.mass.prayer.meditationGuideTitle('secondReading'),
            icon: Icons.menu_book,
            reference: readings.second!.reference,
            readingType: 'secondReading',
            dateKey: dateKey,
            languageCode: languageCode,
            isBibleTextLicensed: isBibleTextLicensed,
            titleText: readings.second!.title,
          ),

        // 복음 묵상 가이드
        _buildMeditationCard(
          primaryColor: primaryColor,
          title: l10n.mass.prayer.meditationGuideTitle('gospel'),
          icon: Icons.auto_stories,
          reference: readings.gospel.reference,
          readingType: 'gospel',
          dateKey: dateKey,
          languageCode: languageCode,
          isBibleTextLicensed: isBibleTextLicensed,
          titleText: readings.gospel.title,
        ),
      ],
    );
  }

  /// 묵상 가이드 카드 위젯
  Widget _buildMeditationCard({
    required Color primaryColor,
    required String title,
    required IconData icon,
    required String reference,
    required String readingType,
    required String dateKey,
    required String languageCode,
    required bool isBibleTextLicensed,
    String? titleText,
  }) {
    final params = MeditationGuideParams(
      dateKey: dateKey,
      readingType: readingType,
      reference: reference,
      title: titleText,
      language: languageCode,
    );

    final meditationGuideAsync = ref.watch(meditationGuideProvider(params));

    return meditationGuideAsync.when(
      data: (guide) => ExpandableContentCard(
        title: title,
        subtitle: '',
        icon: icon,
        primaryColor: primaryColor,
        content: guide,
        referenceLabel: _formatReferenceLabel(reference),
        isBibleTextLicensed: isBibleTextLicensed,
      ),
      loading: () => ExpandableContentCard(
        title: title,
        subtitle: '',
        icon: icon,
        primaryColor: primaryColor,
        content: _getLoadingMessage(languageCode),
        referenceLabel: _formatReferenceLabel(reference),
        isBibleTextLicensed: isBibleTextLicensed,
      ),
      error: (error, stackTrace) {
        AppLogger.error(
          '[DailyMassScreen] 묵상 가이드 로드 실패: $readingType',
          error,
          stackTrace,
        );
        return ExpandableContentCard(
          title: title,
          subtitle: '',
          icon: icon,
          primaryColor: primaryColor,
          content: _getErrorMessage(languageCode),
          referenceLabel: _formatReferenceLabel(reference),
          isBibleTextLicensed: isBibleTextLicensed,
        );
      },
    );
  }

  /// 로딩 메시지
  String _getLoadingMessage(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '묵상 가이드를 생성하고 있습니다...';
      case 'ko':
        return '묵상 가이드를 생성하고 있습니다...';
      case 'en':
        return 'Generating meditation guide...';
      default:
        return '묵상 가이드를 생성하고 있습니다...';
    }
  }

  /// 에러 메시지
  String _getErrorMessage(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '묵상 가이드를 불러오는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 'ko':
        return '묵상 가이드를 불러오는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 'en':
        return 'An error occurred while loading the meditation guide. Please try again later.';
      default:
        return '묵상 가이드를 불러오는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  /// reference를 referenceLabel 형식으로 변환
  /// 예: "イザヤ 48:17-19" -> "参考箇所：イザヤ書 48:17–19"
  String? _formatReferenceLabel(String? reference) {
    if (reference == null || reference.isEmpty) {
      return null;
    }

    // reference가 이미 적절한 형식인지 확인
    // "参考箇所：" 또는 "聖書箇所："로 시작하면 그대로 사용
    if (reference.startsWith('参考箇所：') || reference.startsWith('聖書箇所：')) {
      return reference;
    }

    // 그렇지 않으면 "参考箇所：" 접두사 추가
    return '参考箇所：$reference';
  }

  String _getDefaultDayName(LiturgicalDay day, AppLocalizations l10n) {
    // 이름이 비어있을 때 기본 이름 생성
    // 주일, 대축일, 축일은 시기와 관계없이 우선 표시
    if (day.isSunday) {
      return l10n.mass.sunday;
    } else if (day.isSolemnity) {
      return l10n.mass.solemnity;
    } else if (day.isFeast) {
      return l10n.mass.feast;
    } else {
      // 시기에 따라 기본 이름 반환
      switch (day.season) {
        case 'advent':
          return l10n.mass.advent;
        case 'christmas':
          return l10n.mass.christmas;
        case 'lent':
          return l10n.mass.lent;
        case 'easter':
          return l10n.mass.easter;
        case 'ordinary':
        default:
          return l10n.mass.ordinary;
      }
    }
  }

  Widget _buildNoDataCard(
    ThemeData theme,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            l10n.mass.noDataToday,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.mass.noDataWeekday,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLiturgicalColor(String color) {
    switch (color) {
      case 'white':
        return const Color(0xFFD4AF37); // 금색으로 표시 (흰색은 보이지 않으므로)
      case 'red':
        return Colors.red.shade700;
      case 'green':
        return Colors.green.shade700;
      case 'purple':
        return Colors.purple.shade700;
      case 'rose':
        return Colors.pink.shade300;
      case 'black':
        return Colors.black87;
      default:
        return Colors.green.shade700;
    }
  }

  String _getColorName(String color) {
    switch (color) {
      case 'white':
        return '白';
      case 'red':
        return '赤';
      case 'green':
        return '緑';
      case 'purple':
        return '紫';
      case 'rose':
        return '薔薇';
      case 'black':
        return '黒';
      default:
        return '緑';
    }
  }

  String _getSeasonName(String season) {
    switch (season) {
      case 'advent':
        return '待降節';
      case 'christmas':
        return '降誕節';
      case 'lent':
        return '四旬節';
      case 'easter':
        return '復活節';
      case 'ordinary':
        return '年間';
      default:
        return '';
    }
  }

  Widget _buildCommentsSection(
    ThemeData theme,
    Color primaryColor,
    String dateKey,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('daily_meditation_comments')
          .doc(dateKey)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          String errorMessage = 'エラーが発生しました';
          if (error.toString().contains('permission-denied')) {
            errorMessage = '権限がありません。ログイン状態を確認してください。';
          } else if (error.toString().contains('network')) {
            errorMessage = 'ネットワークエラーが発生しました。';
          } else {
            errorMessage = 'エラーが発生しました: $error';
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final comments = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'みんなの黙想 (${comments.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'まだ黙想がありません',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...comments.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final authorName = data['authorName'] as String? ?? '匿名';
                final content = data['content'] as String? ?? '';
                final createdAt =
                    (data['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime.now();

                return _buildCommentItem(
                  theme,
                  primaryColor,
                  authorName,
                  content,
                  createdAt,
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildCommentItem(
    ThemeData theme,
    Color primaryColor,
    String authorName,
    String content,
    DateTime createdAt,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: primaryColor.withValues(alpha: 0.2),
            child: Text(
              authorName.isNotEmpty ? authorName[0] : '?',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      authorName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppDateUtils.formatRelativeTime(createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
    String dateKey,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: l10n.mass.prayer.shareHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            onPressed: () =>
                _handleSubmitComment(context, primaryColor, dateKey),
            icon: Icon(Icons.send, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          LoginRequiredDialog.show(context, primaryColor: primaryColor);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'ログインして黙想を共有しましょう',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.community.shareMeditation)));
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
      }
    } catch (e, stackTrace) {
      AppLogger.error('댓글 작성 실패: $e', e, stackTrace);
      if (mounted) {
        String errorMessage = 'エラーが発生しました';
        if (e.toString().contains('permission-denied')) {
          errorMessage = '権限がありません。ログイン状態を確認してください。';
        } else if (e.toString().contains('network')) {
          errorMessage = 'ネットワークエラーが発生しました。';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }
}
