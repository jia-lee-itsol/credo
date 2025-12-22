import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/data/services/image_upload_service.dart';
import '../../../../shared/providers/auth_provider.dart';

/// 프로필 이미지 선택 위젯
class ProfileImagePicker extends ConsumerWidget {
  final Color primaryColor;
  final Function(String imageUrl)? onImageSelected;
  final String? previewImageUrl; // 업로드된 이미지 미리보기 URL

  const ProfileImagePicker({
    super.key,
    required this.primaryColor,
    this.onImageSelected,
    this.previewImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    // 미리보기 이미지가 있으면 우선 사용, 없으면 현재 사용자 이미지 사용
    final profileImageUrl = previewImageUrl ?? currentUser?.profileImageUrl;

    return Center(
      child: GestureDetector(
        onTap: () => _showImagePicker(context, ref),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor.withValues(alpha: 0.2),
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl == null
                  ? Icon(Icons.person, size: 50, color: primaryColor)
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImagePicker(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (pickedFile == null) return;

      // 로딩 표시
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // 이미지 업로드
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        if (context.mounted) Navigator.pop(context);
        return;
      }

      final imageUploadService = ImageUploadService();
      final imageUrl = await imageUploadService.uploadImage(
        imageFile: File(pickedFile.path),
        userId: currentUser.userId,
      );

      // 로딩 닫기
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 콜백 호출
      if (onImageSelected != null) {
        onImageSelected!(imageUrl);
      }

      // 성공 메시지
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 이미지가 업로드되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // 로딩 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드 실패: $e')),
        );
      }
    }
  }
}
