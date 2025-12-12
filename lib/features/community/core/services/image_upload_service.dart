import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/error/failures.dart';

/// Firebase Storage에 이미지를 업로드하는 서비스
class ImageUploadService {
  final FirebaseStorage _storage;
  final Uuid _uuid;

  ImageUploadService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance,
      _uuid = const Uuid();

  /// 이미지 파일을 Firebase Storage에 업로드
  /// 반환: 업로드된 이미지의 다운로드 URL
  Future<String> uploadImage({
    required File imageFile,
    required String userId,
    String? postId,
    int retryCount = 0,
  }) async {
    const maxRetries = 3;

    try {
      AppLogger.image('이미지 업로드 시작 (시도: ${retryCount + 1}/$maxRetries)');
      AppLogger.image('파일 경로: ${imageFile.path}');
      AppLogger.image('파일 크기: ${await imageFile.length()} bytes');

      // 파일 확장자 추출
      final extension = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        throw ValidationFailure(message: '지원하지 않는 이미지 형식입니다: $extension');
      }

      // Storage 경로 생성
      final fileName = '${_uuid.v4()}.$extension';
      final path = postId != null
          ? 'posts/$postId/$fileName'
          : 'posts/temp/$userId/$fileName';

      AppLogger.image('Storage 경로: $path');

      // 파일 업로드
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/$extension',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // 업로드 완료 대기
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.image('✅ 이미지 업로드 완료');
      AppLogger.image('다운로드 URL: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      AppLogger.error('이미지 업로드 실패: $e', e, stackTrace);

      // 재시도 로직
      if (retryCount < maxRetries - 1) {
        AppLogger.image('🔄 재시도 중... (${retryCount + 2}/$maxRetries)');
        await Future.delayed(
          Duration(seconds: 1 * (retryCount + 1)),
        ); // 점점 길어지는 딜레이
        return uploadImage(
          imageFile: imageFile,
          userId: userId,
          postId: postId,
          retryCount: retryCount + 1,
        );
      }

      throw FirebaseFailure(message: '이미지 업로드 실패: $e');
    }
  }

  /// 여러 이미지를 순차적으로 업로드
  Future<List<String>> uploadImages({
    required List<File> imageFiles,
    required String userId,
    String? postId,
  }) async {
    final urls = <String>[];
    for (var i = 0; i < imageFiles.length; i++) {
      AppLogger.image('이미지 ${i + 1}/${imageFiles.length} 업로드 중...');
      final url = await uploadImage(
        imageFile: imageFiles[i],
        userId: userId,
        postId: postId,
      );
      urls.add(url);
    }
    return urls;
  }

  /// 이미지 삭제
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      AppLogger.image('✅ 이미지 삭제 완료: $imageUrl');
    } catch (e) {
      AppLogger.error('이미지 삭제 실패: $e', e);
      // 삭제 실패해도 계속 진행 (이미 삭제된 경우 등)
    }
  }
}
