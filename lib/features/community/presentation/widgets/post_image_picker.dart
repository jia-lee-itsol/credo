import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/app_localizations.dart';
import '../notifiers/post_form_notifier.dart';

/// 게시글 이미지 선택 위젯
class PostImagePicker extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final totalImageCount =
        formState.selectedImages.length + formState.imageUrls.length;
    final canAddMore = totalImageCount < 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.image.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
          l10n.image.max3Images,
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

class _AddImageButton extends ConsumerWidget {
  final VoidCallback onTap;
  final bool isLarge;

  const _AddImageButton({required this.onTap, this.isLarge = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate, size: 32),
              const SizedBox(height: 4),
              Text(l10n.image.add),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate, size: 32),
            const SizedBox(height: 4),
            Text(l10n.image.addButton, style: const TextStyle(fontSize: 12)),
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
    final l10n = AppLocalizations.of(context);
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
      builder: (dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(dialogL10n.image.camera),
                onTap: () => Navigator.pop(dialogContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(dialogL10n.image.gallery),
                onTap: () => Navigator.pop(dialogContext, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: Text(dialogL10n.common.cancel),
                onTap: () => Navigator.pop(dialogContext),
              ),
            ],
          ),
        );
      },
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
    } on PlatformException catch (e) {
      // 권한 관련 에러 처리
      if (context.mounted) {
        String errorMessage = l10n.image.selectFailed;

        if (e.code == 'photo_access_denied' ||
            e.code == 'camera_access_denied' ||
            e.message?.contains('permission') == true ||
            e.message?.contains('権限') == true) {
          errorMessage = l10n.image.permissionRequired;

          // 설정으로 이동 안내 다이얼로그
          final shouldOpen = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              final dialogL10n = AppLocalizations.of(dialogContext);
              return AlertDialog(
                title: Text(dialogL10n.image.permissionRequired),
                content: Text(
                  source == ImageSource.camera
                      ? dialogL10n.image.cameraPermissionMessage
                      : dialogL10n.image.galleryPermissionMessage,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(dialogL10n.common.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(dialogL10n.image.openSettings),
                  ),
                ],
              );
            },
          );

          if (shouldOpen == true && context.mounted) {
            // iOS/Android 설정 앱 열기
            if (Platform.isIOS) {
              // iOS는 직접 설정 앱을 열 수 없으므로 안내만 표시
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.image.permissionDeniedMessage),
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
              // Android는 설정 앱 열기 가능 (permission_handler 필요)
              // 현재는 안내만 표시
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.image.permissionDeniedMessageAlt),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$errorMessage: ${e.message ?? e.code}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.image.selectFailed}: $e')),
        );
      }
    }
  }
}
