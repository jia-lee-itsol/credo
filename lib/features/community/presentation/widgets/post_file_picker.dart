import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/app_localizations.dart';
import '../notifiers/post_form_notifier.dart';

/// 게시글 파일 선택 위젯 (이미지 + PDF)
class PostFilePicker extends ConsumerWidget {
  final PostFormState formState;
  final PostFormNotifier notifier;
  final VoidCallback onFilePickerTap;

  const PostFilePicker({
    super.key,
    required this.formState,
    required this.notifier,
    required this.onFilePickerTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final totalImageCount =
        formState.selectedImages.length + formState.imageUrls.length;
    final totalPdfCount =
        formState.selectedPdfs.length + formState.pdfUrls.length;
    final totalFileCount = totalImageCount + totalPdfCount;
    final canAddMore = totalFileCount < 5; // 이미지 3개 + PDF 2개 = 최대 5개

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.community.attachments,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // 이미지 섹션
        if (totalImageCount > 0 || canAddMore) ...[
          Text(
            l10n.image.title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
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
                return _AddFileButton(
                  onTap: () =>
                      _showImagePicker(context, notifier, totalImageCount),
                  icon: Icons.add_photo_alternate,
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],

        // PDF 섹션
        if (totalPdfCount > 0 || canAddMore) ...[
          Text(
            l10n.community.pdfFiles,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          // PDF 목록 (선택된 PDF 파일들)
          if (totalPdfCount > 0)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalPdfCount,
              itemBuilder: (context, index) {
                if (index < formState.selectedPdfs.length) {
                  final pdfFile = formState.selectedPdfs[index];
                  return _PdfItem(
                    pdfFile: pdfFile,
                    onRemove: () => notifier.removePdf(index),
                  );
                } else {
                  final urlIndex = index - formState.selectedPdfs.length;
                  final pdfUrl = formState.pdfUrls[urlIndex];
                  return _PdfItem(pdfUrl: pdfUrl);
                }
              },
            ),
          // PDF 추가 버튼 (이미지와 동일한 그리드 스타일)
          if (canAddMore)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 1,
              itemBuilder: (context, index) {
                return _AddFileButton(
                  onTap: () => _showPdfPicker(context, notifier, totalPdfCount),
                  icon: Icons.picture_as_pdf,
                );
              },
            ),
        ],

        const SizedBox(height: 4),
        Text(
          l10n.community.attachmentsDescription,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Future<void> _showImagePicker(
    BuildContext context,
    PostFormNotifier notifier,
    int currentImageCount,
  ) async {
    await PostFilePickerHelper.showImagePicker(
      context,
      notifier,
      currentImageCount,
      3,
    );
  }

  Future<void> _showPdfPicker(
    BuildContext context,
    PostFormNotifier notifier,
    int currentPdfCount,
  ) async {
    await PostFilePickerHelper.showPdfPicker(
      context,
      notifier,
      currentPdfCount,
      2,
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

class _PdfItem extends StatelessWidget {
  final File? pdfFile;
  final String? pdfUrl;
  final VoidCallback? onRemove;

  const _PdfItem({this.pdfFile, this.pdfUrl, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final fileName =
        pdfFile?.path.split('/').last ??
        (pdfUrl != null ? pdfUrl!.split('/').last.split('?').first : 'PDF');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onRemove,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }
}

class _AddFileButton extends ConsumerWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _AddFileButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
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
            Icon(icon, size: 32),
            const SizedBox(height: 4),
            Text(
              l10n.community.addButton,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// 파일 피커 다이얼로그 표시 헬퍼
class PostFilePickerHelper {
  /// 이미지 피커 표시
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
          SnackBar(
            content: Text(l10n.community.maxImagesReached(max: maxImages)),
          ),
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
        final fileSize = await imageFile.length();
        const maxFileSize = 10 * 1024 * 1024; // 10MB

        if (fileSize > maxFileSize) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.community.imageFileTooLarge),
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        notifier.addImage(imageFile);
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        String errorMessage = l10n.image.selectFailed;

        if (e.code == 'photo_access_denied' ||
            e.code == 'camera_access_denied' ||
            e.message?.contains('permission') == true ||
            e.message?.contains('権限') == true) {
          errorMessage = l10n.image.permissionRequired;

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
            if (Platform.isIOS) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.image.permissionDeniedMessage),
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
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

  /// PDF 피커 표시
  static Future<void> showPdfPicker(
    BuildContext context,
    PostFormNotifier notifier,
    int currentPdfCount,
    int maxPdfs,
  ) async {
    final l10n = AppLocalizations.of(context);
    // 최대 개수 확인
    if (currentPdfCount >= maxPdfs) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.community.maxPdfsReached(max: maxPdfs))),
        );
      }
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
      );

      if (result != null && result.files.single.path != null) {
        final pdfFile = File(result.files.single.path!);
        final fileSize = await pdfFile.length();
        const maxFileSize = 10 * 1024 * 1024; // 10MB

        if (fileSize > maxFileSize) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.community.pdfFileTooLarge),
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        notifier.addPdf(pdfFile);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.community.pdfSelectFailed}: $e')),
        );
      }
    }
  }
}
