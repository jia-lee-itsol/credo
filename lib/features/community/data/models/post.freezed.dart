// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Post _$PostFromJson(Map<String, dynamic> json) {
  return _Post.fromJson(json);
}

/// @nodoc
mixin _$Post {
  String get postId => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError; // user uid
  String get authorName =>
      throw _privateConstructorUsedError; // snapshot of user.displayName at posting time
  String get authorRole =>
      throw _privateConstructorUsedError; // copy of user.role for snapshot
  bool get authorIsVerified =>
      throw _privateConstructorUsedError; // copy of user.isVerified for snapshot
  String get category =>
      throw _privateConstructorUsedError; // e.g. "notice", "community", "qa", "testimony"
  String get type =>
      throw _privateConstructorUsedError; // "official" | "normal"
  String? get parishId =>
      throw _privateConstructorUsedError; // if the post is specific to a parish
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  List<String> get imageUrls =>
      throw _privateConstructorUsedError; // 게시글에 첨부된 이미지 URL 리스트
  List<String> get pdfUrls =>
      throw _privateConstructorUsedError; // 게시글에 첨부된 PDF 파일 URL 리스트
  int get likeCount => throw _privateConstructorUsedError; // 좋아요 수
  int get commentCount => throw _privateConstructorUsedError; // 댓글 수
  bool get isPinned => throw _privateConstructorUsedError; // 상단 고정 여부
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostCopyWith<Post> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCopyWith<$Res> {
  factory $PostCopyWith(Post value, $Res Function(Post) then) =
      _$PostCopyWithImpl<$Res, Post>;
  @useResult
  $Res call({
    String postId,
    String authorId,
    String authorName,
    String authorRole,
    bool authorIsVerified,
    String category,
    String type,
    String? parishId,
    String title,
    String body,
    List<String> imageUrls,
    List<String> pdfUrls,
    int likeCount,
    int commentCount,
    bool isPinned,
    DateTime createdAt,
    DateTime updatedAt,
    String status,
  });
}

/// @nodoc
class _$PostCopyWithImpl<$Res, $Val extends Post>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? authorId = null,
    Object? authorName = null,
    Object? authorRole = null,
    Object? authorIsVerified = null,
    Object? category = null,
    Object? type = null,
    Object? parishId = freezed,
    Object? title = null,
    Object? body = null,
    Object? imageUrls = null,
    Object? pdfUrls = null,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? isPinned = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            postId: null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as String,
            authorId: null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String,
            authorName: null == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String,
            authorRole: null == authorRole
                ? _value.authorRole
                : authorRole // ignore: cast_nullable_to_non_nullable
                      as String,
            authorIsVerified: null == authorIsVerified
                ? _value.authorIsVerified
                : authorIsVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            parishId: freezed == parishId
                ? _value.parishId
                : parishId // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrls: null == imageUrls
                ? _value.imageUrls
                : imageUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            pdfUrls: null == pdfUrls
                ? _value.pdfUrls
                : pdfUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            likeCount: null == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            commentCount: null == commentCount
                ? _value.commentCount
                : commentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isPinned: null == isPinned
                ? _value.isPinned
                : isPinned // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PostImplCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$$PostImplCopyWith(
    _$PostImpl value,
    $Res Function(_$PostImpl) then,
  ) = __$$PostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String postId,
    String authorId,
    String authorName,
    String authorRole,
    bool authorIsVerified,
    String category,
    String type,
    String? parishId,
    String title,
    String body,
    List<String> imageUrls,
    List<String> pdfUrls,
    int likeCount,
    int commentCount,
    bool isPinned,
    DateTime createdAt,
    DateTime updatedAt,
    String status,
  });
}

