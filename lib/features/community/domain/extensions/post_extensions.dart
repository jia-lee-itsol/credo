import '../../data/models/post.dart';

/// Post 리스트에 대한 확장 메서드
extension PostListExtension on List<Post> {
  /// 핀 고정된 게시글을 상단에 표시하고, 그 다음 생성 시간순으로 정렬
  List<Post> sortByPinnedAndDate() {
    return [...this]..sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  /// 핀 고정된 게시글을 상단에 표시하고, 그 다음 인기순으로 정렬
  /// 인기 점수 = likeCount (commentCount는 Post 모델에 없으므로 likeCount만 사용)
  List<Post> sortByPinnedAndPopularity() {
    return [...this]..sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      // likeCount로 정렬
      if (b.likeCount != a.likeCount) {
        return b.likeCount.compareTo(a.likeCount);
      }
      // 점수가 같으면 최신순
      return b.createdAt.compareTo(a.createdAt);
    });
  }
}
