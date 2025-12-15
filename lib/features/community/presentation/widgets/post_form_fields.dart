import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/services/logger_service.dart';
import '../notifiers/post_form_notifier.dart';

/// 게시글 폼 필드 위젯 (제목, 본문)
class PostFormFields extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Column(
      children: [
        // 제목 입력
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: l10n.validation.titleRequired.replaceAll(
              'を入力してください',
              '',
            ),
            hintText: l10n.validation.titleRequired,
          ),
          validator: (value) => Validators.validatePostTitle(value, l10n),
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
          decoration: InputDecoration(
            labelText: l10n.validation.contentRequired.replaceAll(
              'を入力してください',
              '',
            ),
            hintText: l10n.validation.contentRequired,
            alignLabelWithHint: true,
          ),
          validator: (value) => Validators.validatePostContent(value, l10n),
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
