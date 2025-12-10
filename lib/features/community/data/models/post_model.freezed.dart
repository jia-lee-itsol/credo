// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PostModel _$PostModelFromJson(Map<String, dynamic> json) {
  return _PostModel.fromJson(json);
}

/// @nodoc
mixin _$PostModel {
  @JsonKey(name: 'post_id')
  String get postId => throw _privateConstructorUsedError;
  @JsonKey(name: 'parish_id')
  String? get parishId => throw _privateConstructorUsedError; // 본당별 공지/게시판 분리용 (옵션)
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_official')
  bool get isOfficial => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_pinned')
  bool get isPinned => throw _privateConstructorUsedError;
  @JsonKey(name: 'like_count')
  int get likeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'comment_count')
  int get commentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_nickname')
  String? get authorNickname => throw _privateConstructorUsedError; // 스냅샷용
  @JsonKey(name: 'author_profile_image')
  String? get authorProfileImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_role')
  String? get authorRole => throw _privateConstructorUsedError; // 스냅샷용
  @JsonKey(name: 'author_is_verified')
  bool get authorIsVerified => throw _privateConstructorUsedError; // 스냅샷용
  String get category =>
      throw _privateConstructorUsedError; // "notice" | "community" | "qa" | "testimony" ...
  String get type =>
      throw _privateConstructorUsedError; // "official" | "normal"
  String get status =>
      throw _privateConstructorUsedError; // "published" | "hidden" | "reported" ...
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PostModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostModelCopyWith<PostModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostModelCopyWith<$Res> {
  factory $PostModelCopyWith(PostModel value, $Res Function(PostModel) then) =
      _$PostModelCopyWithImpl<$Res, PostModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'post_id') String postId,
    @JsonKey(name: 'parish_id') String? parishId,
    @JsonKey(name: 'user_id') String userId,
    String title,
    String content,
    @JsonKey(name: 'is_official') bool isOfficial,
    @JsonKey(name: 'is_pinned') bool isPinned,
    @JsonKey(name: 'like_count') int likeCount,
    @JsonKey(name: 'comment_count') int commentCount,
    @JsonKey(name: 'author_nickname') String? authorNickname,
    @JsonKey(name: 'author_profile_image') String? authorProfileImage,
    @JsonKey(name: 'author_role') String? authorRole,
    @JsonKey(name: 'author_is_verified') bool authorIsVerified,
    String category,
    String type,
    String status,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$PostModelCopyWithImpl<$Res, $Val extends PostModel>
    implements $PostModelCopyWith<$Res> {
  _$PostModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? parishId = freezed,
    Object? userId = null,
    Object? title = null,
    Object? content = null,
    Object? isOfficial = null,
    Object? isPinned = null,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? authorNickname = freezed,
    Object? authorProfileImage = freezed,
    Object? authorRole = freezed,
    Object? authorIsVerified = null,
    Object? category = null,
    Object? type = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            postId: null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as String,
            parishId: freezed == parishId
                ? _value.parishId
                : parishId // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            isOfficial: null == isOfficial
                ? _value.isOfficial
                : isOfficial // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPinned: null == isPinned
                ? _value.isPinned
                : isPinned // ignore: cast_nullable_to_non_nullable
                      as bool,
            likeCount: null == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            commentCount: null == commentCount
                ? _value.commentCount
                : commentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            authorNickname: freezed == authorNickname
                ? _value.authorNickname
                : authorNickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorProfileImage: freezed == authorProfileImage
                ? _value.authorProfileImage
                : authorProfileImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorRole: freezed == authorRole
                ? _value.authorRole
                : authorRole // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PostModelImplCopyWith<$Res>
    implements $PostModelCopyWith<$Res> {
  factory _$$PostModelImplCopyWith(
    _$PostModelImpl value,
    $Res Function(_$PostModelImpl) then,
  ) = __$$PostModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'post_id') String postId,
    @JsonKey(name: 'parish_id') String? parishId,
    @JsonKey(name: 'user_id') String userId,
    String title,
    String content,
    @JsonKey(name: 'is_official') bool isOfficial,
    @JsonKey(name: 'is_pinned') bool isPinned,
    @JsonKey(name: 'like_count') int likeCount,
    @JsonKey(name: 'comment_count') int commentCount,
    @JsonKey(name: 'author_nickname') String? authorNickname,
    @JsonKey(name: 'author_profile_image') String? authorProfileImage,
    @JsonKey(name: 'author_role') String? authorRole,
    @JsonKey(name: 'author_is_verified') bool authorIsVerified,
    String category,
    String type,
    String status,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$PostModelImplCopyWithImpl<$Res>
    extends _$PostModelCopyWithImpl<$Res, _$PostModelImpl>
    implements _$$PostModelImplCopyWith<$Res> {
  __$$PostModelImplCopyWithImpl(
    _$PostModelImpl _value,
    $Res Function(_$PostModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? parishId = freezed,
    Object? userId = null,
    Object? title = null,
    Object? content = null,
    Object? isOfficial = null,
    Object? isPinned = null,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? authorNickname = freezed,
    Object? authorProfileImage = freezed,
    Object? authorRole = freezed,
    Object? authorIsVerified = null,
    Object? category = null,
    Object? type = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$PostModelImpl(
        postId: null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as String,
        parishId: freezed == parishId
            ? _value.parishId
            : parishId // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        isOfficial: null == isOfficial
            ? _value.isOfficial
            : isOfficial // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPinned: null == isPinned
            ? _value.isPinned
            : isPinned // ignore: cast_nullable_to_non_nullable
                  as bool,
        likeCount: null == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        commentCount: null == commentCount
            ? _value.commentCount
            : commentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        authorNickname: freezed == authorNickname
            ? _value.authorNickname
            : authorNickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorProfileImage: freezed == authorProfileImage
            ? _value.authorProfileImage
            : authorProfileImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorRole: freezed == authorRole
            ? _value.authorRole
            : authorRole // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PostModelImpl extends _PostModel {
  const _$PostModelImpl({
    @JsonKey(name: 'post_id') required this.postId,
    @JsonKey(name: 'parish_id') this.parishId,
    @JsonKey(name: 'user_id') required this.userId,
    required this.title,
    required this.content,
    @JsonKey(name: 'is_official') this.isOfficial = false,
    @JsonKey(name: 'is_pinned') this.isPinned = false,
    @JsonKey(name: 'like_count') this.likeCount = 0,
    @JsonKey(name: 'comment_count') this.commentCount = 0,
    @JsonKey(name: 'author_nickname') this.authorNickname,
    @JsonKey(name: 'author_profile_image') this.authorProfileImage,
    @JsonKey(name: 'author_role') this.authorRole,
    @JsonKey(name: 'author_is_verified') this.authorIsVerified = false,
    this.category = 'community',
    this.type = 'normal',
    this.status = 'published',
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : super._();

  factory _$PostModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostModelImplFromJson(json);

  @override
  @JsonKey(name: 'post_id')
  final String postId;
  @override
  @JsonKey(name: 'parish_id')
  final String? parishId;
  // 본당별 공지/게시판 분리용 (옵션)
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String title;
  @override
  final String content;
  @override
  @JsonKey(name: 'is_official')
  final bool isOfficial;
  @override
  @JsonKey(name: 'is_pinned')
  final bool isPinned;
  @override
  @JsonKey(name: 'like_count')
  final int likeCount;
  @override
  @JsonKey(name: 'comment_count')
  final int commentCount;
  @override
  @JsonKey(name: 'author_nickname')
  final String? authorNickname;
  // 스냅샷용
  @override
  @JsonKey(name: 'author_profile_image')
  final String? authorProfileImage;
  @override
  @JsonKey(name: 'author_role')
  final String? authorRole;
  // 스냅샷용
  @override
  @JsonKey(name: 'author_is_verified')
  final bool authorIsVerified;
  // 스냅샷용
  @override
  @JsonKey()
  final String category;
  // "notice" | "community" | "qa" | "testimony" ...
  @override
  @JsonKey()
  final String type;
  // "official" | "normal"
  @override
  @JsonKey()
  final String status;
  // "published" | "hidden" | "reported" ...
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'PostModel(postId: $postId, parishId: $parishId, userId: $userId, title: $title, content: $content, isOfficial: $isOfficial, isPinned: $isPinned, likeCount: $likeCount, commentCount: $commentCount, authorNickname: $authorNickname, authorProfileImage: $authorProfileImage, authorRole: $authorRole, authorIsVerified: $authorIsVerified, category: $category, type: $type, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostModelImpl &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.parishId, parishId) ||
                other.parishId == parishId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isOfficial, isOfficial) ||
                other.isOfficial == isOfficial) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.authorNickname, authorNickname) ||
                other.authorNickname == authorNickname) &&
            (identical(other.authorProfileImage, authorProfileImage) ||
                other.authorProfileImage == authorProfileImage) &&
            (identical(other.authorRole, authorRole) ||
                other.authorRole == authorRole) &&
            (identical(other.authorIsVerified, authorIsVerified) ||
                other.authorIsVerified == authorIsVerified) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    postId,
    parishId,
    userId,
    title,
    content,
    isOfficial,
    isPinned,
    likeCount,
    commentCount,
    authorNickname,
    authorProfileImage,
    authorRole,
    authorIsVerified,
    category,
    type,
    status,
    createdAt,
    updatedAt,
  );

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostModelImplCopyWith<_$PostModelImpl> get copyWith =>
      __$$PostModelImplCopyWithImpl<_$PostModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostModelImplToJson(this);
  }
}

