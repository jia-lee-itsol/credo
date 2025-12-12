import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../data/models/post.dart';
import '../../data/providers/community_repository_providers.dart';
import '../notifiers/post_form_notifier.dart';
import '../widgets/post_form_fields.dart';
import '../widgets/post_image_picker.dart';
import '../widgets/post_official_settings.dart';

/// 게시글 작성/수정 화면
class PostEditScreen extends ConsumerStatefulWidget {
  final Post? initialPost;
  final String? parishId;

  const PostEditScreen({super.key, this.initialPost, this.parishId});

  @override
  ConsumerState<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends ConsumerState<PostEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.community('initState() 호출됨');
    AppLogger.community('parishId=${widget.parishId}');
    if (widget.initialPost != null) {
      _titleController.text = widget.initialPost!.title;
      _bodyController.text = widget.initialPost!.body;
      AppLogger.community('기존 게시글 수정 모드');
    } else {
      AppLogger.community('새 게시글 작성 모드');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAppUserAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialPost == null ? '게시글 작성' : '게시글 수정'),
        actions: [
          currentAppUserAsync.when(
            data: (currentUser) {
              if (currentUser == null) {
                return const SizedBox.shrink();
              }

              final params = PostFormParams(
                currentUser: currentUser,
                initialPost: widget.initialPost,
                parishId: widget.parishId,
              );

              final formState = ref.watch(postFormNotifierProvider(params));

              return TextButton(
                onPressed: formState.isSubmitting
                    ? null
                    : () {
                        AppLogger.debug('===== 저장 버튼 클릭됨! =====');
                        AppLogger.debug('현재 제목: "${_titleController.text}"');
                        AppLogger.debug('현재 내용: "${_bodyController.text}"');
                        AppLogger.debug(
                          'formState.title: "${formState.title}"',
                        );
                        AppLogger.debug('formState.body: "${formState.body}"');
                        AppLogger.debug(
                          'formState.isSubmitting: ${formState.isSubmitting}',
                        );
                        AppLogger.debug('_submit() 호출 시작...');
                        _submit();
                      },
                child: formState.isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('저장'),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: currentAppUserAsync.when(
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(child: Text('로그인이 필요합니다.'));
          }

          final params = PostFormParams(
            currentUser: currentUser,
            initialPost: widget.initialPost,
            parishId: widget.parishId,
          );

          final formState = ref.watch(postFormNotifierProvider(params));
          final notifier = ref.read(postFormNotifierProvider(params).notifier);
          final primaryColor = ref.watch(liturgyPrimaryColorProvider);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 폼 필드 (제목, 본문)
                PostFormFields(
                  titleController: _titleController,
                  contentController: _bodyController,
                  notifier: notifier,
                ),
                const SizedBox(height: 16),

                // 이미지 선택 섹션
                PostImagePicker(
                  formState: formState,
                  notifier: notifier,
                  onImagePickerTap: () => _showImagePicker(
                    context,
                    notifier,
                    formState.selectedImages.length +
                        formState.imageUrls.length,
                  ),
                ),

                // 공식 계정인 경우 공지/핀 옵션 표시
                if (currentUser.isVerified) ...[
                  const SizedBox(height: 24),
                  PostOfficialSettings(
                    formState: formState,
                    notifier: notifier,
                    primaryColor: primaryColor,
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('에러: $error')),
      ),
    );
  }

  Future<void> _submit() async {
    AppLogger.debug('===== _submit() 호출됨 =====');
    AppLogger.debug('제목 컨트롤러: "${_titleController.text}"');
    AppLogger.debug('내용 컨트롤러: "${_bodyController.text}"');

    if (!_formKey.currentState!.validate()) {
      AppLogger.warning('폼 검증 실패');
      return;
    }
    AppLogger.community('폼 검증 통과');

    final currentAppUserAsync = ref.read(currentAppUserProvider);
    final currentUser = currentAppUserAsync.valueOrNull;

    if (currentUser == null) {
      AppLogger.warning('사용자가 로그인하지 않음');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      }
      return;
    }
    AppLogger.community(
      '사용자 확인: uid=${currentUser.uid}, displayName=${currentUser.displayName}',
    );

    final params = PostFormParams(
      currentUser: currentUser,
      initialPost: widget.initialPost,
      parishId: widget.parishId,
    );
    AppLogger.community('PostFormParams 생성: parishId=${widget.parishId}');

    final notifier = ref.read(postFormNotifierProvider(params).notifier);
    final currentState = ref.read(postFormNotifierProvider(params));
    AppLogger.debug('===== notifier.submit() 호출 시작 =====');
    AppLogger.debug('notifier 상태 확인:');
    AppLogger.debug('   - title: "${currentState.title}"');
    AppLogger.debug(
      '   - body: "${currentState.body.substring(0, currentState.body.length > 100 ? 100 : currentState.body.length)}..."',
    );
    AppLogger.debug('   - category: "${currentState.category}"');
    AppLogger.debug('   - isOfficial: ${currentState.isOfficial}');
    final success = await notifier.submit();
    AppLogger.debug('===== notifier.submit() 완료: success=$success =====');

    if (!mounted) {
      AppLogger.warning('Widget이 unmount됨');
      return;
    }

    if (success) {
      AppLogger.community('게시글 저장 성공');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.initialPost == null ? '게시글이 작성되었습니다.' : '게시글이 수정되었습니다.',
          ),
        ),
      );
      AppLogger.community('Navigator.pop() 호출');
      Navigator.of(context).pop();
    } else {
      AppLogger.error('게시글 저장 실패');
      // 에러 메시지 표시
      final formState = ref.read(postFormNotifierProvider(params));
      if (formState.errorMessage != null) {
        AppLogger.error('에러 메시지: ${formState.errorMessage}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(formState.errorMessage!)));
      } else {
        AppLogger.warning('에러 메시지가 없음');
      }
    }
  }

  Future<void> _showImagePicker(
    BuildContext context,
    PostFormNotifier notifier,
    int currentImageCount,
  ) async {
    await PostImagePickerHelper.showImagePicker(
      context,
      notifier,
      currentImageCount,
      3,
    );
  }
}
