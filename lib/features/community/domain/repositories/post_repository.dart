import '../../data/models/post.dart';

/// 게시글 Repository 인터페이스
abstract class PostRepository {
  /// 게시글 생성 (postId 반환)
  ///
  /// 공식 게시글(type == "official")인 경우 authorIsVerified가 true여야 함
  /// 그렇지 않으면 예외 발생
  Future<String> createPost(Post post);

  /// 게시글 업데이트
  Future<void> updatePost(Post post);

  /// 게시글 삭제
  Future<void> deletePost(String postId);

  /// 공식 공지사항 스트림 조회
  ///
  /// 필터 조건:
  /// - category == "notice"
  /// - type == "official"
  /// - status == "published"
  /// - parishId가 제공된 경우 parishId로 추가 필터링
  Stream<List<Post>> watchOfficialNotices({String? parishId});

  /// 커뮤니티 게시글 스트림 조회
  ///
  /// 필터 조건:
  /// - category == "community"
  /// - type == "normal"
  /// - status == "published"
  /// - parishId가 제공된 경우 parishId로 추가 필터링
  Stream<List<Post>> watchCommunityPosts({String? parishId});
}