abstract class _PostModel extends PostModel {
  const factory _PostModel({
    @JsonKey(name: 'post_id') required final String postId,
    @JsonKey(name: 'parish_id') final String? parishId,
    @JsonKey(name: 'user_id') required final String userId,
    required final String title,
    required final String content,
    @JsonKey(name: 'is_official') final bool isOfficial,
    @JsonKey(name: 'is_pinned') final bool isPinned,
    @JsonKey(name: 'like_count') final int likeCount,
    @JsonKey(name: 'comment_count') final int commentCount,
    @JsonKey(name: 'author_nickname') final String? authorNickname,
    @JsonKey(name: 'author_profile_image') final String? authorProfileImage,
    @JsonKey(name: 'author_role') final String? authorRole,
    @JsonKey(name: 'author_is_verified') final bool authorIsVerified,
    final String category,
    final String type,
    final String status,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$PostModelImpl;
  const _PostModel._() : super._();

  factory _PostModel.fromJson(Map<String, dynamic> json) =
      _$PostModelImpl.fromJson;

  @override
  @JsonKey(name: 'post_id')
  String get postId;
  @override
  @JsonKey(name: 'parish_id')
  String? get parishId; // 본당별 공지/게시판 분리용 (옵션)
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get title;
  @override
  String get content;
  @override
  @JsonKey(name: 'is_official')
  bool get isOfficial;
  @override
  @JsonKey(name: 'is_pinned')
  bool get isPinned;
  @override
  @JsonKey(name: 'like_count')
  int get likeCount;
  @override
  @JsonKey(name: 'comment_count')
  int get commentCount;
  @override
  @JsonKey(name: 'author_nickname')
  String? get authorNickname; // 스냅샷용
  @override
  @JsonKey(name: 'author_profile_image')
  String? get authorProfileImage;
  @override
  @JsonKey(name: 'author_role')
  String? get authorRole; // 스냅샷용
  @override
  @JsonKey(name: 'author_is_verified')
  bool get authorIsVerified; // 스냅샷용
  @override
  String get category; // "notice" | "community" | "qa" | "testimony" ...
  @override
  String get type; // "official" | "normal"
  @override
  String get status; // "published" | "hidden" | "reported" ...
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostModelImplCopyWith<_$PostModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) {
  return _CommentModel.fromJson(json);
}

/// @nodoc
mixin _$CommentModel {
  @JsonKey(name: 'comment_id')
  String get commentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'post_id')
  String get postId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_nickname')
  String? get authorNickname => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_profile_image')
  String? get authorProfileImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_official')
  bool get isOfficial => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CommentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentModelCopyWith<CommentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentModelCopyWith<$Res> {
  factory $CommentModelCopyWith(
    CommentModel value,
    $Res Function(CommentModel) then,
  ) = _$CommentModelCopyWithImpl<$Res, CommentModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'comment_id') String commentId,
    @JsonKey(name: 'post_id') String postId,
    @JsonKey(name: 'user_id') String userId,
    String content,
    @JsonKey(name: 'author_nickname') String? authorNickname,
    @JsonKey(name: 'author_profile_image') String? authorProfileImage,
    @JsonKey(name: 'is_official') bool isOfficial,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$CommentModelCopyWithImpl<$Res, $Val extends CommentModel>
    implements $CommentModelCopyWith<$Res> {
  _$CommentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commentId = null,
    Object? postId = null,
    Object? userId = null,
    Object? content = null,
    Object? authorNickname = freezed,
    Object? authorProfileImage = freezed,
    Object? isOfficial = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            commentId: null == commentId
                ? _value.commentId
                : commentId // ignore: cast_nullable_to_non_nullable
                      as String,
            postId: null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            authorNickname: freezed == authorNickname
                ? _value.authorNickname
                : authorNickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorProfileImage: freezed == authorProfileImage
                ? _value.authorProfileImage
                : authorProfileImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            isOfficial: null == isOfficial
                ? _value.isOfficial
                : isOfficial // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommentModelImplCopyWith<$Res>
    implements $CommentModelCopyWith<$Res> {
  factory _$$CommentModelImplCopyWith(
    _$CommentModelImpl value,
    $Res Function(_$CommentModelImpl) then,
  ) = __$$CommentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'comment_id') String commentId,
    @JsonKey(name: 'post_id') String postId,
    @JsonKey(name: 'user_id') String userId,
    String content,
    @JsonKey(name: 'author_nickname') String? authorNickname,
    @JsonKey(name: 'author_profile_image') String? authorProfileImage,
    @JsonKey(name: 'is_official') bool isOfficial,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$CommentModelImplCopyWithImpl<$Res>
    extends _$CommentModelCopyWithImpl<$Res, _$CommentModelImpl>
    implements _$$CommentModelImplCopyWith<$Res> {
  __$$CommentModelImplCopyWithImpl(
    _$CommentModelImpl _value,
    $Res Function(_$CommentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commentId = null,
    Object? postId = null,
    Object? userId = null,
    Object? content = null,
    Object? authorNickname = freezed,
    Object? authorProfileImage = freezed,
    Object? isOfficial = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$CommentModelImpl(
        commentId: null == commentId
            ? _value.commentId
            : commentId // ignore: cast_nullable_to_non_nullable
                  as String,
        postId: null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        authorNickname: freezed == authorNickname
            ? _value.authorNickname
            : authorNickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorProfileImage: freezed == authorProfileImage
            ? _value.authorProfileImage
            : authorProfileImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        isOfficial: null == isOfficial
            ? _value.isOfficial
            : isOfficial // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentModelImpl extends _CommentModel {
  const _$CommentModelImpl({
    @JsonKey(name: 'comment_id') required this.commentId,
    @JsonKey(name: 'post_id') required this.postId,
    @JsonKey(name: 'user_id') required this.userId,
    required this.content,
    @JsonKey(name: 'author_nickname') this.authorNickname,
    @JsonKey(name: 'author_profile_image') this.authorProfileImage,
    @JsonKey(name: 'is_official') this.isOfficial = false,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : super._();

  factory _$CommentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentModelImplFromJson(json);

  @override
  @JsonKey(name: 'comment_id')
  final String commentId;
  @override
  @JsonKey(name: 'post_id')
  final String postId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String content;
  @override
  @JsonKey(name: 'author_nickname')
  final String? authorNickname;
  @override
  @JsonKey(name: 'author_profile_image')
  final String? authorProfileImage;
  @override
  @JsonKey(name: 'is_official')
  final bool isOfficial;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'CommentModel(commentId: $commentId, postId: $postId, userId: $userId, content: $content, authorNickname: $authorNickname, authorProfileImage: $authorProfileImage, isOfficial: $isOfficial, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentModelImpl &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.authorNickname, authorNickname) ||
                other.authorNickname == authorNickname) &&
            (identical(other.authorProfileImage, authorProfileImage) ||
                other.authorProfileImage == authorProfileImage) &&
            (identical(other.isOfficial, isOfficial) ||
                other.isOfficial == isOfficial) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    commentId,
    postId,
    userId,
    content,
    authorNickname,
    authorProfileImage,
    isOfficial,
    createdAt,
  );

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentModelImplCopyWith<_$CommentModelImpl> get copyWith =>
      __$$CommentModelImplCopyWithImpl<_$CommentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentModelImplToJson(this);
  }
}

abstract class _CommentModel extends CommentModel {
  const factory _CommentModel({
    @JsonKey(name: 'comment_id') required final String commentId,
    @JsonKey(name: 'post_id') required final String postId,
    @JsonKey(name: 'user_id') required final String userId,
    required final String content,
    @JsonKey(name: 'author_nickname') final String? authorNickname,
    @JsonKey(name: 'author_profile_image') final String? authorProfileImage,
    @JsonKey(name: 'is_official') final bool isOfficial,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$CommentModelImpl;
  const _CommentModel._() : super._();

  factory _CommentModel.fromJson(Map<String, dynamic> json) =
      _$CommentModelImpl.fromJson;

  @override
  @JsonKey(name: 'comment_id')
  String get commentId;
  @override
  @JsonKey(name: 'post_id')
  String get postId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get content;
  @override
  @JsonKey(name: 'author_nickname')
  String? get authorNickname;
  @override
  @JsonKey(name: 'author_profile_image')
  String? get authorProfileImage;
  @override
  @JsonKey(name: 'is_official')
  bool get isOfficial;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentModelImplCopyWith<_$CommentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LikeModel _$LikeModelFromJson(Map<String, dynamic> json) {
  return _LikeModel.fromJson(json);
}

/// @nodoc
mixin _$LikeModel {
  @JsonKey(name: 'like_id')
  String get likeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'post_id')
  String get postId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LikeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LikeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LikeModelCopyWith<LikeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LikeModelCopyWith<$Res> {
  factory $LikeModelCopyWith(LikeModel value, $Res Function(LikeModel) then) =
      _$LikeModelCopyWithImpl<$Res, LikeModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'like_id') String likeId,
    @JsonKey(name: 'post_id') String postId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$LikeModelCopyWithImpl<$Res, $Val extends LikeModel>
    implements $LikeModelCopyWith<$Res> {
  _$LikeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LikeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? likeId = null,
    Object? postId = null,
    Object? userId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            likeId: null == likeId
                ? _value.likeId
                : likeId // ignore: cast_nullable_to_non_nullable
                      as String,
            postId: null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LikeModelImplCopyWith<$Res>
    implements $LikeModelCopyWith<$Res> {
  factory _$$LikeModelImplCopyWith(
    _$LikeModelImpl value,
    $Res Function(_$LikeModelImpl) then,
  ) = __$$LikeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'like_id') String likeId,
    @JsonKey(name: 'post_id') String postId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$LikeModelImplCopyWithImpl<$Res>
    extends _$LikeModelCopyWithImpl<$Res, _$LikeModelImpl>
    implements _$$LikeModelImplCopyWith<$Res> {
  __$$LikeModelImplCopyWithImpl(
    _$LikeModelImpl _value,
    $Res Function(_$LikeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LikeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? likeId = null,
    Object? postId = null,
    Object? userId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$LikeModelImpl(
        likeId: null == likeId
            ? _value.likeId
            : likeId // ignore: cast_nullable_to_non_nullable
                  as String,
        postId: null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LikeModelImpl extends _LikeModel {
  const _$LikeModelImpl({
    @JsonKey(name: 'like_id') required this.likeId,
    @JsonKey(name: 'post_id') required this.postId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : super._();

  factory _$LikeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LikeModelImplFromJson(json);

  @override
  @JsonKey(name: 'like_id')
  final String likeId;
  @override
  @JsonKey(name: 'post_id')
  final String postId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'LikeModel(likeId: $likeId, postId: $postId, userId: $userId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikeModelImpl &&
            (identical(other.likeId, likeId) || other.likeId == likeId) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, likeId, postId, userId, createdAt);

  /// Create a copy of LikeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LikeModelImplCopyWith<_$LikeModelImpl> get copyWith =>
      __$$LikeModelImplCopyWithImpl<_$LikeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LikeModelImplToJson(this);
  }
}

abstract class _LikeModel extends LikeModel {
  const factory _LikeModel({
    @JsonKey(name: 'like_id') required final String likeId,
    @JsonKey(name: 'post_id') required final String postId,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$LikeModelImpl;
  const _LikeModel._() : super._();

  factory _LikeModel.fromJson(Map<String, dynamic> json) =
      _$LikeModelImpl.fromJson;

  @override
  @JsonKey(name: 'like_id')
  String get likeId;
  @override
  @JsonKey(name: 'post_id')
  String get postId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of LikeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LikeModelImplCopyWith<_$LikeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
