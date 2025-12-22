import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../chat/presentation/providers/friend_providers.dart';

/// 게시글 작성자 정보 위젯
class PostDetailAuthorInfo extends ConsumerStatefulWidget {
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final Color primaryColor;

  const PostDetailAuthorInfo({
    super.key,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    required this.primaryColor,
  });

  @override
  ConsumerState<PostDetailAuthorInfo> createState() => _PostDetailAuthorInfoState();
}

class _PostDetailAuthorInfoState extends ConsumerState<PostDetailAuthorInfo> {
  // StreamProvider를 사용하므로 initState에서 무효화할 필요 없음

  String _formatTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return l10n.common.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.common.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.common.minutesAgo(difference.inMinutes);
    } else {
      return l10n.common.justNow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final timeAgo = _formatTimeAgo(widget.createdAt, l10n);
    // 실시간 업데이트를 위해 StreamProvider 사용
    final userAsync = ref.watch(userByIdStreamProvider(widget.authorId));

    return Row(
      children: [
        userAsync.when(
          data: (user) {
            // 디버깅: 프로필 이미지 URL 확인
            if (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty) {
              return CircleAvatar(
                key: ValueKey('${user.userId}-${user.profileImageUrl}'),
                radius: 16,
                backgroundColor: widget.primaryColor.withValues(alpha: 0.2),
                backgroundImage: CachedNetworkImageProvider(user.profileImageUrl!),
              );
            }
            return CircleAvatar(
              key: ValueKey('no-image-${widget.authorId}'),
              radius: 16,
              backgroundColor: widget.primaryColor.withValues(alpha: 0.2),
              child: Icon(Icons.person, size: 16, color: widget.primaryColor),
            );
          },
          loading: () => CircleAvatar(
            radius: 16,
            backgroundColor: widget.primaryColor.withValues(alpha: 0.2),
            child: Icon(Icons.person, size: 16, color: widget.primaryColor),
          ),
          error: (error, stackTrace) {
            // 에러 발생 시 provider 무효화 후 재시도
            Future.microtask(() {
              ref.invalidate(userByIdProvider(widget.authorId));
            });
            return CircleAvatar(
              radius: 16,
              backgroundColor: widget.primaryColor.withValues(alpha: 0.2),
              child: Icon(Icons.person, size: 16, color: widget.primaryColor),
            );
          },
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.authorName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(timeAgo, style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
