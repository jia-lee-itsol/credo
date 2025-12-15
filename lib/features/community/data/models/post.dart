import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

/// 게시글 모델 (Firestore /posts/{postId} 컬렉션)
@freezed
class Post with _$Post {
  const factory Post({
    required String postId,
    required String authorId, // user uid
    required String authorName, // snapshot of user.displayName at posting time
    @Default('user') String authorRole, // copy of user.role for snapshot
    @Default(false)
    bool authorIsVerified, // copy of user.isVerified for snapshot
    @Default('community')
    String category, // e.g. "notice", "community", "qa", "testimony"
    @Default('normal') String type, // "official" | "normal"
    String? parishId, // if the post is specific to a parish
    required String title,
    required String body,
    @Default([]) List<String> imageUrls, // 게시글에 첨부된 이미지 URL 리스트
    @Default(0) int likeCount, // 좋아요 수
    @Default(0) int commentCount, // 댓글 수
    @Default(false) bool isPinned, // 상단 고정 여부
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('published') String status, // "published" | "hidden" | "reported"
  }) = _Post;

  const Post._();

  /// 공식 게시글인지 확인
  bool get isOfficial => type == 'official';

  /// 일반 게시글인지 확인
  bool get isNormal => type == 'normal';

  /// 공지 게시글인지 확인
  bool get isNotice => category == 'notice';

  /// 커뮤니티 게시글인지 확인
  bool get isCommunity => category == 'community';

  /// 게시된 상태인지 확인
  bool get isPublished => status == 'published';

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  /// Firestore Document에서 생성
  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Timestamp를 ISO8601 문자열로 변환 (json_serializable이 파싱할 수 있도록)
    final json = <String, dynamic>{
      'postId': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
      'updatedAt':
          (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
    return Post.fromJson(json);
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // DateTime을 Timestamp로 변환 (toJson은 ISO8601 문자열로 변환됨)
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);
    return json;
  }
}
