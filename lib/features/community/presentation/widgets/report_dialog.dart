import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/widgets/login_required_dialog.dart';
import '../../data/providers/community_repository_providers.dart';

/// 신고 사유
enum ReportReason {
  spam('spam', 'spam'),
  inappropriate('inappropriate', 'inappropriate'),
  harassment('harassment', 'harassment'),
  other('other', 'other');

  final String displayName;
  final String value;

  const ReportReason(this.displayName, this.value);

  /// 번역된 표시 이름 가져오기
  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case ReportReason.spam:
        return l10n.report.reasons.spam;
      case ReportReason.inappropriate:
        return l10n.report.reasons.inappropriate;
      case ReportReason.harassment:
        return l10n.report.reasons.harassment;
      case ReportReason.other:
        return l10n.report.reasons.other;
    }
  }
}

/// 신고 다이얼로그 위젯
class ReportDialog extends ConsumerStatefulWidget {
  final String targetType; // "post" | "comment" | "user"
  final String targetId;

  const ReportDialog({
    super.key,
    required this.targetType,
    required this.targetId,
  });

  /// 게시글 신고 다이얼로그 표시
  static Future<void> showForPost(BuildContext context, String postId) {
    return showDialog(
      context: context,
      builder: (context) => ReportDialog(targetType: 'post', targetId: postId),
    );
  }

  /// 댓글 신고 다이얼로그 표시
  static Future<void> showForComment(BuildContext context, String commentId) {
    return showDialog(
      context: context,
      builder: (context) =>
          ReportDialog(targetType: 'comment', targetId: commentId),
    );
  }

  /// 사용자 신고 다이얼로그 표시
  static Future<void> showForUser(BuildContext context, String userId) {
    return showDialog(
      context: context,
      builder: (context) => ReportDialog(targetType: 'user', targetId: userId),
    );
  }

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  ReportReason? _selectedReason;
  final TextEditingController _customReasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final primaryColor = ref.read(liturgyPrimaryColorProvider);

    if (!isAuthenticated) {
      if (mounted) {
        Navigator.pop(context);
        LoginRequiredDialog.show(context, primaryColor: primaryColor);
      }
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      return;
    }

    final l10n = ref.read(appLocalizationsSyncProvider);

    if (_selectedReason == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.report.reasonRequired)));
      }
      return;
    }

    String reason = _selectedReason!.value;
    if (_selectedReason == ReportReason.other) {
      final customReason = _customReasonController.text.trim();
      if (customReason.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.report.reasonInputRequired)),
          );
        }
        return;
      }
      reason = customReason;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(reportRepositoryProvider);
      final result = await repository.createReport(
        targetType: widget.targetType,
        targetId: widget.targetId,
        reason: reason,
        reporterId: currentUser.userId,
      );

      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.report.reportFailed(failure.message)),
              ),
            );
          },
          (_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.report.reportSuccess)));
          },
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = ref.read(appLocalizationsSyncProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.report.reportFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return AlertDialog(
      title: Text(l10n.report.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.report.reasonRequired, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            RadioGroup<ReportReason>(
              groupValue: _selectedReason,
              onChanged: _isSubmitting
                  ? (_) {}
                  : (value) {
                      setState(() {
                        _selectedReason = value;
                      });
                    },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...ReportReason.values.map((reason) {
                    if (reason == ReportReason.other) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile<ReportReason>(
                            title: Text(reason.getLocalizedName(l10n)),
                            value: reason,
                          ),
                          if (_selectedReason == ReportReason.other)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 40,
                                right: 8,
                              ),
                              child: TextField(
                                controller: _customReasonController,
                                decoration: InputDecoration(
                                  hintText: l10n.report.reasonHint,
                                  border: const OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                enabled: !_isSubmitting,
                              ),
                            ),
                        ],
                      );
                    }
                    return RadioListTile<ReportReason>(
                      title: Text(reason.getLocalizedName(l10n)),
                      value: reason,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(l10n.common.cancel),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: FilledButton.styleFrom(backgroundColor: primaryColor),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.report.title),
        ),
      ],
    );
  }
}
