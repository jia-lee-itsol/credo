import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_entity.freezed.dart';

/// 게시글 엔티티
@freezed
class PostEntity with _$PostEntity {
  const factory PostEntity({
    required String postId,
    required String parishId,
    required String userId,
    required String title,
    required String content,
    @Default(false) bool isOfficial,
    @Default(false) bool isPinned,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(false) bool isLikedByCurrentUser,
    String? authorNickname,
    String? authorProfileImage,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PostEntity;

  const PostEntity._();

  /// 공식 게시글인지 확인
  bool get isOfficialPost => isOfficial;

  /// 고정 게시글인지 확인
  bool get isPinnedPost => isPinned;

  /// 내용 미리보기 (2~3줄)
  String get contentPreview {
    const maxLength = 100;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }
}

/// 댓글 엔티티
@freezed
class CommentEntity with _$CommentEntity {
  const factory CommentEntity({
    required String commentId,
    required String postId,
    required String userId,
    required String content,
    String? authorNickname,
    String? authorProfileImage,
    @Default(false) bool isOfficial,
    required DateTime createdAt,
  }) = _CommentEntity;

  const CommentEntity._();
}

/// 좋아요 엔티티
@freezed
class LikeEntity with _$LikeEntity {
  const factory LikeEntity({
    required String likeId,
    required String postId,
    required String userId,
    required DateTime createdAt,
  }) = _LikeEntity;
}

/// 신고 엔티티
@freezed
class ReportEntity with _$ReportEntity {
  const factory ReportEntity({
    required String reportId,
    required String targetId, // post_id 또는 comment_id
    required ReportTargetType targetType,
    required String reporterId,
    required ReportReason reason,
    String? description,
    @Default(ReportStatus.pending) ReportStatus status,
    required DateTime createdAt,
  }) = _ReportEntity;
}

/// 신고 대상 유형
enum ReportTargetType {
  post,
  comment,
}

/// 신고 사유
enum ReportReason {
  spam,
  harassment,
  inappropriate,
  misinformation,
  other,
}

/// 신고 상태
enum ReportStatus {
  pending,
  reviewed,
  resolved,
  dismissed,
}
