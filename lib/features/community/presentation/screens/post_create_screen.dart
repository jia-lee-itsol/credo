import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../config/routes/app_routes.dart';
import '../providers/community_presentation_providers.dart';
import '../notifiers/post_form_notifier.dart';
import '../widgets/post_form_fields.dart';
import '../widgets/post_image_picker.dart';
import '../widgets/post_official_settings.dart';
import '../widgets/post_form_submit_button.dart';

/// 게시글 작성 화면
class PostCreateScreen extends ConsumerStatefulWidget {
  final String parishId;

  const PostCreateScreen({super.key, required this.parishId});

  @override
  ConsumerState<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends ConsumerState<PostCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.community('PostCreateScreen initState() 호출됨');
    AppLogger.community('parishId: ${widget.parishId}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // 로그인하지 않은 경우 로그인 화면으로 리다이렉트
    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final l10n = ref.read(appLocalizationsSyncProvider);
            return AlertDialog(
              title: Text(l10n.auth.loginRequired),
              content: Text(l10n.auth.loginRequiredMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(AppRoutes.home);
                  },
                  child: Text(l10n.common.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push(AppRoutes.signIn);
                  },
                  child: Text(
                    l10n.auth.signIn,
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            );
          },
        );
      });
    }

    final currentAppUserAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.community.newPost)),
      body: currentAppUserAsync.when(
        data: (currentUser) {
          if (currentUser == null) {
            return Center(child: Text(l10n.auth.loginRequired));
          }

          final params = PostFormParams(
            currentUser: currentUser,
            initialPost: null,
            parishId: widget.parishId,
          );

          final formState = ref.watch(postFormNotifierProvider(params));
          final notifier = ref.read(postFormNotifierProvider(params).notifier);

          // 공식 계정인지 확인
          final isVerifiedUser = currentUser.isVerified;

          return Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 폼 필드 (제목, 본문)
                      PostFormFields(
                        titleController: _titleController,
                        contentController: _contentController,
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
                          formState.selectedImages.length,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 공식 계정인 경우 공지/핀 옵션 표시
                      if (isVerifiedUser) ...[
                        const SizedBox(height: 16),
                        PostOfficialSettings(
                          formState: formState,
                          notifier: notifier,
                          primaryColor: primaryColor,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // 이용 규약 안내
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.community.guidelines,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 하단 투고 버튼
              PostFormSubmitButton(
                isSubmitting: formState.isSubmitting,
                onPressed: () => _submit(notifier),
                primaryColor: primaryColor,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
    );
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

  Future<void> _submit(PostFormNotifier notifier) async {
    AppLogger.community('===== _submit() 호출됨 =====');
    AppLogger.community('제목 컨트롤러: "${_titleController.text}"');
    AppLogger.community('내용 컨트롤러: "${_contentController.text}"');

    if (!_formKey.currentState!.validate()) {
      AppLogger.warning('폼 검증 실패');
      return;
    }
    AppLogger.community('폼 검증 통과');
    AppLogger.community('parishId=${widget.parishId}');

    AppLogger.community('===== notifier.submit() 호출 시작 =====');
    final success = await notifier.submit();
    AppLogger.community('===== notifier.submit() 완료: success=$success =====');

    if (!mounted) {
      AppLogger.warning('Widget이 unmount됨');
      return;
    }

    if (success) {
      AppLogger.community('게시글 저장 성공');
      // 게시물 목록 provider를 invalidate하여 새로고침
      ref.invalidate(allPostsProvider(widget.parishId));
      AppLogger.community('allPostsProvider invalidate 완료');

      final l10n = ref.read(appLocalizationsSyncProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.community.postCreated)));
      AppLogger.community('context.pop() 호출');
      context.pop();
    } else {
      AppLogger.error('게시글 저장 실패');
      final l10n = ref.read(appLocalizationsSyncProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.community.postCreateFailed),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
