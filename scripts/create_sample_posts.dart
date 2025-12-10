import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Firestore에 샘플 게시글 데이터를 생성하는 스크립트
///
/// 사용법:
///   dart run scripts/create_sample_posts.dart
Future<void> main() async {
  print('🔥 Firebase 초기화 중...');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 초기화 완료');
  } catch (e) {
    print('❌ Firebase 초기화 실패: $e');
    exit(1);
  }

  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();

  // 샘플 게시글 데이터
  final samplePosts = [
    {
      'postId': 'sample-post-1',
      'authorId': 'C8V7SJaUbGfBZDxMExthGTDU8tJ2', // 현재 사용자 UID로 변경 필요
      'authorName': '東京カテドラル',
      'authorRole': 'staff',
      'authorIsVerified': true,
      'category': 'notice',
      'type': 'official',
      'parishId': null,
      'title': '【お知らせ】年末年始のミサ時間について',
      'body':
          '年末年始のミサ時間をお知らせいたします。12月31日は18時から、1月1日は10時からとなります。皆様のご参列をお待ちしております。',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      'status': 'published',
    },
    {
      'postId': 'sample-post-2',
      'authorId': 'C8V7SJaUbGfBZDxMExthGTDU8tJ2',
      'authorName': '聖歌隊担当',
      'authorRole': 'staff',
      'authorIsVerified': true,
      'category': 'notice',
      'type': 'official',
      'parishId': null,
      'title': '聖歌隊メンバー募集中です',
      'body': '聖歌隊では新しいメンバーを募集しています。経験不問、歌うことが好きな方ならどなたでも歓迎します。練習は毎週土曜日の午後です。',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      'status': 'published',
    },
    {
      'postId': 'sample-post-3',
      'authorId': 'C8V7SJaUbGfBZDxMExthGTDU8tJ2',
      'authorName': 'マリア',
      'authorRole': 'user',
      'authorIsVerified': false,
      'category': 'community',
      'type': 'normal',
      'parishId': null,
      'title': '先週のミサで感動しました',
      'body': '先週日曜日のミサに初めて参加しました。神父様のお話がとても心に響きました。これからも通い続けたいと思います。',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 12))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(hours: 12))),
      'status': 'published',
    },
    {
      'postId': 'sample-post-4',
      'authorId': 'C8V7SJaUbGfBZDxMExthGTDU8tJ2',
      'authorName': 'ヨハネ',
      'authorRole': 'user',
      'authorIsVerified': false,
      'category': 'community',
      'type': 'normal',
      'parishId': null,
      'title': '駐車場についての質問',
      'body': '来週の日曜日に家族で伺いたいのですが、教会の駐車場は何台くらい停められますか？また、近くにコインパーキングはありますか？',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 6))),
      'updatedAt': Timestamp.fromDate(now.subtract(const Duration(hours: 6))),
      'status': 'published',
    },
  ];

  print('\n📝 샘플 게시글 생성 중...');

  int successCount = 0;
  int failCount = 0;

  for (final postData in samplePosts) {
    try {
      await firestore
          .collection('posts')
          .doc(postData['postId'] as String)
          .set(postData);
      print('✅ 게시글 생성: ${postData['title']}');
      successCount++;
    } catch (e) {
      print('❌ 게시글 생성 실패: ${postData['title']} - $e');
      failCount++;
    }
  }

  print('\n📊 결과:');
  print('  ✅ 성공: $successCount개');
  print('  ❌ 실패: $failCount개');
  print('\n🎉 완료! Firebase Console에서 posts 컬렉션을 확인하세요.');

  exit(0);
}
