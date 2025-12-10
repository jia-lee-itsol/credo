import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/app_user.dart';

/// Firestore를 사용한 사용자 Repository 구현
class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AppUser?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return null;
      }
      return AppUser.fromFirestore(doc);
    } catch (e) {
      throw Exception('사용자 조회 실패: $e');
    }
  }

  @override
  Future<void> saveUser(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('사용자 저장 실패: $e');
    }
  }

  @override
  Stream<AppUser?> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return AppUser.fromFirestore(snapshot);
    });
  }
}
