import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/services/liturgical_reading_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/bible_license_provider.dart';
import '../../../../shared/providers/meditation_guide_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/expandable_content_card.dart';

/// 매일미사 독서 섹션 위젯
class DailyMassReadings extends ConsumerWidget {
  final Color primaryColor;
  final LiturgicalDay day;
  final AppLocalizations l10n;
  final String dateKey;

  const DailyMassReadings({
    super.key,
    required this.primaryColor,
    required this.day,
    required this.l10n,
    required this.dateKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = day.readings;
    // Firestore의 app_settings/bible_license 문서에서 라이선스 상태 확인
    final isBibleTextLicensed = ref.watch(bibleLicenseStatusSyncProvider);
    // 현재 로케일 가져오기
    final currentLocale = ref.watch(localeProvider);
    final languageCode = currentLocale.languageCode;

    return Column(
      children: [
        // 제1독서 묵상 가이드
        _MeditationCard(
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
          _MeditationCard(
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
          _MeditationCard(
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
        _MeditationCard(
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
}

/// 묵상 가이드 카드 위젯
class _MeditationCard extends ConsumerWidget {
  final Color primaryColor;
  final String title;
  final IconData icon;
  final String reference;
  final String readingType;
  final String dateKey;
  final String languageCode;
  final bool isBibleTextLicensed;
  final String? titleText;

  const _MeditationCard({
    required this.primaryColor,
    required this.title,
    required this.icon,
    required this.reference,
    required this.readingType,
    required this.dateKey,
    required this.languageCode,
    required this.isBibleTextLicensed,
    this.titleText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}