/// @nodoc
class __$$PostImplCopyWithImpl<$Res>
    extends _$PostCopyWithImpl<$Res, _$PostImpl>
    implements _$$PostImplCopyWith<$Res> {
  __$$PostImplCopyWithImpl(_$PostImpl _value, $Res Function(_$PostImpl) _then)
    : super(_value, _then);

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? authorId = null,
    Object? authorName = null,
    Object? authorRole = null,
    Object? authorIsVerified = null,
    Object? category = null,
    Object? type = null,
    Object? parishId = freezed,
    Object? title = null,
    Object? body = null,
    Object? imageUrls = null,
    Object? pdfUrls = null,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? isPinned = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? status = null,
  }) {
    return _then(
      _$PostImpl(
        postId: null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as String,
        authorId: null == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String,
        authorName: null == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String,
        authorRole: null == authorRole
            ? _value.authorRole
            : authorRole // ignore: cast_nullable_to_non_nullable
                  as String,
        authorIsVerified: null == authorIsVerified
            ? _value.authorIsVerified
            : authorIsVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        parishId: freezed == parishId
            ? _value.parishId
            : parishId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrls: null == imageUrls
            ? _value._imageUrls
            : imageUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        pdfUrls: null == pdfUrls
            ? _value._pdfUrls
            : pdfUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        likeCount: null == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        commentCount: null == commentCount
            ? _value.commentCount
            : commentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isPinned: null == isPinned
            ? _value.isPinned
            : isPinned // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PostImpl extends _Post {
  const _$PostImpl({
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorRole = 'user',
    this.authorIsVerified = false,
    this.category = 'community',
    this.type = 'normal',
    this.parishId,
    required this.title,
    required this.body,
    final List<String> imageUrls = const [],
    final List<String> pdfUrls = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'published',
  }) : _imageUrls = imageUrls,
       _pdfUrls = pdfUrls,
       super._();

  factory _$PostImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostImplFromJson(json);

  @override
  final String postId;
  @override
  final String authorId;
  // user uid
  @override
  final String authorName;
  // snapshot of user.displayName at posting time
  @override
  @JsonKey()
  final String authorRole;
  // copy of user.role for snapshot
  @override
  @JsonKey()
  final bool authorIsVerified;
  // copy of user.isVerified for snapshot
  @override
  @JsonKey()
  final String category;
  // e.g. "notice", "community", "qa", "testimony"
  @override
  @JsonKey()
  final String type;
  // "official" | "normal"
  @override
  final String? parishId;
  // if the post is specific to a parish
  @override
  final String title;
  @override
  final String body;
  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  // 게시글에 첨부된 이미지 URL 리스트
  final List<String> _pdfUrls;
  // 게시글에 첨부된 이미지 URL 리스트
  @override
  @JsonKey()
  List<String> get pdfUrls {
    if (_pdfUrls is EqualUnmodifiableListView) return _pdfUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pdfUrls);
  }

  // 게시글에 첨부된 PDF 파일 URL 리스트
  @override
  @JsonKey()
  final int likeCount;
  // 좋아요 수
  @override
  @JsonKey()
  final int commentCount;
  // 댓글 수
  @override
  @JsonKey()
  final bool isPinned;
  // 상단 고정 여부
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'Post(postId: $postId, authorId: $authorId, authorName: $authorName, authorRole: $authorRole, authorIsVerified: $authorIsVerified, category: $category, type: $type, parishId: $parishId, title: $title, body: $body, imageUrls: $imageUrls, pdfUrls: $pdfUrls, likeCount: $likeCount, commentCount: $commentCount, isPinned: $isPinned, createdAt: $createdAt, updatedAt: $updatedAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostImpl &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorRole, authorRole) ||
                other.authorRole == authorRole) &&
            (identical(other.authorIsVerified, authorIsVerified) ||
                other.authorIsVerified == authorIsVerified) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.parishId, parishId) ||
                other.parishId == parishId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            const DeepCollectionEquality().equals(
              other._imageUrls,
              _imageUrls,
            ) &&
            const DeepCollectionEquality().equals(other._pdfUrls, _pdfUrls) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    postId,
    authorId,
    authorName,
    authorRole,
    authorIsVerified,
    category,
    type,
    parishId,
    title,
    body,
    const DeepCollectionEquality().hash(_imageUrls),
    const DeepCollectionEquality().hash(_pdfUrls),
    likeCount,
    commentCount,
    isPinned,
    createdAt,
    updatedAt,
    status,
  );

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      __$$PostImplCopyWithImpl<_$PostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostImplToJson(this);
  }
}

abstract class _Post extends Post {
  const factory _Post({
    required final String postId,
    required final String authorId,
    required final String authorName,
    final String authorRole,
    final bool authorIsVerified,
    final String category,
    final String type,
    final String? parishId,
    required final String title,
    required final String body,
    final List<String> imageUrls,
    final List<String> pdfUrls,
    final int likeCount,
    final int commentCount,
    final bool isPinned,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String status,
  }) = _$PostImpl;
  const _Post._() : super._();

  factory _Post.fromJson(Map<String, dynamic> json) = _$PostImpl.fromJson;

  @override
  String get postId;
  @override
  String get authorId; // user uid
  @override
  String get authorName; // snapshot of user.displayName at posting time
  @override
  String get authorRole; // copy of user.role for snapshot
  @override
  bool get authorIsVerified; // copy of user.isVerified for snapshot
  @override
  String get category; // e.g. "notice", "community", "qa", "testimony"
  @override
  String get type; // "official" | "normal"
  @override
  String? get parishId; // if the post is specific to a parish
  @override
  String get title;
  @override
  String get body;
  @override
  List<String> get imageUrls; // 게시글에 첨부된 이미지 URL 리스트
  @override
  List<String> get pdfUrls; // 게시글에 첨부된 PDF 파일 URL 리스트
  @override
  int get likeCount; // 좋아요 수
  @override
  int get commentCount; // 댓글 수
  @override
  bool get isPinned; // 상단 고정 여부
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get status;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
