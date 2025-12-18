import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/font_scale_provider.dart';

/// 글씨 크기 설정 타일
class FontScaleSettingsTile extends ConsumerWidget {
  final Color primaryColor;

  const FontScaleSettingsTile({
    super.key,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = ref.watch(fontScaleProvider);
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, color: primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.profile.fontSize,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.common.small),
              Expanded(
                child: Slider(
                  value: fontScale,
                  min: 0.85,
                  max: 1.4,
                  divisions: 11,
                  activeColor: primaryColor,
                  label: _getFontScaleLabel(fontScale, l10n),
                  onChanged: (value) {
                    ref.read(fontScaleProvider.notifier).setFontScale(value);
                  },
                ),
              ),
              Text(l10n.common.large),
            ],
          ),
          Center(
            child: Text(
              l10n.common.sampleText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16 * fontScale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFontScaleLabel(double scale, AppLocalizations l10n) {
    if (scale <= 0.9) return l10n.common.small;
    if (scale <= 1.05) return l10n.common.medium;
    if (scale <= 1.2) return l10n.common.large;
    return l10n.common.extraLarge;
  }
}

