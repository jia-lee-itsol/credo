import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../notifiers/post_form_notifier.dart';

/// 게시글 이미지 선택 위젯
class PostImagePicker extends StatelessWidget {
  final PostFormState formState;
  final PostFormNotifier notifier;
  final VoidCallback onImagePickerTap;

  const PostImagePicker({
    super.key,
    required this.formState,
    required this.notifier,
    required this.onImagePickerTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalImageCount =
        formState.selectedImages.length + formState.imageUrls.length;
    final canAddMore = totalImageCount < 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '画像',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        if (totalImageCount > 0 || canAddMore)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: totalImageCount + (canAddMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < formState.selectedImages.length) {
                // 선택된 이미지 (File)
                final imageFile = formState.selectedImages[index];
                return _ImageItem(
                  imageFile: imageFile,
                  onRemove: () => notifier.removeImage(index),
                );
              } else if (index < totalImageCount) {
                // 업로드된 이미지 (URL) - 수정 모드에서만 표시
                final urlIndex = index - formState.selectedImages.length;
                final imageUrl = formState.imageUrls[urlIndex];
                return _ImageItem(imageUrl: imageUrl);
              } else {
                // 이미지 추가 버튼
                return _AddImageButton(onTap: onImagePickerTap);
              }
            },
          )
        else
          _AddImageButton(onTap: onImagePickerTap, isLarge: true),
        const SizedBox(height: 4),
        Text(
          '最大3枚まで添付できます',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _ImageItem extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback? onRemove;

  const _ImageItem({this.imageFile, this.imageUrl, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageFile != null
                ? Image.file(
                    imageFile!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLarge;

  const _AddImageButton({required this.onTap, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    if (isLarge) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade100,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 32),
              SizedBox(height: 4),
              Text('画像を追加'),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade100,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32),
            SizedBox(height: 4),
            Text('追加', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// 이미지 피커 다이얼로그 표시 헬퍼
class PostImagePickerHelper {
  static Future<void> showImagePicker(
    BuildContext context,
    PostFormNotifier notifier,
    int currentImageCount,
    int maxImages,
  ) async {
    // 최대 개수 확인
    if (currentImageCount >= maxImages) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지는 최대 $maxImages개까지 추가할 수 있습니다.')),
        );
      }
      return;
    }

    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラ'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリー'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('キャンセル'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

    if (source == null || !context.mounted) return;

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        notifier.addImage(imageFile);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('画像の選択に失敗しました: $e')));
      }
    }
  }
}
