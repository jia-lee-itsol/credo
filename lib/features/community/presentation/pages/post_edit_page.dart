import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/post.dart';
import '../../data/providers/community_repository_providers.dart';
import '../../presentation/notifiers/post_form_notifier.dart';

/// 게시글 작성/수정 페이지
class PostEditPage extends ConsumerStatefulWidget {
  final Post? initialPost;
  final bool isOfficial;
  final String? parishId;

  const PostEditPage({
    super.key,
    this.initialPost,
    required this.isOfficial,
    this.parishId,
  });

  @override
  ConsumerState<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends ConsumerState<PostEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPost != null) {
      _titleController.text = widget.initialPost!.title;
      _bodyController.text = widget.initialPost!.body;
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
                isOfficial: widget.isOfficial,
                parishId: widget.parishId,
              );

              final formState = ref.watch(postFormNotifierProvider(params));

              return TextButton(
                onPressed: formState.isSubmitting ? null : _submit,
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
            error: (_, __) => const SizedBox.shrink(),
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
            isOfficial: widget.isOfficial,
            parishId: widget.parishId,
          );

          final formState = ref.watch(postFormNotifierProvider(params));
          final notifier = ref.read(postFormNotifierProvider(params).notifier);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    hintText: '제목을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '제목을 입력하세요';
                    }
                    return null;
                  },
                  maxLength: 100,
                  onChanged: (value) => notifier.setTitle(value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    hintText: '내용을 입력하세요',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '내용을 입력하세요';
                    }
                    return null;
                  },
                  maxLines: 15,
                  maxLength: 5000,
                  onChanged: (value) => notifier.setBody(value),
                ),
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
    if (!_formKey.currentState!.validate()) return;

    final currentAppUserAsync = ref.read(currentAppUserProvider);
    final currentUser = await currentAppUserAsync.future;

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      }
      return;
    }

    final params = PostFormParams(
      currentUser: currentUser,
      initialPost: widget.initialPost,
      isOfficial: widget.isOfficial,
      parishId: widget.parishId,
    );

    final notifier = ref.read(postFormNotifierProvider(params).notifier);
    final success = await notifier.submit();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.initialPost == null ? '게시글이 작성되었습니다.' : '게시글이 수정되었습니다.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      // 에러 메시지 표시
      final formState = ref.read(postFormNotifierProvider(params));
      if (formState.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(formState.errorMessage!)));
      }
    }
  }
}
