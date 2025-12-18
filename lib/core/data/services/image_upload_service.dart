import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../services/logger_service.dart';
import '../../error/failures.dart';

/// Firebase Storage에 이미지 및 파일을 업로드하는 서비스
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

      // MIME 타입 매핑 (확장자 → MIME 타입)
      final mimeTypeMap = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'gif': 'image/gif',
        'webp': 'image/webp',
      };
      final contentType = mimeTypeMap[extension] ?? 'image/jpeg';

      // Storage 경로 생성
      final fileName = '${_uuid.v4()}.$extension';
      final path = postId != null
          ? 'posts/$postId/$fileName'
          : 'posts/temp/$userId/$fileName';

      AppLogger.image('Storage 경로: $path');
      AppLogger.image('Content-Type: $contentType');

      // 파일 업로드
      AppLogger.image('Storage 인스턴스 확인: ${_storage.app.name}');
      AppLogger.image('Storage 버킷: ${_storage.bucket}');

      final ref = _storage.ref().child(path);
      AppLogger.image('Storage 참조 생성 완료: ${ref.fullPath}');
      AppLogger.image('파일 업로드 시작...');

      AppLogger.image('putFile() 호출 전...');
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      AppLogger.image('putFile() 호출 완료, uploadTask 생성됨');

      // 업로드 진행 상황 모니터링
      final progressSubscription = uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          AppLogger.image(
            '업로드 진행: ${progress.toStringAsFixed(1)}% (${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes)',
          );
        } else {
          AppLogger.image(
            '업로드 진행: ${snapshot.bytesTransferred} bytes (전체 크기 알 수 없음)',
          );
        }
      });

      // 업로드 완료 대기 (타임아웃 추가)
      AppLogger.image('업로드 태스크 대기 중... (타임아웃: 60초)');
      TaskSnapshot snapshot;
      try {
        snapshot = await uploadTask.timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            AppLogger.error('이미지 업로드 타임아웃 (60초)', null);
            progressSubscription.cancel();
            throw TimeoutException('이미지 업로드 타임아웃: 60초 내에 완료되지 않았습니다.');
          },
        );
      } catch (e) {
        progressSubscription.cancel();
        rethrow;
      }
      progressSubscription.cancel();
      AppLogger.image('업로드 태스크 완료, 다운로드 URL 가져오는 중...');

      final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.error('다운로드 URL 가져오기 타임아웃 (10초)', null);
          throw TimeoutException('다운로드 URL 가져오기 타임아웃: 10초 내에 완료되지 않았습니다.');
        },
      );

      AppLogger.image('✅ 이미지 업로드 완료');
      AppLogger.image('다운로드 URL: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Firebase Storage 에러 발생', e, stackTrace);
      AppLogger.error('에러 코드: ${e.code}');
      AppLogger.error('에러 메시지: ${e.message}');
      AppLogger.error('에러 플러그인: ${e.plugin}');
      AppLogger.error('에러 스택: ${e.stackTrace}');

      // 'unknown' 에러의 경우 더 자세한 정보 로깅
      if (e.code == 'unknown') {
        AppLogger.error('⚠️ unknown 에러 - 네트워크 연결 상태를 확인하세요');
        AppLogger.error('파일 크기: ${await imageFile.length()} bytes');
        AppLogger.error(
          'Storage 경로: ${postId != null ? 'posts/$postId/' : 'posts/temp/$userId/'}',
        );
      }

      // 재시도 로직 (일부 에러는 재시도하지 않음)
      final nonRetryableCodes = [
        'unauthorized',
        'permission-denied',
        'unauthenticated',
      ];

      // 'unknown' 에러는 네트워크 문제일 수 있으므로 재시도
      if (retryCount < maxRetries - 1 &&
          (!nonRetryableCodes.contains(e.code) || e.code == 'unknown')) {
        final delaySeconds = 2 * (retryCount + 1); // 더 긴 딜레이
        AppLogger.image(
          '🔄 재시도 중... (${retryCount + 2}/$maxRetries, $delaySeconds초 후)',
        );
        await Future.delayed(Duration(seconds: delaySeconds));
        return uploadImage(
          imageFile: imageFile,
          userId: userId,
          postId: postId,
          retryCount: retryCount + 1,
        );
      }

      // 사용자 친화적인 에러 메시지
      String userMessage;
      if (e.code == 'unknown') {
        userMessage = '네트워크 연결을 확인하고 다시 시도해주세요.';
      } else if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        userMessage = '업로드 권한이 없습니다. 로그인 상태를 확인해주세요.';
      } else {
        userMessage = e.message ?? '이미지 업로드에 실패했습니다.';
      }

      throw FirebaseFailure(message: userMessage, code: e.code);
    } on TimeoutException catch (e, stackTrace) {
      AppLogger.error('이미지 업로드 타임아웃: $e', e, stackTrace);

      // 타임아웃은 재시도
      if (retryCount < maxRetries - 1) {
        final delaySeconds = 3 * (retryCount + 1);
        AppLogger.image(
          '🔄 재시도 중... (${retryCount + 2}/$maxRetries, $delaySeconds초 후)',
        );
        await Future.delayed(Duration(seconds: delaySeconds));
        return uploadImage(
          imageFile: imageFile,
          userId: userId,
          postId: postId,
          retryCount: retryCount + 1,
        );
      }

      throw FirebaseFailure(
        message: '이미지 업로드 시간이 초과되었습니다. 네트워크 연결을 확인하고 다시 시도해주세요.',
        code: 'timeout',
      );
    } catch (e, stackTrace) {
      AppLogger.error('이미지 업로드 실패 (알 수 없는 에러): $e', e, stackTrace);
      AppLogger.error('에러 타입: ${e.runtimeType}');

      // 알 수 없는 에러도 재시도 (네트워크 문제일 수 있음)
      if (retryCount < maxRetries - 1) {
        final delaySeconds = 2 * (retryCount + 1);
        AppLogger.image(
          '🔄 재시도 중... (${retryCount + 2}/$maxRetries, $delaySeconds초 후)',
        );
        await Future.delayed(Duration(seconds: delaySeconds));
        return uploadImage(
          imageFile: imageFile,
          userId: userId,
          postId: postId,
          retryCount: retryCount + 1,
        );
      }

      throw FirebaseFailure(
        message: '이미지 업로드에 실패했습니다. 네트워크 연결을 확인하고 다시 시도해주세요.',
      );
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

  /// PDF 파일을 Firebase Storage에 업로드
  /// 반환: 업로드된 PDF 파일의 다운로드 URL
  Future<String> uploadPdf({
    required File pdfFile,
    required String userId,
    String? postId,
    String? commentId,
    int retryCount = 0,
  }) async {
    const maxRetries = 3;
    const maxFileSize = 10 * 1024 * 1024; // 10MB

    try {
      AppLogger.image('PDF 업로드 시작 (시도: ${retryCount + 1}/$maxRetries)');
      AppLogger.image('파일 경로: ${pdfFile.path}');

      final fileSize = await pdfFile.length();
      AppLogger.image(
        '파일 크기: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
      );

      // 파일 크기 확인
      if (fileSize > maxFileSize) {
        throw ValidationFailure(message: 'PDF 파일 크기는 10MB를 초과할 수 없습니다.');
      }

      // 파일 확장자 추출
      final extension = pdfFile.path.split('.').last.toLowerCase();
      if (extension != 'pdf') {
        throw ValidationFailure(message: 'PDF 파일만 업로드할 수 있습니다: $extension');
      }

      // Storage 경로 생성
      final fileName = '${_uuid.v4()}.pdf';
      String path;
      if (postId != null) {
        path = commentId != null
            ? 'posts/$postId/comments/$commentId/$fileName'
            : 'posts/$postId/$fileName';
      } else {
        path = 'posts/temp/$userId/$fileName';
      }

      AppLogger.image('Storage 경로: $path');
      AppLogger.image('Content-Type: application/pdf');

      // 파일 업로드
      final ref = _storage.ref().child(path);
      AppLogger.image('파일 업로드 시작...');

      final uploadTask = ref.putFile(
        pdfFile,
        SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'fileType': 'pdf',
          },
        ),
      );

      // 업로드 진행 상황 모니터링
      final progressSubscription = uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          AppLogger.image(
            '업로드 진행: ${progress.toStringAsFixed(1)}% (${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes)',
          );
        }
      });

      // 업로드 완료 대기
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 120), // PDF는 더 큰 파일이므로 타임아웃을 120초로 설정
        onTimeout: () {
          AppLogger.error('PDF 업로드 타임아웃 (120초)', null);
          progressSubscription.cancel();
          throw TimeoutException('PDF 업로드 타임아웃: 120초 내에 완료되지 않았습니다.');
        },
      );
      progressSubscription.cancel();

      final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.error('다운로드 URL 가져오기 타임아웃 (10초)', null);
          throw TimeoutException('다운로드 URL 가져오기 타임아웃: 10초 내에 완료되지 않았습니다.');
        },
      );

      AppLogger.image('✅ PDF 업로드 완료');
      AppLogger.image('다운로드 URL: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Firebase Storage 에러 발생', e, stackTrace);

      final nonRetryableCodes = [
        'unauthorized',
        'permission-denied',
        'unauthenticated',
      ];

      if (retryCount < maxRetries - 1 &&
          (!nonRetryableCodes.contains(e.code) || e.code == 'unknown')) {
        final delaySeconds = 2 * (retryCount + 1);
        AppLogger.image(
          '🔄 재시도 중... (${retryCount + 2}/$maxRetries, $delaySeconds초 후)',
        );
        await Future.delayed(Duration(seconds: delaySeconds));
        return uploadPdf(
          pdfFile: pdfFile,
          userId: userId,
          postId: postId,
          commentId: commentId,
          retryCount: retryCount + 1,
        );
      }

      String userMessage;
      if (e.code == 'unknown') {
        userMessage = '네트워크 연결을 확인하고 다시 시도해주세요.';
      } else if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        userMessage = '업로드 권한이 없습니다. 로그인 상태를 확인해주세요.';
      } else {
        userMessage = e.message ?? 'PDF 업로드에 실패했습니다.';
      }

      throw FirebaseFailure(message: userMessage, code: e.code);
    } on TimeoutException catch (e, stackTrace) {
      AppLogger.error('PDF 업로드 타임아웃: $e', e, stackTrace);

      if (retryCount < maxRetries - 1) {
        final delaySeconds = 3 * (retryCount + 1);
        AppLogger.image(
          '🔄 재시도 중... (${retryCount + 2}/$maxRetries, $delaySeconds초 후)',
        );
        await Future.delayed(Duration(seconds: delaySeconds));
        return uploadPdf(
          pdfFile: pdfFile,
          userId: userId,
          postId: postId,
          commentId: commentId,
          retryCount: retryCount + 1,
        );
      }

      throw FirebaseFailure(
        message: 'PDF 업로드 시간이 초과되었습니다. 네트워크 연결을 확인하고 다시 시도해주세요.',
        code: 'timeout',
      );
    } catch (e, stackTrace) {
      AppLogger.error('PDF 업로드 실패 (알 수 없는 에러): $e', e, stackTrace);

      if (retryCount < maxRetries - 1) {
        final delaySeconds = 2 * (retryCount + 1);
        AppLogger.image(
          '🔄 재시도 중... (${retryCount + 2}/$maxRetries, $delaySeconds초 후)',
        );
        await Future.delayed(Duration(seconds: delaySeconds));
        return uploadPdf(
          pdfFile: pdfFile,
          userId: userId,
          postId: postId,
          commentId: commentId,
          retryCount: retryCount + 1,
        );
      }

      throw FirebaseFailure(
        message: 'PDF 업로드에 실패했습니다. 네트워크 연결을 확인하고 다시 시도해주세요.',
      );
    }
  }

  /// 여러 PDF 파일을 순차적으로 업로드
  Future<List<String>> uploadPdfs({
    required List<File> pdfFiles,
    required String userId,
    String? postId,
    String? commentId,
  }) async {
    final urls = <String>[];
    for (var i = 0; i < pdfFiles.length; i++) {
      AppLogger.image('PDF ${i + 1}/${pdfFiles.length} 업로드 중...');
      final url = await uploadPdf(
        pdfFile: pdfFiles[i],
        userId: userId,
        postId: postId,
        commentId: commentId,
      );
      urls.add(url);
    }
    return urls;
  }

  /// PDF 파일 삭제
  Future<void> deletePdf(String pdfUrl) async {
    try {
      final ref = _storage.refFromURL(pdfUrl);
      await ref.delete();
      AppLogger.image('✅ PDF 삭제 완료: $pdfUrl');
    } catch (e) {
      AppLogger.error('PDF 삭제 실패: $e', e);
      // 삭제 실패해도 계속 진행 (이미 삭제된 경우 등)
    }
  }
}
