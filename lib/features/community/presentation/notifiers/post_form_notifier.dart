import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_user.dart';
import '../../data/models/post.dart';
import '../../domain/repositories/post_repository.dart';

/// 게시글 폼 상태
class PostFormState {
  final String title;
  final String body;
  final String category;
  final bool isOfficial;
  final bool isSubmitting;
  final String? errorMessage;

  const PostFormState({
    this.title = '',
    this.body = '',
    this.category = 'community',
    this.isOfficial = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// 복사본 생성
  PostFormState copyWith({
    String? title,
    String? body,
    String? category,
    bool? isOfficial,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return PostFormState(
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      isOfficial: isOfficial ?? this.isOfficial,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// PostFormNotifier 파라미터
class PostFormParams {
  final AppUser currentUser;
  final Post? initialPost;
  final bool isOfficial;
  final String? parishId;

  const PostFormParams({
    required this.currentUser,
    this.initialPost,
    required this.isOfficial,
    this.parishId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostFormParams &&
        other.currentUser == currentUser &&
        other.initialPost == initialPost &&
        other.isOfficial == isOfficial &&
        other.parishId == parishId;
  }

  @override
  int get hashCode {
    return Object.hash(currentUser, initialPost, isOfficial, parishId);
  }
}

/// 게시글 폼 Notifier
class PostFormNotifier extends StateNotifier<PostFormState> {
  final PostRepository _postRepository;
  final AppUser _currentUser;
  final Post? _initialPost;
  final bool _isOfficial;
  final String? _parishId;

  PostFormNotifier({
    required PostRepository postRepository,
    required AppUser currentUser,
    Post? initialPost,
    required bool isOfficial,
    String? parishId,
  }) : _postRepository = postRepository,
       _currentUser = currentUser,
       _initialPost = initialPost,
       _isOfficial = isOfficial,
       _parishId = parishId,
       super(
         PostFormState(
           title: initialPost?.title ?? '',
           body: initialPost?.body ?? '',
           category:
               initialPost?.category ?? (isOfficial ? 'notice' : 'community'),
           isOfficial: isOfficial,
         ),
       );

  /// 제목 설정
  void setTitle(String title) {
    state = state.copyWith(
      title: title,
      errorMessage: null, // 에러 메시지 초기화
    );
  }

  /// 본문 설정
  void setBody(String body) {
    state = state.copyWith(
      body: body,
      errorMessage: null, // 에러 메시지 초기화
    );
  }

  /// 카테고리 설정
  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  /// 제출
  Future<bool> submit() async {
    // 유효성 검사
    final trimmedTitle = state.title.trim();
    final trimmedBody = state.body.trim();

    if (trimmedTitle.isEmpty) {
      state = state.copyWith(errorMessage: '제목을 입력하세요');
      return false;
    }

    if (trimmedBody.isEmpty) {
      state = state.copyWith(errorMessage: '내용을 입력하세요');
      return false;
    }

    // 제출 중 상태로 변경
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final now = DateTime.now();

      if (_initialPost == null) {
        // 새 게시글 생성
        final post = Post(
          postId: '',
          authorId: _currentUser.uid,
          authorName: _currentUser.displayName,
          authorRole: _currentUser.role,
          authorIsVerified: _currentUser.isVerified,
          category: state.category,
          type: _isOfficial ? 'official' : 'normal',
          parishId: _parishId,
          title: trimmedTitle,
          body: trimmedBody,
          createdAt: now,
          updatedAt: now,
          status: 'published',
        );

        await _postRepository.createPost(post);
      } else {
        // 기존 게시글 수정
        final updatedPost = _initialPost!.copyWith(
          title: trimmedTitle,
          body: trimmedBody,
          updatedAt: now,
        );

        await _postRepository.updatePost(updatedPost);
      }

      // 성공 시 제출 중 상태 해제
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      // 오류 발생 시 에러 메시지 설정
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '오류가 발생했습니다: $e',
      );
      return false;
    }
  }
}
