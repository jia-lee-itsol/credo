import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';

/// 매일미사 댓글 섹션 위젯
class DailyMassComments extends StatelessWidget {
  final ThemeData theme;
  final Color primaryColor;
  final String dateKey;
  final AppLocalizations l10n;

  const DailyMassComments({
    super.key,
    required this.theme,
    required this.primaryColor,
    required this.dateKey,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
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
          String errorMessage = l10n.mass.prayer.errorOccurred;
          if (error.toString().contains('permission-denied')) {
            errorMessage = l10n.mass.prayer.permissionDenied;
          } else if (error.toString().contains('network')) {
            errorMessage = l10n.mass.prayer.networkError;
          } else {
            errorMessage = '${l10n.mass.prayer.errorOccurred}: $error';
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
              l10n.mass.prayer.everyoneMeditation(comments.length),
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
                    l10n.mass.prayer.noMeditationYet,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...comments.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final authorName =
                    data['authorName'] as String? ?? l10n.mass.prayer.anonymous;
                final content = data['content'] as String? ?? '';
                final createdAt =
                    (data['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime.now();

                return _CommentItem(
                  theme: theme,
                  primaryColor: primaryColor,
                  authorName: authorName,
                  content: content,
                  createdAt: createdAt,
                );
              }),
          ],
        );
      },
    );
  }
}

/// 댓글 아이템 위젯
class _CommentItem extends StatelessWidget {
  final ThemeData theme;
  final Color primaryColor;
  final String authorName;
  final String content;
  final DateTime createdAt;

  const _CommentItem({
    required this.theme,
    required this.primaryColor,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
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
}

