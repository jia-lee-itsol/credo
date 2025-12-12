import 'package:flutter/material.dart';

/// 프로필 이미지 선택 위젯
class ProfileImagePicker extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback? onTap;

  const ProfileImagePicker({super.key, required this.primaryColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor.withValues(alpha: 0.2),
              child: Icon(Icons.person, size: 50, color: primaryColor),
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
}
