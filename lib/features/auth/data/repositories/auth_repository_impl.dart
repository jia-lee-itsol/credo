import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/data/services/push_notification_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/logger_service.dart';
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
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             scopes: ['email', 'profile'],
             // Web client ID를 serverClientId로 설정
             // google-services.json의 oauth_client에서 client_type: 3인 client_id 사용
             serverClientId:
                 '182699877294-6qcgdug0hnqdkq9j5lkkglgct39qla9f.apps.googleusercontent.com',
           );

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      AppLogger.auth('getCurrentUser() 호출됨');
      final firebaseUser = _auth.currentUser;
      AppLogger.auth(
        'Firebase Auth currentUser: ${firebaseUser?.uid ?? 'null'}',
      );
      AppLogger.auth(
        'Firebase Auth currentUser email: ${firebaseUser?.email ?? 'null'}',
      );
      AppLogger.auth(
        'Firebase Auth currentUser displayName: ${firebaseUser?.displayName ?? 'null'}',
      );

      if (firebaseUser == null) {
        AppLogger.auth('firebaseUser가 null이므로 null 반환');
        return const Right(null);
      }

      AppLogger.auth('Firestore에서 사용자 데이터 조회: ${firebaseUser.uid}');
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      AppLogger.auth('Firestore 문서 존재 여부: ${userDoc.exists}');

      if (!userDoc.exists) {
        AppLogger.auth('Firestore에 사용자 데이터가 없어서 기본 데이터 생성');
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
        AppLogger.auth('기본 사용자 데이터 생성 완료: ${newUser.userId}');
        return Right(newUser);
      }

      final userModel = UserModel.fromFirestore(userDoc);
      final userEntity = userModel.toEntity();
      AppLogger.auth(
        '사용자 데이터 로드 완료: userId=${userEntity.userId}, email=${userEntity.email}',
      );
      return Right(userEntity);
    } on FirebaseException catch (e) {
      AppLogger.error('FirebaseException: ${e.code} - ${e.message}', e);
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Exception: $e', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
    String? mainParishId,
    String? baptismalName,
    String? feastDayId,
  }) async {
    try {
      AppLogger.auth('createUserWithEmailAndPassword 시작');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      AppLogger.auth('createUserWithEmailAndPassword 완료');

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        AppLogger.error('firebaseUser가 null');
        return const Left(AuthFailure(message: 'アカウント作成に失敗しました。'));
      }
      AppLogger.auth('firebaseUser 생성됨: ${firebaseUser.uid}');

      // 사용자 프로필 업데이트
      AppLogger.auth('updateDisplayName 시작: $nickname');
      await firebaseUser.updateDisplayName(nickname);
      AppLogger.auth('updateDisplayName 완료');

      // Firestore에 사용자 데이터 저장
      AppLogger.auth('UserEntity 생성 시작');
      final newUser = UserEntity(
        userId: firebaseUser.uid,
        nickname: nickname,
        email: email,
        mainParishId: mainParishId,
        baptismalName: baptismalName,
        feastDayId: feastDayId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      AppLogger.auth('UserEntity 생성 완료');

      AppLogger.auth('UserModel 변환 시작');
      final userModel = UserModel.fromEntity(newUser);
      AppLogger.auth('UserModel 변환 완료');

      AppLogger.auth('Firestore 저장 시작: users/${firebaseUser.uid}');
      AppLogger.debug('저장할 데이터: ${userModel.toFirestore()}');

      try {
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toFirestore())
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                AppLogger.error('Firestore 저장 타임아웃 (10초)');
                throw TimeoutException('Firestore 저장 타임아웃');
              },
            );
        AppLogger.auth('Firestore 저장 완료');
      } catch (e) {
        AppLogger.error('Firestore 저장 중 에러: $e', e);
        AppLogger.debug('에러 타입: ${e.runtimeType}');
        rethrow;
      }

      AppLogger.auth('signUpWithEmail 성공, Right 반환');
      return Right(newUser);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('FirebaseAuthException: ${e.code} - ${e.message}', e);
      return Left(_handleAuthException(e));
    } on FirebaseException catch (e) {
      AppLogger.error('FirebaseException: ${e.code} - ${e.message}', e);
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unknown Exception: $e', e, stackTrace);
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
      AppLogger.auth('signInWithGoogle() 시작');

      // Google 로그인 플로우 시작
      AppLogger.auth('GoogleSignIn.signIn() 호출');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.auth('사용자가 Google 로그인을 취소함');
        return const Left(AuthFailure(message: 'Googleログインがキャンセルされました。'));
      }

      AppLogger.auth(
        'GoogleSignIn 성공: email=${googleUser.email}, id=${googleUser.id}',
      );

      // Google 인증 정보 가져오기
      AppLogger.auth('GoogleSignInAuthentication 가져오기 시작');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        AppLogger.error('Google 인증 idToken이 null입니다');
        return const Left(AuthFailure(message: 'Google認証情報の取得に失敗しました。'));
      }

      AppLogger.auth(
        'Google 인증 정보 획득 완료: accessToken=${googleAuth.accessToken != null ? "있음" : "없음"}, idToken=${googleAuth.idToken != null ? "있음" : "없음"}',
      );

      // Firebase에 인증 정보 전달
      AppLogger.auth('GoogleAuthProvider.credential 생성');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Auth에 로그인
      AppLogger.auth('Firebase Auth signInWithCredential 시작');
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        AppLogger.error('Firebase Auth userCredential.user가 null입니다');
        return const Left(AuthFailure(message: 'Googleログインに失敗しました。'));
      }

      AppLogger.auth(
        'Firebase Auth 로그인 성공: uid=${firebaseUser.uid}, email=${firebaseUser.email}',
      );

      // Firestore에서 사용자 데이터 확인
      AppLogger.auth('Firestore에서 사용자 데이터 확인: ${firebaseUser.uid}');
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      UserEntity user;
      if (!userDoc.exists) {
        // 새 사용자: Firestore에 사용자 데이터 생성
        AppLogger.auth('새 사용자 - Firestore에 사용자 데이터 생성');
        user = UserEntity(
          userId: firebaseUser.uid,
          nickname:
              firebaseUser.displayName ?? googleUser.displayName ?? 'ユーザー',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        AppLogger.auth(
          'UserEntity 생성 완료: userId=${user.userId}, nickname=${user.nickname}, email=${user.email}',
        );

        AppLogger.auth('Firestore에 사용자 데이터 저장 시작');
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(UserModel.fromEntity(user).toFirestore());
        AppLogger.auth('Firestore에 사용자 데이터 저장 완료');
      } else {
        // 기존 사용자: Firestore에서 데이터 가져오기
        AppLogger.auth('기존 사용자 - Firestore에서 데이터 가져오기');
        final userModel = UserModel.fromFirestore(userDoc);
        user = userModel.toEntity();
        AppLogger.auth(
          '사용자 데이터 로드 완료: userId=${user.userId}, nickname=${user.nickname}',
        );
      }

      AppLogger.auth('signInWithGoogle() 성공 완료');
      return Right(user);
    } on PlatformException catch (e, stackTrace) {
      AppLogger.error(
        'PlatformException: ${e.code} - ${e.message}',
        e,
        stackTrace,
      );

      // Google Sign-In 관련 PlatformException 처리
      if (e.code == 'sign_in_failed') {
        // ApiException: 10은 DEVELOPER_ERROR (설정 오류)
        // 이는 보통 SHA 인증서 미등록 또는 google-services.json 설정 오류
        if (e.message?.contains('ApiException: 10') == true) {
          AppLogger.error(
            'Google Sign-In DEVELOPER_ERROR (ApiException: 10) - SHA 인증서 또는 설정 확인 필요',
            e,
            stackTrace,
          );
          return const Left(
            AuthFailure(message: 'Googleログインに失敗しました。', code: 'developer_error'),
          );
        }
        // 기타 sign_in_failed 에러
        return Left(AuthFailure(message: 'Googleログインに失敗しました。', code: e.code));
      }

      // 기타 PlatformException
      return Left(
        AuthFailure(
          message: 'Googleログイン中にエラーが発生しました: ${e.message ?? e.code}',
          code: e.code,
        ),
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error(
        'FirebaseAuthException: ${e.code} - ${e.message}',
        e,
        stackTrace,
      );
      return Left(_handleAuthException(e));
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error(
        'FirebaseException: ${e.code} - ${e.message}',
        e,
        stackTrace,
      );
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'signInWithGoogle() 예외 발생: ${e.runtimeType} - $e',
        e,
        stackTrace,
      );
      return Left(
        UnknownFailure(message: 'Googleログイン中にエラーが発生しました: ${e.toString()}'),
      );
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
      // FCM 토큰 삭제
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await PushNotificationService().removeTokenForUser(currentUser.uid);
      }

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
      AppLogger.auth('authStateChanges 이벤트 발생');
      AppLogger.auth(
        'Firebase Auth currentUser: ${_auth.currentUser?.uid ?? 'null'}',
      );
      AppLogger.auth(
        'firebaseUser from stream: ${firebaseUser?.uid ?? 'null'}',
      );
      AppLogger.auth('firebaseUser email: ${firebaseUser?.email ?? 'null'}');
      AppLogger.auth(
        'firebaseUser displayName: ${firebaseUser?.displayName ?? 'null'}',
      );

      if (firebaseUser == null) {
        AppLogger.auth('firebaseUser가 null이므로 null 반환');
        return null;
      }

      try {
        AppLogger.auth('Firestore에서 사용자 데이터 조회 시작: ${firebaseUser.uid}');
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        AppLogger.auth('Firestore 문서 존재 여부: ${userDoc.exists}');

        if (!userDoc.exists) {
          AppLogger.auth('Firestore에 사용자 데이터가 없어서 기본 데이터 생성');
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
          AppLogger.auth('기본 사용자 데이터 생성 완료: ${newUser.userId}');
          return newUser;
        }

        final userModel = UserModel.fromFirestore(userDoc);
        final userEntity = userModel.toEntity();
        AppLogger.auth(
          '사용자 데이터 로드 완료: userId=${userEntity.userId}, email=${userEntity.email}, nickname=${userEntity.nickname}',
        );

        // FCM 토큰 저장
        await PushNotificationService().saveTokenForUser(userEntity.userId);

        return userEntity;
      } catch (e, stackTrace) {
        // 에러 발생 시 null 반환
        AppLogger.error('에러 발생: $e', e, stackTrace);
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
      AppLogger.auth('searchUser 호출: email=$email, userId=$userId');
      
      if (email == null && userId == null) {
        AppLogger.auth('검색 파라미터가 없음');
        return const Left(AuthFailure(message: 'メールアドレスまたはユーザーIDを入力してください。'));
      }

      if (userId != null) {
        // userId로 검색 (문서 ID로 직접 조회)
        AppLogger.auth('userId로 검색: $userId');
        final userDoc = await _firestore.collection('users').doc(userId).get();
        AppLogger.auth('문서 존재 여부: ${userDoc.exists}');
        
        if (!userDoc.exists) {
          AppLogger.auth('사용자를 찾을 수 없음 (userId: $userId)');
          return const Right(null);
        }
        
        final userModel = UserModel.fromFirestore(userDoc);
        final userEntity = userModel.toEntity();
        AppLogger.auth('사용자 검색 성공: ${userEntity.userId}, ${userEntity.email}');
        return Right(userEntity);
      } else {
        // email로 검색
        AppLogger.auth('email로 검색: $email');
        final querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        AppLogger.auth('검색 결과 문서 수: ${querySnapshot.docs.length}');

        if (querySnapshot.docs.isEmpty) {
          AppLogger.auth('사용자를 찾을 수 없음 (email: $email)');
          return const Right(null);
        }

        final userDoc = querySnapshot.docs.first;
        final userModel = UserModel.fromFirestore(userDoc);
        final userEntity = userModel.toEntity();
        AppLogger.auth('사용자 검색 성공: ${userEntity.userId}, ${userEntity.email}');
        return Right(userEntity);
      }
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Firebase 에러 발생: ${e.code}, ${e.message}', e, stackTrace);
      return Left(
        FirebaseFailure(message: e.message ?? 'Firebaseエラー', code: e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('검색 에러 발생: $e', e, stackTrace);
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
