import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/failures/community_failures.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/app_user.dart';

/// Firestore를 사용한 사용자 Repository 구현
class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, AppUser?>> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return const Right(null);
      }
      return Right(AppUser.fromFirestore(doc));
    } on FirebaseException catch (e) {
      AppLogger.error('사용자 조회 실패: $e', e);
      return Left(
        FirebaseFailure(message: e.message ?? '사용자 조회 실패', code: e.code),
      );
    } catch (e) {
      AppLogger.error('사용자 조회 실패: $e', e);
      return Left(UserNotFoundFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.error('사용자 저장 실패: $e', e);
      return Left(
        FirebaseFailure(message: e.message ?? '사용자 저장 실패', code: e.code),
      );
    } catch (e) {
      AppLogger.error('사용자 저장 실패: $e', e);
      return Left(UserSaveFailure(message: e.toString()));
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

  @override
  Future<Either<Failure, List<AppUser>>> searchUsersByDisplayName(
    String displayName,
  ) async {
    try {
      AppLogger.community('사용자 검색: displayName=$displayName');

      // displayName으로 시작하는 사용자 검색 (대소문자 구분 없음)
      // Firestore는 대소문자 구분 검색만 지원하므로, 클라이언트에서 필터링
      final snapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: displayName)
          .where('displayName', isLessThanOrEqualTo: '$displayName\uf8ff')
          .limit(10)
          .get();

      final users = snapshot.docs
          .map((doc) {
            try {
              return AppUser.fromFirestore(doc);
            } catch (e) {
              AppLogger.error('사용자 파싱 에러: $e', e);
              return null;
            }
          })
          .whereType<AppUser>()
          .where(
            (user) => user.displayName.toLowerCase().startsWith(
              displayName.toLowerCase(),
            ),
          )
          .toList();

      AppLogger.community('displayName 검색 결과: ${users.length}명');

      // nickname으로도 검색 시도
      final nicknameSnapshot = await _firestore
          .collection('users')
          .where('nickname', isGreaterThanOrEqualTo: displayName)
          .where('nickname', isLessThanOrEqualTo: '$displayName\uf8ff')
          .limit(10)
          .get();

      final nicknameUsers = nicknameSnapshot.docs
          .map((doc) {
            try {
              final user = AppUser.fromFirestore(doc);
              final docData = doc.data() as Map<String, dynamic>?;
              final nickname = docData?['nickname'] as String?;

              // nickname 또는 displayName으로 필터링
              final matchesNickname =
                  nickname?.toLowerCase().startsWith(
                    displayName.toLowerCase(),
                  ) ??
                  false;
              final matchesDisplayName = user.displayName
                  .toLowerCase()
                  .startsWith(displayName.toLowerCase());

              return matchesNickname || matchesDisplayName ? user : null;
            } catch (e) {
              AppLogger.error('nickname 사용자 파싱 에러: $e', e);
              return null;
            }
          })
          .whereType<AppUser>()
          .toList();

      AppLogger.community('nickname 검색 결과: ${nicknameUsers.length}명');

      // 중복 제거
      final allUsers = <AppUser>{...users, ...nicknameUsers};
      final result = allUsers.toList();
      AppLogger.community('최종 검색 결과: ${result.length}명');
      return Right(result);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('검색 에러: $e', e, stackTrace);
      return Left(
        FirebaseFailure(message: e.message ?? '사용자 검색 실패', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('검색 에러: $e', e, stackTrace);
      return Left(UserNotFoundFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppUser>>> getUsersByParishId(
    String parishId,
  ) async {
    try {
      AppLogger.community('성당 소속 사용자 조회: parishId=$parishId');

      // main_parish_id 또는 parishId로 검색
      final snapshot = await _firestore
          .collection('users')
          .where('main_parish_id', isEqualTo: parishId)
          .get();

      final users = snapshot.docs
          .map((doc) {
            try {
              return AppUser.fromFirestore(doc);
            } catch (e) {
              AppLogger.error('사용자 파싱 에러: $e', e);
              return null;
            }
          })
          .whereType<AppUser>()
          .toList();

      AppLogger.community('성당 소속 사용자: ${users.length}명');
      return Right(users);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('성당 소속 사용자 조회 에러: $e', e, stackTrace);
      return Left(
        FirebaseFailure(message: e.message ?? '성당 소속 사용자 조회 실패', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('성당 소속 사용자 조회 에러: $e', e, stackTrace);
      return Left(UserNotFoundFailure(message: e.toString()));
    }
  }
}
