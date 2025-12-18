import 'package:flutter/material.dart';
import '../../../../core/utils/app_localizations.dart';

/// 매일미사 면책 조항 카드 위젯
class DailyMassDisclaimerCard extends StatelessWidget {
  final AppLocalizations l10n;

  const DailyMassDisclaimerCard({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mass.contentDisclaimer,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.mass.bibleNotice,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

