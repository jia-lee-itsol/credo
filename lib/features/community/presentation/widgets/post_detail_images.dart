import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'post_image_viewer.dart';

/// 게시글 이미지 썸네일 섹션
class PostDetailImages extends StatelessWidget {
  final List<String> imageUrls;

  const PostDetailImages({super.key, required this.imageUrls});

  void _showImageFullScreen(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PostImageViewer(imageUrls: imageUrls, initialIndex: initialIndex),
      ),
    );
  }

  Widget _buildThumbnailItem(
    BuildContext context,
    List<String> imageUrls,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _showImageFullScreen(context, imageUrls, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image),
              ),
            ),
            // 이미지가 3개 이상일 때 마지막 이미지에 더보기 오버레이
            if (imageUrls.length > 3 && index == 2)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Text(
                    '+${imageUrls.length - 3}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrls.length == 1)
          // 이미지가 1개인 경우 큰 썸네일
          GestureDetector(
            onTap: () => _showImageFullScreen(context, imageUrls, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrls[0],
                fit: BoxFit.contain,
                width: double.infinity,
                height: 200,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          )
        else if (imageUrls.length == 2)
          // 이미지가 2개인 경우 2열 그리드
          Row(
            children: [
              Expanded(child: _buildThumbnailItem(context, imageUrls, 0)),
              const SizedBox(width: 8),
              Expanded(child: _buildThumbnailItem(context, imageUrls, 1)),
            ],
          )
        else
          // 이미지가 3개 이상인 경우 3열 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return _buildThumbnailItem(context, imageUrls, index);
            },
          ),
      ],
    );
  }
}
