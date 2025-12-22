// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return _MessageModel.fromJson(json);
}

/// @nodoc
mixin _$MessageModel {
  String get messageId => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _readByFromJson, toJson: _readByToJson)
  Map<String, DateTime> get readBy => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String? get deletedBy => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
  MessageType get type => throw _privateConstructorUsedError;

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageModelCopyWith<MessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageModelCopyWith<$Res> {
  factory $MessageModelCopyWith(
    MessageModel value,
    $Res Function(MessageModel) then,
  ) = _$MessageModelCopyWithImpl<$Res, MessageModel>;
  @useResult
  $Res call({
    String messageId,
    String conversationId,
    String senderId,
    String content,
    List<String> imageUrls,
    @JsonKey(fromJson: _readByFromJson, toJson: _readByToJson)
    Map<String, DateTime> readBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? updatedAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? deletedAt,
    String? deletedBy,
    @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
    MessageType type,
  });
}

/// @nodoc
class _$MessageModelCopyWithImpl<$Res, $Val extends MessageModel>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? conversationId = null,
    Object? senderId = null,
    Object? content = null,
    Object? imageUrls = null,
    Object? readBy = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? deletedBy = freezed,
    Object? type = null,
  }) {
    return _then(
      _value.copyWith(
            messageId: null == messageId
                ? _value.messageId
                : messageId // ignore: cast_nullable_to_non_nullable
                      as String,
            conversationId: null == conversationId
                ? _value.conversationId
                : conversationId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrls: null == imageUrls
                ? _value.imageUrls
                : imageUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            readBy: null == readBy
                ? _value.readBy
                : readBy // ignore: cast_nullable_to_non_nullable
                      as Map<String, DateTime>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deletedBy: freezed == deletedBy
                ? _value.deletedBy
                : deletedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MessageType,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageModelImplCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$$MessageModelImplCopyWith(
    _$MessageModelImpl value,
    $Res Function(_$MessageModelImpl) then,
  ) = __$$MessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String messageId,
    String conversationId,
    String senderId,
    String content,
    List<String> imageUrls,
    @JsonKey(fromJson: _readByFromJson, toJson: _readByToJson)
    Map<String, DateTime> readBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? updatedAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? deletedAt,
    String? deletedBy,
    @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
    MessageType type,
  });
}

/// @nodoc
class __$$MessageModelImplCopyWithImpl<$Res>
    extends _$MessageModelCopyWithImpl<$Res, _$MessageModelImpl>
    implements _$$MessageModelImplCopyWith<$Res> {
  __$$MessageModelImplCopyWithImpl(
    _$MessageModelImpl _value,
    $Res Function(_$MessageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? conversationId = null,
    Object? senderId = null,
    Object? content = null,
    Object? imageUrls = null,
    Object? readBy = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? deletedBy = freezed,
    Object? type = null,
  }) {
    return _then(
      _$MessageModelImpl(
        messageId: null == messageId
            ? _value.messageId
            : messageId // ignore: cast_nullable_to_non_nullable
                  as String,
        conversationId: null == conversationId
            ? _value.conversationId
            : conversationId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrls: null == imageUrls
            ? _value._imageUrls
            : imageUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        readBy: null == readBy
            ? _value._readBy
            : readBy // ignore: cast_nullable_to_non_nullable
                  as Map<String, DateTime>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deletedBy: freezed == deletedBy
            ? _value.deletedBy
            : deletedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MessageType,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageModelImpl extends _MessageModel {
  const _$MessageModelImpl({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.content,
    final List<String> imageUrls = const [],
    @JsonKey(fromJson: _readByFromJson, toJson: _readByToJson)
    final Map<String, DateTime> readBy = const {},
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required this.createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    this.updatedAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    this.deletedAt,
    this.deletedBy,
    @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
    this.type = MessageType.text,
  }) : _imageUrls = imageUrls,
       _readBy = readBy,
       super._();

  factory _$MessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageModelImplFromJson(json);

  @override
  final String messageId;
  @override
  final String conversationId;
  @override
  final String senderId;
  @override
  final String content;
  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  final Map<String, DateTime> _readBy;
  @override
  @JsonKey(fromJson: _readByFromJson, toJson: _readByToJson)
  Map<String, DateTime> get readBy {
    if (_readBy is EqualUnmodifiableMapView) return _readBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_readBy);
  }

  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  final DateTime? updatedAt;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  final DateTime? deletedAt;
  @override
  final String? deletedBy;
  @override
  @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
  final MessageType type;

  @override
  String toString() {
    return 'MessageModel(messageId: $messageId, conversationId: $conversationId, senderId: $senderId, content: $content, imageUrls: $imageUrls, readBy: $readBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, deletedBy: $deletedBy, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageModelImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(
              other._imageUrls,
              _imageUrls,
            ) &&
            const DeepCollectionEquality().equals(other._readBy, _readBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.deletedBy, deletedBy) ||
                other.deletedBy == deletedBy) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    messageId,
    conversationId,
    senderId,
    content,
    const DeepCollectionEquality().hash(_imageUrls),
    const DeepCollectionEquality().hash(_readBy),
    createdAt,
    updatedAt,
    deletedAt,
    deletedBy,
    type,
  );

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      __$$MessageModelImplCopyWithImpl<_$MessageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageModelImplToJson(this);
  }
}

abstract class _MessageModel extends MessageModel {
  const factory _MessageModel({
    required final String messageId,
    required final String conversationId,
    required final String senderId,
    required final String content,
    final List<String> imageUrls,
    @JsonKey(fromJson: _readByFromJson, toJson: _readByToJson)
    final Map<String, DateTime> readBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required final DateTime createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    final DateTime? updatedAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    final DateTime? deletedAt,
    final String? deletedBy,
    @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
    final MessageType type,
  }) = _$MessageModelImpl;
  const _MessageModel._() : super._();

  factory _MessageModel.fromJson(Map<String, dynamic> json) =
      _$MessageModelImpl.fromJson;

  @override
  String get messageId;
  @override
  String get conversationId;
  @override
  String get senderId;
  @override
  String get content;
  @override
  List<String> get imageUrls;
  @override
  @JsonKey(fromJson: _readByFromJson, toJson: _readByToJson)
  Map<String, DateTime> get readBy;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get updatedAt;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get deletedAt;
  @override
  String? get deletedBy;
  @override
  @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
  MessageType get type;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
