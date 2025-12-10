import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/post.dart';
import '../data/repositories/firestore_post_repository.dart';

/// Firestore에 샘플 게시글 데이터를 생성하는 유틸리티
class CreateSamplePosts {
  final FirestorePostRepository _repository;

  CreateSamplePosts({FirestorePostRepository? repository})
    : _repository = repository ?? FirestorePostRepository();

  /// 샘플 게시글 생성
  ///
  /// [currentUserId] 현재 로그인한 사용자의 UID
  /// [currentUserName] 현재 로그인한 사용자의 이름
  /// [currentUserRole] 현재 로그인한 사용자의 역할
  /// [currentUserIsVerified] 현재 로그인한 사용자의 인증 여부
  Future<List<String>> createSamplePosts({
    required String currentUserId,
    required String currentUserName,
    String currentUserRole = 'user',
    bool currentUserIsVerified = false,
  }) async {
    final now = DateTime.now();
    final createdPostIds = <String>[];

    // 샘플 게시글 목록
    final samplePosts = [
      // 공식 공지사항 1
      Post(
        postId: '',
        authorId: currentUserId,
        authorName: '東京カテドラル',
        authorRole: 'staff',
        authorIsVerified: true,
        category: 'notice',
        type: 'official',
        parishId: null,
        title: '【お知らせ】年末年始のミサ時間について',
        body:
            '年末年始のミサ時間をお知らせいたします。12月31日は18時から、1月1日は10時からとなります。皆様のご参列をお待ちしております。',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        status: 'published',
      ),
      // 공식 공지사항 2
      Post(
        postId: '',
        authorId: currentUserId,
        authorName: '聖歌隊担当',
        authorRole: 'staff',
        authorIsVerified: true,
        category: 'notice',
        type: 'official',
        parishId: null,
        title: '聖歌隊メンバー募集中です',
        body: '聖歌隊では新しいメンバーを募集しています。経験不問、歌うことが好きな方ならどなたでも歓迎します。練習は毎週土曜日の午後です。',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        status: 'published',
      ),
      // 커뮤니티 게시글 1
      Post(
        postId: '',
        authorId: currentUserId,
        authorName: currentUserName,
        authorRole: currentUserRole,
        authorIsVerified: currentUserIsVerified,
        category: 'community',
        type: 'normal',
        parishId: null,
        title: '先週のミサで感動しました',
        body: '先週日曜日のミサに初めて参加しました。神父様のお話がとても心に響きました。これからも通い続けたいと思います。',
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        status: 'published',
      ),
      // 커뮤니티 게시글 2
      Post(
        postId: '',
        authorId: currentUserId,
        authorName: currentUserName,
        authorRole: currentUserRole,
        authorIsVerified: currentUserIsVerified,
        category: 'community',
        type: 'normal',
        parishId: null,
        title: '駐車場についての質問',
        body: '来週の日曜日に家族で伺いたいのですが、教会の駐車場は何台くらい停められますか？また、近くにコインパーキングはありますか？',
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        status: 'published',
      ),
    ];

    // 각 게시글 생성
    for (final post in samplePosts) {
      try {
        final postId = await _repository.createPost(post);
        createdPostIds.add(postId);
      } catch (e) {
        // 에러 발생 시 계속 진행
        print('게시글 생성 실패: ${post.title} - $e');
      }
    }

    return createdPostIds;
  }
}
