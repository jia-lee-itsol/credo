import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Firebase Auth를 사용한 인증 Repository 구현
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return const Right(null);
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        // Firestore에 사용자 데이터가 없으면 기본 데이터 생성
        final newUser = UserEntity(
          userId: firebaseUser.uid,
          nickname: firebaseUser.displayName ?? 'ユーザー',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(UserModel.fromEntity(newUser).toFirestore());
        return Right(newUser);
      }

      final userModel = UserModel.fromFirestore(userDoc);
      return Right(userModel.toEntity());
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      debugPrint('🟡 [AuthRepo] createUserWithEmailAndPassword 시작');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('🟢 [AuthRepo] createUserWithEmailAndPassword 완료');

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        debugPrint('🔴 [AuthRepo] firebaseUser가 null');
        return const Left(AuthFailure(message: 'アカウント作成に失敗しました。'));
      }
      debugPrint('🟢 [AuthRepo] firebaseUser 생성됨: ${firebaseUser.uid}');

      // 사용자 프로필 업데이트
      debugPrint('🟡 [AuthRepo] updateDisplayName 시작: $nickname');
      await firebaseUser.updateDisplayName(nickname);
      debugPrint('🟢 [AuthRepo] updateDisplayName 완료');

      // Firestore에 사용자 데이터 저장
      debugPrint('🟡 [AuthRepo] UserEntity 생성 시작');
      final newUser = UserEntity(
        userId: firebaseUser.uid,
        nickname: nickname,
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      debugPrint('🟢 [AuthRepo] UserEntity 생성 완료');

      debugPrint('🟡 [AuthRepo] UserModel 변환 시작');
      final userModel = UserModel.fromEntity(newUser);
      debugPrint('🟢 [AuthRepo] UserModel 변환 완료');

      debugPrint('🟡 [AuthRepo] Firestore 저장 시작: users/${firebaseUser.uid}');
      debugPrint('🟡 [AuthRepo] 저장할 데이터: ${userModel.toFirestore()}');

      try {
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toFirestore())
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                debugPrint('🔴 [AuthRepo] Firestore 저장 타임아웃 (10초)');
                throw TimeoutException('Firestore 저장 타임아웃');
              },
            );
        debugPrint('🟢 [AuthRepo] Firestore 저장 완료');
      } catch (e) {
        debugPrint('🔴 [AuthRepo] Firestore 저장 중 에러: $e');
        debugPrint('🔴 [AuthRepo] 에러 타입: ${e.runtimeType}');
        rethrow;
      }

      debugPrint('🟢 [AuthRepo] signUpWithEmail 성공, Right 반환');
      return Right(newUser);
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '🔴 [AuthRepo] FirebaseAuthException: ${e.code} - ${e.message}',
      );
      return Left(_handleAuthException(e));
    } on FirebaseException catch (e) {
      debugPrint('🔴 [AuthRepo] FirebaseException: ${e.code} - ${e.message}');
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e, stackTrace) {
      debugPrint('🔴 [AuthRepo] Unknown Exception: $e');
      debugPrint('🔴 [AuthRepo] StackTrace: $stackTrace');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure(message: 'ログインに失敗しました。'));
      }

      // Firestore에서 사용자 데이터 가져오기
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        // Firestore에 사용자 데이터가 없으면 기본 데이터 생성
        final newUser = UserEntity(
          userId: firebaseUser.uid,
          nickname: firebaseUser.displayName ?? 'ユーザー',
          email: firebaseUser.email ?? email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(UserModel.fromEntity(newUser).toFirestore());
        return Right(newUser);
      }

      final userModel = UserModel.fromFirestore(userDoc);
      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      // Google 로그인 플로우 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 사용자가 로그인을 취소함
        return const Left(AuthFailure(message: 'Googleログインがキャンセルされました。'));
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase에 인증 정보 전달
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Auth에 로그인
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return const Left(AuthFailure(message: 'Googleログインに失敗しました。'));
      }

      // Firestore에서 사용자 데이터 확인
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      UserEntity user;
      if (!userDoc.exists) {
        // 새 사용자: Firestore에 사용자 데이터 생성
        user = UserEntity(
          userId: firebaseUser.uid,
          nickname:
              firebaseUser.displayName ?? googleUser.displayName ?? 'ユーザー',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(UserModel.fromEntity(user).toFirestore());
      } else {
        // 기존 사용자: Firestore에서 데이터 가져오기
        final userModel = UserModel.fromFirestore(userDoc);
        user = userModel.toEntity();
      }

      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      // Apple 로그인 요청
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // OAuth Provider 생성
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Firebase Auth에 로그인
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return const Left(AuthFailure(message: 'Appleログインに失敗しました。'));
      }

      // Firestore에서 사용자 데이터 확인
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      UserEntity user;
      if (!userDoc.exists) {
        // 새 사용자: Firestore에 사용자 데이터 생성
        // Apple은 첫 로그인 시에만 fullName을 제공하므로, 없으면 displayName 사용
        final displayName =
            appleCredential.givenName != null &&
                appleCredential.familyName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : firebaseUser.displayName ?? 'ユーザー';

        user = UserEntity(
          userId: firebaseUser.uid,
          nickname: displayName,
          email: firebaseUser.email ?? appleCredential.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(UserModel.fromEntity(user).toFirestore());
      } else {
        // 기존 사용자: Firestore에서 데이터 가져오기
        final userModel = UserModel.fromFirestore(userDoc);
        user = userModel.toEntity();
      }

      return Right(user);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Left(AuthFailure(message: 'Appleログインがキャンセルされました。'));
      }
      return Left(AuthFailure(message: e.message));
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? nickname,
    String? mainParishId,
    List<String>? preferredLanguages,
    List<String>? favoriteParishIds,
    String? feastDayId,
    DateTime? baptismDate,
    DateTime? confirmationDate,
    List<String>? godchildren,
    String? godparentId,
  }) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return const Left(AuthFailure(message: 'ログインが必要です。'));
      }

      // Firestore에서 현재 사용자 데이터 가져오기
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        return const Left(NotFoundFailure(message: 'ユーザーデータが見つかりません。'));
      }

      final currentUserModel = UserModel.fromFirestore(userDoc);
      final updatedUser = currentUserModel.copyWith(
        nickname: nickname ?? currentUserModel.nickname,
        mainParishId: mainParishId ?? currentUserModel.mainParishId,
        preferredLanguages:
            preferredLanguages ?? currentUserModel.preferredLanguages,
        favoriteParishIds:
            favoriteParishIds ?? currentUserModel.favoriteParishIds,
        feastDayId: feastDayId ?? currentUserModel.feastDayId,
        baptismDate: baptismDate ?? currentUserModel.baptismDate,
        confirmationDate: confirmationDate ?? currentUserModel.confirmationDate,
        godchildren: godchildren ?? currentUserModel.godchildren,
        godparentId: godparentId ?? currentUserModel.godparentId,
        updatedAt: DateTime.now(),
      );

      // Firestore 업데이트
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .update(updatedUser.toFirestore());

      // Firebase Auth 프로필도 업데이트
      if (nickname != null) {
        await firebaseUser.updateDisplayName(nickname);
      }

      return Right(updatedUser.toEntity());
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) {
          // Firestore에 사용자 데이터가 없으면 기본 데이터 생성
          final newUser = UserEntity(
            userId: firebaseUser.uid,
            nickname: firebaseUser.displayName ?? 'ユーザー',
            email: firebaseUser.email ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(UserModel.fromEntity(newUser).toFirestore());
          return newUser;
        }

        final userModel = UserModel.fromFirestore(userDoc);
        return userModel.toEntity();
      } catch (e) {
        // 에러 발생 시 null 반환
        return null;
      }
    });
  }

  @override
  Future<Either<Failure, UserEntity?>> searchUser({
    String? email,
    String? userId,
  }) async {
    try {
      if (email == null && userId == null) {
        return const Left(AuthFailure(message: 'メールアドレスまたはユーザーIDを入力してください。'));
      }

      if (userId != null) {
        // userId로 검색 (문서 ID로 직접 조회)
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (!userDoc.exists) {
          return const Right(null);
        }
        final userModel = UserModel.fromFirestore(userDoc);
        return Right(userModel.toEntity());
      } else {
        // email로 검색
        final querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return const Right(null);
        }

        final userDoc = querySnapshot.docs.first;
        final userModel = UserModel.fromFirestore(userDoc);
        return Right(userModel.toEntity());
      }
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return const Left(AuthFailure(message: 'ログインが必要です。'));
      }

      // Firestore에서 사용자 데이터 삭제
      await _firestore.collection('users').doc(firebaseUser.uid).delete();

      // Firebase Auth에서 계정 삭제
      await firebaseUser.delete();

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// Firebase Auth 예외를 Failure로 변환
  Failure _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure(
          message: '登録されていないメールアドレスです。',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'パスワードが正しくありません。',
          code: 'wrong-password',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: '既に使用されているメールアドレスです。',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthFailure(
          message: 'パスワードが弱すぎます。',
          code: 'weak-password',
        );
      case 'invalid-email':
        return const AuthFailure(
          message: '有効なメールアドレスではありません。',
          code: 'invalid-email',
        );
      case 'user-disabled':
        return const AuthFailure(
          message: '無効化されたアカウントです。',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'リクエストが多すぎます。しばらくしてから再度お試しください。',
          code: 'too-many-requests',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          message: '許可されていない操作です。',
          code: 'operation-not-allowed',
        );
      default:
        return AuthFailure(message: e.message ?? '認証エラーが発生しました。', code: e.code);
    }
  }
}
