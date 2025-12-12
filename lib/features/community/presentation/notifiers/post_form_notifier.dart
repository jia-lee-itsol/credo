import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/logger_service.dart';
import '../../core/services/image_upload_service.dart';
import '../../data/models/app_user.dart';
import '../../data/models/notification.dart' as models;
import '../../data/models/post.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// 게시글 폼 상태
class PostFormState {
  final String title;
  final String body;
  final String category;
  final bool isOfficial;
  final bool isPinned;
  final bool isSubmitting;
  final String? errorMessage;
  final List<File> selectedImages; // 선택된 이미지 파일들
  final List<String> imageUrls; // 업로드된 이미지 URL들

  const PostFormState({
    this.title = '',
    this.body = '',
    this.category = 'community',
    this.isOfficial = false,
    this.isPinned = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.selectedImages = const [],
    this.imageUrls = const [],
  });

  /// 복사본 생성
  PostFormState copyWith({
    String? title,
    String? body,
    String? category,
    bool? isOfficial,
    bool? isPinned,
    bool? isSubmitting,
    String? errorMessage,
    List<File>? selectedImages,
    List<String>? imageUrls,
  }) {
    return PostFormState(
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      isOfficial: isOfficial ?? this.isOfficial,
      isPinned: isPinned ?? this.isPinned,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedImages: selectedImages ?? this.selectedImages,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

/// PostFormNotifier 파라미터
class PostFormParams {
  final AppUser currentUser;
  final Post? initialPost;
  final String? parishId;

  const PostFormParams({
    required this.currentUser,
    this.initialPost,
    this.parishId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostFormParams &&
        other.currentUser == currentUser &&
        other.initialPost == initialPost &&
        other.parishId == parishId;
  }

  @override
  int get hashCode {
    return Object.hash(currentUser, initialPost, parishId);
  }
}

/// 게시글 폼 Notifier
class PostFormNotifier extends StateNotifier<PostFormState> {
  final PostRepository _postRepository;
  final UserRepository? _userRepository;
  final NotificationRepository? _notificationRepository;
  final AppUser _currentUser;
  final Post? _initialPost;
  final String? _parishId;
  final ImageUploadService _imageUploadService;

  PostFormNotifier({
    required PostRepository postRepository,
    UserRepository? userRepository,
    NotificationRepository? notificationRepository,
    required AppUser currentUser,
    Post? initialPost,
    String? parishId,
    ImageUploadService? imageUploadService,
  }) : _postRepository = postRepository,
       _userRepository = userRepository,
       _notificationRepository = notificationRepository,
       _currentUser = currentUser,
       _initialPost = initialPost,
       _parishId = parishId,
       _imageUploadService = imageUploadService ?? ImageUploadService(),
       super(
         PostFormState(
           title: initialPost?.title ?? '',
           body: initialPost?.body ?? '',
           category: initialPost?.category ?? 'community',
           isOfficial: initialPost?.isOfficial ?? false,
           isPinned: initialPost?.isPinned ?? false,
           imageUrls: initialPost?.imageUrls ?? [],
         ),
       );

  /// 제목 설정
  void setTitle(String title) {
    AppLogger.community('setTitle 호출: "$title"');
    state = state.copyWith(
      title: title,
      errorMessage: null, // 에러 메시지 초기화
    );
  }

  /// 본문 설정
  void setBody(String body) {
    AppLogger.community(
      'setBody 호출: "${body.substring(0, body.length > 50 ? 50 : body.length)}..."',
    );
    state = state.copyWith(
      body: body,
      errorMessage: null, // 에러 메시지 초기화
    );
  }

  /// 카테고리 설정
  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  /// 공식 게시글 설정
  void setIsOfficial(bool isOfficial) {
    state = state.copyWith(
      isOfficial: isOfficial,
      category: isOfficial ? 'notice' : 'community',
    );
  }

  /// 핀 고정 설정
  void setIsPinned(bool isPinned) {
    state = state.copyWith(isPinned: isPinned);
  }

  /// 이미지 추가
  void addImage(File imageFile) {
    final updatedImages = [...state.selectedImages, imageFile];
    state = state.copyWith(selectedImages: updatedImages);
  }

  /// 이미지 제거
  void removeImage(int index) {
    final updatedImages = List<File>.from(state.selectedImages);
    updatedImages.removeAt(index);
    state = state.copyWith(selectedImages: updatedImages);
  }

  /// 제출
  Future<bool> submit() async {
    AppLogger.debug('===== submit() 시작 =====');
    AppLogger.debug(
      '현재 상태: title="${state.title}", body="${state.body}", category="${state.category}"',
    );
    AppLogger.debug('isOfficial: ${state.isOfficial}');
    AppLogger.debug('isPinned: ${state.isPinned}');
    AppLogger.debug('_parishId: $_parishId');
    AppLogger.debug('_currentUser.uid: ${_currentUser.uid}');
    AppLogger.debug('_currentUser.displayName: ${_currentUser.displayName}');

    // 유효성 검사
    final trimmedTitle = state.title.trim();
    final trimmedBody = state.body.trim();

    if (trimmedTitle.isEmpty) {
      AppLogger.warning('제목이 비어있음');
      state = state.copyWith(errorMessage: 'タイトルを入力してください');
      return false;
    }

    if (trimmedBody.isEmpty) {
      AppLogger.warning('내용이 비어있음');
      state = state.copyWith(errorMessage: '本文を入力してください');
      return false;
    }

    AppLogger.community('유효성 검사 통과');
    // 제출 중 상태로 변경
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final now = DateTime.now();

      // 이미지 업로드
      List<String> uploadedImageUrls = List.from(state.imageUrls);
      if (state.selectedImages.isNotEmpty) {
        AppLogger.image('이미지 업로드 시작: ${state.selectedImages.length}개');
        final urls = await _imageUploadService.uploadImages(
          imageFiles: state.selectedImages,
          userId: _currentUser.uid,
        );
        uploadedImageUrls.addAll(urls);
        AppLogger.image('이미지 업로드 완료: ${uploadedImageUrls.length}개');
      }

      if (_initialPost == null) {
        // 새 게시글 생성
        AppLogger.community('===== 게시글 작성 시작 =====');
        AppLogger.community(
          '사용자 정보: uid=${_currentUser.uid}, displayName=${_currentUser.displayName}',
        );
        AppLogger.community(
          '게시글 정보: title=$trimmedTitle, category=${state.category}, type=${state.isOfficial ? 'official' : 'normal'}, parishId=$_parishId',
        );

        final post = Post(
          postId: '',
          authorId: _currentUser.uid,
          authorName: _currentUser.displayName,
          authorRole: _currentUser.role,
          authorIsVerified: _currentUser.isVerified,
          category: state.category,
          type: state.isOfficial ? 'official' : 'normal',
          parishId: _parishId,
          title: trimmedTitle,
          body: trimmedBody,
          imageUrls: uploadedImageUrls,
          isPinned: state.isPinned,
          createdAt: now,
          updatedAt: now,
          status: 'published',
        );

        AppLogger.debug('===== Post 객체 생성 완료 =====');
        AppLogger.debug('Post 객체 상세:');
        AppLogger.debug('   - postId: ${post.postId}');
        AppLogger.debug('   - authorId: ${post.authorId}');
        AppLogger.debug('   - authorName: ${post.authorName}');
        AppLogger.debug('   - authorRole: ${post.authorRole}');
        AppLogger.debug('   - authorIsVerified: ${post.authorIsVerified}');
        AppLogger.debug('   - category: ${post.category}');
        AppLogger.debug('   - type: ${post.type}');
        AppLogger.debug('   - parishId: ${post.parishId}');
        AppLogger.debug('   - title: ${post.title}');
        AppLogger.debug(
          '   - body: ${post.body.substring(0, post.body.length > 100 ? 100 : post.body.length)}...',
        );
        AppLogger.debug('   - status: ${post.status}');
        AppLogger.debug('   - createdAt: ${post.createdAt}');
        AppLogger.debug('   - updatedAt: ${post.updatedAt}');

        final postJson = post.toFirestore();
        AppLogger.debug('===== Post.toFirestore() 결과 =====');
        postJson.forEach((key, value) {
          AppLogger.debug('   $key: $value (${value.runtimeType})');
        });
        AppLogger.debug('====================================');

        AppLogger.community('_postRepository.createPost() 호출 시작...');
        final result = await _postRepository.createPost(post);
        final postId = result.fold((failure) {
          AppLogger.error('게시글 생성 실패: ${failure.message}', failure);
          throw Exception(failure.message);
        }, (id) => id);
        AppLogger.community('===== 게시글 생성 성공: postId=$postId =====');

        // 공지 게시글인 경우 성당 소속 사용자들에게 알림 전송
        if (state.isOfficial &&
            _parishId != null &&
            _userRepository != null &&
            _notificationRepository != null) {
          await _sendNoticeNotifications(
            postId: postId,
            title: trimmedTitle,
            body: trimmedBody,
          );
        }
      } else {
        // 기존 게시글 수정
        // else 블록에 들어왔으므로 _initialPost는 null이 아님
        final initialPost = _initialPost;
        AppLogger.community('게시글 수정 시작: postId=${initialPost.postId}');
        AppLogger.community(
          'isOfficial: ${state.isOfficial}, isPinned: ${state.isPinned}',
        );
        final updatedPost = initialPost.copyWith(
          title: trimmedTitle,
          body: trimmedBody,
          imageUrls: uploadedImageUrls,
          category: state.category,
          type: state.isOfficial ? 'official' : 'normal',
          isPinned: state.isPinned,
          updatedAt: now,
        );

        final updateResult = await _postRepository.updatePost(updatedPost);
        updateResult.fold(
          (failure) {
            AppLogger.error('게시글 수정 실패: ${failure.message}', failure);
            throw Exception(failure.message);
          },
          (_) {
            AppLogger.community('✅ 게시글 수정 성공');
          },
        );
      }

      // 성공 시 제출 중 상태 해제
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e, stackTrace) {
      // 오류 발생 시 에러 메시지 설정
      AppLogger.error('게시글 저장 실패: $e', e, stackTrace);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '게시글 저장에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  /// 공지 알림 전송 (성당 소속 사용자들에게)
  Future<void> _sendNoticeNotifications({
    required String postId,
    required String title,
    required String body,
  }) async {
    try {
      AppLogger.notification('공지 알림 전송 시작: parishId=$_parishId');

      // 성당 소속 사용자 목록 조회
      final membersResult = await _userRepository!.getUsersByParishId(
        _parishId!,
      );

      final parishMembers = membersResult.fold((failure) {
        AppLogger.error('성당 소속 사용자 조회 실패: ${failure.message}', failure);
        return <AppUser>[];
      }, (members) => members);

      AppLogger.notification('성당 소속 사용자: ${parishMembers.length}명');

      // 각 사용자에게 알림 생성 (작성자 본인 제외)
      for (final member in parishMembers) {
        if (member.uid == _currentUser.uid) {
          AppLogger.notification('작성자 본인 제외: ${member.uid}');
          continue;
        }

        final notification = models.AppNotification(
          notificationId: '',
          userId: member.uid,
          type: 'notice',
          title: '新しいお知らせ',
          body: title,
          postId: postId,
          authorId: _currentUser.uid,
          authorName: _currentUser.displayName,
          isRead: false,
          createdAt: DateTime.now(),
        );

        final notificationResult = await _notificationRepository!
            .createNotification(notification);
        notificationResult.fold(
          (failure) {
            AppLogger.error(
              '알림 생성 실패 (userId=${member.uid}): ${failure.message}',
              failure,
            );
          },
          (_) {
            AppLogger.notification('알림 생성 완료: userId=${member.uid}');
          },
        );
      }

      AppLogger.notification('공지 알림 전송 완료');
    } catch (e, stackTrace) {
      AppLogger.error('공지 알림 전송 실패: $e', e, stackTrace);
    }
  }
}
