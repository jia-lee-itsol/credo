import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/logger_service.dart';

/// 성당 정보 수정 서비스 (이미지, 주소, 전화번호, 미사시간 등)
class ParishEditService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ImagePicker _picker = ImagePicker();

  /// 성당 필드 업데이트 (일반)
  static Future<void> updateParishField({
    required String parishId,
    required String fieldName,
    required dynamic value,
  }) async {
    try {
      AppLogger.info('[ParishEditService] 필드 업데이트: $fieldName = $value');

      await _firestore.collection('parishes').doc(parishId).set({
        'id': parishId,
        fieldName: value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      AppLogger.info('[ParishEditService] 필드 업데이트 완료');
    } catch (e, stackTrace) {
      AppLogger.error('[ParishEditService] 필드 업데이트 실패', e, stackTrace);
      rethrow;
    }
  }

  /// 주소 업데이트
  static Future<void> updateAddress({
    required String parishId,
    required String address,
  }) async {
    await updateParishField(
      parishId: parishId,
      fieldName: 'address',
      value: address,
    );
  }

  /// 전화번호 업데이트
  static Future<void> updatePhone({
    required String parishId,
    required String phone,
  }) async {
    await updateParishField(
      parishId: parishId,
      fieldName: 'phone',
      value: phone,
    );
  }

  /// 미사 시간 업데이트
  static Future<void> updateMassTimes({
    required String parishId,
    required Map<String, dynamic> massTimes,
  }) async {
    await updateParishField(
      parishId: parishId,
      fieldName: 'massTimes',
      value: massTimes,
    );
  }

  /// 외국어 미사 업데이트
  static Future<void> updateForeignMass({
    required String parishId,
    required List<Map<String, dynamic>> foreignMass,
  }) async {
    await updateParishField(
      parishId: parishId,
      fieldName: 'foreignMass',
      value: foreignMass,
    );
  }

  /// 이미지 선택 (갤러리에서)
  static Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 70,
      );
      return image;
    } catch (e) {
      AppLogger.error('[ParishImageService] 이미지 선택 실패', e);
      return null;
    }
  }

  /// 성당 이미지 업로드
  static Future<String?> uploadParishImage({
    required String parishId,
    required File imageFile,
  }) async {
    try {
      // Storage 경로 설정 - parishId를 안전하게 인코딩
      final safeParishId = Uri.encodeComponent(parishId);
      final fileName = 'parish_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('parishes/$safeParishId/$fileName');

      AppLogger.info('[ParishImageService] 업로드 시작: parishes/$safeParishId/$fileName');

      // 업로드
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.info('[ParishImageService] 이미지 업로드 완료: $downloadUrl');
      return downloadUrl;
    } catch (e, stackTrace) {
      AppLogger.error('[ParishImageService] 이미지 업로드 실패', e, stackTrace);
      rethrow;
    }
  }

  /// 성당 이미지 URL 업데이트 (Firestore)
  static Future<bool> updateParishImageUrl({
    required String parishId,
    required String imageUrl,
  }) async {
    try {
      AppLogger.info('[ParishImageService] Firestore 업데이트 시작: parishId=$parishId');

      // parishes 컬렉션에서 parishId로 문서 찾기
      final querySnapshot = await _firestore
          .collection('parishes')
          .where('id', isEqualTo: parishId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // 문서가 없으면 새로 생성
        AppLogger.info('[ParishImageService] 기존 문서 없음, 새로 생성');
        await _firestore.collection('parishes').doc(parishId).set({
          'id': parishId,
          'imageUrl': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // 기존 문서 업데이트
        AppLogger.info('[ParishImageService] 기존 문서 업데이트: ${querySnapshot.docs.first.id}');
        await querySnapshot.docs.first.reference.update({
          'imageUrl': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      AppLogger.info('[ParishImageService] Firestore 업데이트 완료');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('[ParishImageService] Firestore 업데이트 실패', e, stackTrace);
      rethrow;
    }
  }

  /// 이미지 선택 및 업로드 전체 프로세스
  static Future<String?> pickAndUploadParishImage({
    required String parishId,
  }) async {
    // 1. 이미지 선택
    final pickedFile = await pickImage();
    if (pickedFile == null) {
      AppLogger.info('[ParishImageService] 이미지 선택 취소됨');
      return null; // 사용자가 취소한 경우
    }

    AppLogger.info('[ParishImageService] 이미지 선택됨: ${pickedFile.path}');

    // 2. 업로드
    final imageFile = File(pickedFile.path);
    final imageUrl = await uploadParishImage(
      parishId: parishId,
      imageFile: imageFile,
    );

    // 3. Firestore 업데이트
    await updateParishImageUrl(
      parishId: parishId,
      imageUrl: imageUrl!,
    );

    return imageUrl;
  }

  /// 기존 이미지 삭제
  static Future<bool> deleteParishImage({
    required String imageUrl,
  }) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      AppLogger.info('[ParishImageService] 이미지 삭제 완료');
      return true;
    } catch (e) {
      AppLogger.error('[ParishImageService] 이미지 삭제 실패', e);
      return false;
    }
  }
}
