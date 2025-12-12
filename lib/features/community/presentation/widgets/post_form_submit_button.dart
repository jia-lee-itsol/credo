import 'package:flutter/material.dart';

/// 게시글 폼 제출 버튼 위젯
class PostFormSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;
  final Color primaryColor;
  final String buttonText;

  const PostFormSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
    required this.primaryColor,
    this.buttonText = '投稿する',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
