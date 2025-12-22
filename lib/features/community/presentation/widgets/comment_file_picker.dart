import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/app_localizations.dart';

/// 댓글 파일 선택 상태
class CommentFileState {
  final List<File> selectedImages;
  final List<File> selectedPdfs;

  const CommentFileState({
    this.selectedImages = const [],
    this.selectedPdfs = const [],
  });

  CommentFileState copyWith({
    List<File>? selectedImages,
    List<File>? selectedPdfs,
  }) {
    return CommentFileState(
      selectedImages: selectedImages ?? this.selectedImages,
      selectedPdfs: selectedPdfs ?? this.selectedPdfs,
    );
  }

  int get totalFileCount => selectedImages.length + selectedPdfs.length;
  bool get canAddMore => totalFileCount < 3; // 댓글은 최대 3개 (이미지 2개 + PDF 1개)
}

/// 댓글 파일 선택 위젯
class CommentFilePicker extends ConsumerStatefulWidget {
  final CommentFileState fileState;
  final ValueChanged<CommentFileState> onFileStateChanged;

  const CommentFilePicker({
    super.key,
    required this.fileState,
    required this.onFileStateChanged,
  });

  @override
  ConsumerState<CommentFilePicker> createState() => _CommentFilePickerState();
}

class _CommentFilePickerState extends ConsumerState<CommentFilePicker> {
  Future<void> _showImagePicker() async {
    final l10n = AppLocalizations.of(context);
    if (widget.fileState.selectedImages.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.community.maxImagesReached(max: 2))),
      );
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

        widget.onFileStateChanged(
          widget.fileState.copyWith(
            selectedImages: [...widget.fileState.selectedImages, imageFile],
          ),
        );
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.image.selectFailed}: ${e.message ?? e.code}'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.image.selectFailed}: $e')),
        );
      }
    }
  }

  Future<void> _showPdfPicker() async {
    final l10n = AppLocalizations.of(context);
    if (widget.fileState.selectedPdfs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.community.maxPdfsReached(max: 1))),
      );
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

        widget.onFileStateChanged(
          widget.fileState.copyWith(
            selectedPdfs: [...widget.fileState.selectedPdfs, pdfFile],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.community.pdfSelectFailed}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsSyncProvider);

    if (widget.fileState.totalFileCount == 0 && !widget.fileState.canAddMore) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 선택된 파일 표시
        if (widget.fileState.selectedImages.isNotEmpty ||
            widget.fileState.selectedPdfs.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...widget.fileState.selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                return Chip(
                  avatar: const Icon(Icons.image, size: 18),
                  label: Text('画像 ${index + 1}'),
                  onDeleted: () {
                    final updatedImages = List<File>.from(
                      widget.fileState.selectedImages,
                    );
                    updatedImages.removeAt(index);
                    widget.onFileStateChanged(
                      widget.fileState.copyWith(selectedImages: updatedImages),
                    );
                  },
                );
              }),
              ...widget.fileState.selectedPdfs.asMap().entries.map((entry) {
                final index = entry.key;
                final pdfFile = entry.value;
                final fileName = pdfFile.path.split('/').last;
                return Chip(
                  avatar: const Icon(
                    Icons.picture_as_pdf,
                    size: 18,
                    color: Colors.red,
                  ),
                  label: Text(
                    fileName.length > 15
                        ? '${fileName.substring(0, 15)}...'
                        : fileName,
                  ),
                  onDeleted: () {
                    final updatedPdfs = List<File>.from(
                      widget.fileState.selectedPdfs,
                    );
                    updatedPdfs.removeAt(index);
                    widget.onFileStateChanged(
                      widget.fileState.copyWith(selectedPdfs: updatedPdfs),
                    );
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // 파일 추가 버튼
        if (widget.fileState.canAddMore)
          Row(
            children: [
              if (widget.fileState.selectedImages.length < 2)
                TextButton.icon(
                  onPressed: _showImagePicker,
                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                  label: Text(l10n.image.addButton),
                ),
              if (widget.fileState.selectedPdfs.isEmpty)
                TextButton.icon(
                  onPressed: _showPdfPicker,
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: Text(l10n.community.addFile),
                ),
            ],
          ),
      ],
    );
  }
}
