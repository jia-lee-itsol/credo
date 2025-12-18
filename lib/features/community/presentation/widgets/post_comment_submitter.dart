import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/logger_service.dart';
import '../../data/models/app_user.dart';
import '../../data/models/notification.dart' as models;
import '../../data/models/post.dart';
import '../providers/community_presentation_providers.dart';
import '../../core/utils/mention_parser.dart';

/// 댓글 제출 로직을 처리하는 헬퍼 클래스
class PostCommentSubmitter {
  final WidgetRef ref;

  PostCommentSubmitter({required this.ref});

  Future<bool> submitComment({
    required Post post,
    required AppUser currentUser,
    required String content,
    List<String> imageUrls = const [],
    List<String> pdfUrls = const [],
  }) async {
    try {
      final postRepo = ref.read(postRepositoryProvider);
      final notificationRepo = ref.read(notificationRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);

      // 댓글 작성
      final commentResult = await postRepo.createComment(
        postId: post.postId,
        authorId: currentUser.uid,
        authorName: currentUser.displayName,
        content: content,
        imageUrls: imageUrls,
        pdfUrls: pdfUrls,
      );
      final commentId = commentResult.fold((failure) {
        AppLogger.error('댓글 생성 실패: ${failure.message}', failure);
        throw Exception(failure.message);
      }, (id) => id);

      // 게시글 작성자에게 댓글 알림 생성 (본인이 댓글을 단 경우 제외)
      AppLogger.community(
        '게시글 작성자 확인: post.authorId=${post.authorId}, currentUser.uid=${currentUser.uid}',
      );
      if (post.authorId != currentUser.uid) {
        AppLogger.notification('게시글 작성자에게 댓글 알림 생성 시작');
        final postAuthorNotification = models.AppNotification(
          notificationId: '',
          userId: post.authorId,
          type: 'comment',
          title: '${currentUser.displayName}さんがあなたの投稿にコメントしました',
          body: content.length > 50
              ? '${content.substring(0, 50)}...'
              : content,
          postId: post.postId,
          commentId: commentId,
          authorId: currentUser.uid,
          authorName: currentUser.displayName,
          isRead: false,
          createdAt: DateTime.now(),
        );

        AppLogger.notification(
          '알림 생성: userId=${postAuthorNotification.userId}, title=${postAuthorNotification.title}',
        );
        final notificationResult = await notificationRepo.createNotification(
          postAuthorNotification,
        );
        notificationResult.fold(
          (failure) {
            AppLogger.error('댓글 알림 생성 실패: ${failure.message}', failure);
          },
          (notificationId) {
            AppLogger.notification('알림 생성 완료: notificationId=$notificationId');
          },
        );
      } else {
        AppLogger.community('본인 게시글이므로 댓글 알림 생성하지 않음');
      }

      // 멘션 파싱 및 알림 생성
      final mentions = MentionParser.extractMentions(content);
      AppLogger.community('멘션 파싱 결과: $mentions');
      if (mentions.isNotEmpty) {
        for (final mentionName in mentions) {
          AppLogger.community('멘션된 사용자 검색: $mentionName');
          // 멘션된 사용자 검색
          final searchResult = await userRepo.searchUsersByDisplayName(
            mentionName,
          );
          final mentionedUsers = searchResult.fold((failure) {
            AppLogger.error('사용자 검색 실패: ${failure.message}', failure);
            return <AppUser>[];
          }, (users) => users);
          AppLogger.community(
            '검색 결과: ${mentionedUsers.length}명 (${mentionedUsers.map((u) => '${u.displayName}(${u.uid})').join(', ')})',
          );

          if (mentionedUsers.isEmpty) {
            AppLogger.community('멘션된 사용자를 찾을 수 없음: $mentionName');
            continue;
          }

          for (final mentionedUser in mentionedUsers) {
            // 본인에게는 알림 생성하지 않음
            if (mentionedUser.uid == currentUser.uid) {
              AppLogger.community('본인 멘션이므로 알림 생성하지 않음: ${mentionedUser.uid}');
              continue;
            }

            // 게시글 작성자에게는 이미 댓글 알림을 보냈으므로 중복 방지
            if (mentionedUser.uid == post.authorId) {
              AppLogger.community(
                '게시글 작성자 멘션이므로 알림 생성하지 않음 (이미 댓글 알림 전송): ${mentionedUser.uid}',
              );
              continue;
            }

            // 알림 생성
            AppLogger.notification(
              '멘션 알림 생성: userId=${mentionedUser.uid}, displayName=${mentionedUser.displayName}',
            );
            final notification = models.AppNotification(
              notificationId: '',
              userId: mentionedUser.uid,
              type: 'mention',
              title: '${currentUser.displayName}さんがあなたをメンションしました',
              body: content.length > 50
                  ? '${content.substring(0, 50)}...'
                  : content,
              postId: post.postId,
              commentId: commentId,
              authorId: currentUser.uid,
              authorName: currentUser.displayName,
              isRead: false,
              createdAt: DateTime.now(),
            );

            final mentionNotificationResult = await notificationRepo
                .createNotification(notification);
            mentionNotificationResult.fold(
              (failure) {
                AppLogger.error(
                  '멘션 알림 생성 실패 (userId=${mentionedUser.uid}): ${failure.message}',
                  failure,
                );
              },
              (notificationId) {
                AppLogger.notification(
                  '멘션 알림 생성 완료: notificationId=$notificationId',
                );
              },
            );
          }
        }
      } else {
        AppLogger.community('멘션이 없음');
      }

      // 댓글 목록 provider를 invalidate하여 새로고침
      ref.invalidate(commentsProvider(post.postId));
      AppLogger.community(
        'commentsProvider invalidate 완료: postId=${post.postId}',
      );

      return true;
    } catch (e) {
      AppLogger.error('댓글 제출 실패: $e', e);
      return false;
    }
  }
}
