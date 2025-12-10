import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/post_entity.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

/// 게시글 데이터 모델
@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'parish_id') String? parishId, // 본당별 공지/게시판 분리용 (옵션)
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    required String content,
    @JsonKey(name: 'is_official') @Default(false) bool isOfficial,
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'author_nickname') String? authorNickname, // 스냅샷용
    @JsonKey(name: 'author_profile_image') String? authorProfileImage,
    @JsonKey(name: 'author_role') String? authorRole, // 스냅샷용
    @JsonKey(name: 'author_is_verified')
    @Default(false)
    bool authorIsVerified, // 스냅샷용
    @Default('community')
    String category, // "notice" | "community" | "qa" | "testimony" ...
    @Default('normal') String type, // "official" | "normal"
    @Default('published')
    String status, // "published" | "hidden" | "reported" ...
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _PostModel;

  const PostModel._();

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  /// Firestore Document에서 생성
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel.fromJson({
      'post_id': doc.id,
      ...data,
      'created_at':
          (data['created_at'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
      'updated_at':
          (data['updated_at'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    });
  }

  /// Entity로 변환
  PostEntity toEntity({bool isLikedByCurrentUser = false}) {
    return PostEntity(
      postId: postId,
      parishId: parishId,
      userId: userId,
      title: title,
      content: content,
      isOfficial: isOfficial,
      isPinned: isPinned,
      likeCount: likeCount,
      commentCount: commentCount,
      isLikedByCurrentUser: isLikedByCurrentUser,
      authorNickname: authorNickname,
      authorProfileImage: authorProfileImage,
      authorRole: authorRole,
      authorIsVerified: authorIsVerified,
      category: category,
      type: type,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'content': content,
      'is_official': isOfficial,
      'is_pinned': isPinned,
      'like_count': likeCount,
      'comment_count': commentCount,
      'author_nickname': authorNickname,
      'author_profile_image': authorProfileImage,
      'author_role': authorRole,
      'author_is_verified': authorIsVerified,
      'category': category,
      'type': type,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };

    if (parishId != null) {
      map['parish_id'] = parishId;
    }

    return map;
  }
}

/// 댓글 데이터 모델
@freezed
class CommentModel with _$CommentModel {
  const factory CommentModel({
    @JsonKey(name: 'comment_id') required String commentId,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'user_id') required String userId,
    required String content,
    @JsonKey(name: 'author_nickname') String? authorNickname,
    @JsonKey(name: 'author_profile_image') String? authorProfileImage,
    @JsonKey(name: 'is_official') @Default(false) bool isOfficial,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CommentModel;

  const CommentModel._();

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  /// Firestore Document에서 생성
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel.fromJson({
      'comment_id': doc.id,
      ...data,
      'created_at':
          (data['created_at'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    });
  }

  /// Entity로 변환
  CommentEntity toEntity() {
    return CommentEntity(
      commentId: commentId,
      postId: postId,
      userId: userId,
      content: content,
      authorNickname: authorNickname,
      authorProfileImage: authorProfileImage,
      isOfficial: isOfficial,
      createdAt: createdAt,
    );
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'author_nickname': authorNickname,
      'author_profile_image': authorProfileImage,
      'is_official': isOfficial,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}

/// 좋아요 데이터 모델
@freezed
class LikeModel with _$LikeModel {
  const factory LikeModel({
    @JsonKey(name: 'like_id') required String likeId,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _LikeModel;

  const LikeModel._();

  factory LikeModel.fromJson(Map<String, dynamic> json) =>
      _$LikeModelFromJson(json);

  factory LikeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LikeModel.fromJson({
      'like_id': doc.id,
      ...data,
      'created_at':
          (data['created_at'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    return {
      'post_id': postId,
      'user_id': userId,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
