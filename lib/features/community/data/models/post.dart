import 'package:cloud_firestore/cloud_firestore.dart';

/// 게시글 모델 (Firestore /posts/{postId} 컬렉션)
class Post {
  final String postId;
  final String authorId; // user uid
  final String authorName; // snapshot of user.displayName at posting time
  final String authorRole; // copy of user.role for snapshot
  final bool authorIsVerified; // copy of user.isVerified for snapshot
  final String category; // e.g. "notice", "community", "qa", "testimony"
  final String type; // "official" | "normal"
  final String? parishId; // if the post is specific to a parish
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // "published" | "hidden" | "reported"

  const Post({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.authorIsVerified,
    required this.category,
    required this.type,
    this.parishId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  /// 공식 게시글인지 확인
  bool get isOfficial => type == 'official';

  /// 일반 게시글인지 확인
  bool get isNormal => type == 'normal';

  /// 공지 게시글인지 확인
  bool get isNotice => category == 'notice';

  /// 커뮤니티 게시글인지 확인
  bool get isCommunity => category == 'community';

  /// 게시된 상태인지 확인
  bool get isPublished => status == 'published';

  /// Firestore Document에서 생성
  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post.fromJson({'postId': doc.id, ...data});
  }

  /// JSON에서 생성
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorRole: json['authorRole'] as String? ?? 'user',
      authorIsVerified: json['authorIsVerified'] as bool? ?? false,
      category: json['category'] as String? ?? 'community',
      type: json['type'] as String? ?? 'normal',
      parishId: json['parishId'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      status: json['status'] as String? ?? 'published',
    );
  }

  /// Firestore Timestamp를 DateTime으로 변환
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorIsVerified': authorIsVerified,
      'category': category,
      'type': type,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
    };

    if (parishId != null) {
      map['parishId'] = parishId;
    }

    return map;
  }

  /// 복사본 생성 (일부 필드만 업데이트)
  Post copyWith({
    String? postId,
    String? authorId,
    String? authorName,
    String? authorRole,
    bool? authorIsVerified,
    String? category,
    String? type,
    String? parishId,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return Post(
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorIsVerified: authorIsVerified ?? this.authorIsVerified,
      category: category ?? this.category,
      type: type ?? this.type,
      parishId: parishId ?? this.parishId,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Post(postId: $postId, title: $title, type: $type, category: $category, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post && other.postId == postId;
  }

  @override
  int get hashCode => postId.hashCode;
}
