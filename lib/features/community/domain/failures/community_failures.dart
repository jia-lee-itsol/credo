import '../../../../core/error/failures.dart';

/// 게시글 생성 실패
class PostCreationFailure extends Failure {
  const PostCreationFailure({super.message = '게시글 생성에 실패했습니다.', super.code});
}

/// 게시글 업데이트 실패
class PostUpdateFailure extends Failure {
  const PostUpdateFailure({super.message = '게시글 업데이트에 실패했습니다.', super.code});
}

/// 게시글 삭제 실패
class PostDeleteFailure extends Failure {
  const PostDeleteFailure({super.message = '게시글 삭제에 실패했습니다.', super.code});
}

/// 게시글 조회 실패
class PostNotFoundFailure extends NotFoundFailure {
  const PostNotFoundFailure({super.message = '게시글을 찾을 수 없습니다.', super.code});
}

/// 댓글 생성 실패
class CommentCreationFailure extends Failure {
  const CommentCreationFailure({super.message = '댓글 생성에 실패했습니다.', super.code});
}

/// 알림 생성 실패
class NotificationCreationFailure extends Failure {
  const NotificationCreationFailure({
    super.message = '알림 생성에 실패했습니다.',
    super.code,
  });
}

/// 알림 업데이트 실패
class NotificationUpdateFailure extends Failure {
  const NotificationUpdateFailure({
    super.message = '알림 업데이트에 실패했습니다.',
    super.code,
  });
}

/// 알림 삭제 실패
class NotificationDeleteFailure extends Failure {
  const NotificationDeleteFailure({
    super.message = '알림 삭제에 실패했습니다.',
    super.code,
  });
}

/// 사용자 조회 실패
class UserNotFoundFailure extends NotFoundFailure {
  const UserNotFoundFailure({super.message = '사용자를 찾을 수 없습니다.', super.code});
}

/// 사용자 저장 실패
class UserSaveFailure extends Failure {
  const UserSaveFailure({super.message = '사용자 정보 저장에 실패했습니다.', super.code});
}

/// 좋아요 처리 실패
class LikeToggleFailure extends Failure {
  const LikeToggleFailure({super.message = '좋아요 처리에 실패했습니다.', super.code});
}

/// 권한 부족 실패 (공식 게시글 작성 등)
class InsufficientPermissionFailure extends PermissionFailure {
  const InsufficientPermissionFailure({
    super.message = '권한이 부족합니다.',
    super.code,
  });
}

/// 신고 생성 실패
class ReportCreationFailure extends Failure {
  const ReportCreationFailure({super.message = '신고 생성에 실패했습니다.', super.code});
}
