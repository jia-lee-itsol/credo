import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/services/logger_service.dart';
import '../notifiers/post_form_notifier.dart';

/// 게시글 폼 필드 위젯 (제목, 본문)
class PostFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final PostFormNotifier notifier;

  const PostFormFields({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 제목 입력
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'タイトル',
            hintText: 'タイトルを入力してください',
          ),
          validator: Validators.validatePostTitle,
          maxLength: 50,
          onChanged: (value) {
            AppLogger.community('제목 입력: "$value"');
            notifier.setTitle(value);
          },
        ),
        const SizedBox(height: 16),

        // 본문 입력
        TextFormField(
          controller: contentController,
          decoration: const InputDecoration(
            labelText: '本文',
            hintText: '本文を入力してください',
            alignLabelWithHint: true,
          ),
          validator: Validators.validatePostContent,
          maxLines: 10,
          maxLength: 2000,
          onChanged: (value) {
            AppLogger.community('내용 입력: "${value.length}자"');
            notifier.setBody(value);
          },
        ),
      ],
    );
  }
}
