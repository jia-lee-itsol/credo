import 'package:flutter/material.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/login_required_dialog.dart';

/// 매일미사 댓글 입력 위젯
class DailyMassCommentInput extends StatelessWidget {
  final TextEditingController commentController;
  final ScrollController scrollController;
  final Color primaryColor;
  final String dateKey;
  final AppLocalizations l10n;
  final VoidCallback onSubmit;

  const DailyMassCommentInput({
    super.key,
    required this.commentController,
    required this.scrollController,
    required this.primaryColor,
    required this.dateKey,
    required this.l10n,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: l10n.mass.prayer.shareHint,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          // 터치 영역을 확대한 공유 버튼
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSubmit,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 매일미사 로그인 프롬프트 위젯
class DailyMassLoginPrompt extends StatelessWidget {
  final Color primaryColor;
  final AppLocalizations l10n;

  const DailyMassLoginPrompt({
    super.key,
    required this.primaryColor,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: GestureDetector(
        onTap: () {
          LoginRequiredDialog.show(context, primaryColor: primaryColor);
        },
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: l10n.mass.prayer.loginToShare,
            hintStyle: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(Icons.login, color: primaryColor, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}

