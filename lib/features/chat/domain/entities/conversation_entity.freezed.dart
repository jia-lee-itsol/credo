// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConversationEntity {
  String get conversationId => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  ConversationType get type => throw _privateConstructorUsedError;
  LastMessageInfo? get lastMessage => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError; // 그룹 채팅용
  String? get name => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationEntityCopyWith<ConversationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationEntityCopyWith<$Res> {
  factory $ConversationEntityCopyWith(
    ConversationEntity value,
    $Res Function(ConversationEntity) then,
  ) = _$ConversationEntityCopyWithImpl<$Res, ConversationEntity>;
  @useResult
  $Res call({
    String conversationId,
    List<String> participants,
    ConversationType type,
    LastMessageInfo? lastMessage,
    DateTime? lastMessageAt,
    DateTime createdAt,
    DateTime updatedAt,
    String? name,
    String? imageUrl,
    String? createdBy,
  });

  $LastMessageInfoCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$ConversationEntityCopyWithImpl<$Res, $Val extends ConversationEntity>
    implements $ConversationEntityCopyWith<$Res> {
  _$ConversationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = null,
    Object? participants = null,
    Object? type = null,
    Object? lastMessage = freezed,
    Object? lastMessageAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? name = freezed,
    Object? imageUrl = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            conversationId: null == conversationId
                ? _value.conversationId
                : conversationId // ignore: cast_nullable_to_non_nullable
                      as String,
            participants: null == participants
                ? _value.participants
                : participants // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ConversationType,
            lastMessage: freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as LastMessageInfo?,
            lastMessageAt: freezed == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdBy: freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LastMessageInfoCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $LastMessageInfoCopyWith<$Res>(_value.lastMessage!, (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConversationEntityImplCopyWith<$Res>
    implements $ConversationEntityCopyWith<$Res> {
  factory _$$ConversationEntityImplCopyWith(
    _$ConversationEntityImpl value,
    $Res Function(_$ConversationEntityImpl) then,
  ) = __$$ConversationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String conversationId,
    List<String> participants,
    ConversationType type,
    LastMessageInfo? lastMessage,
    DateTime? lastMessageAt,
    DateTime createdAt,
    DateTime updatedAt,
    String? name,
    String? imageUrl,
    String? createdBy,
  });

  @override
  $LastMessageInfoCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$ConversationEntityImplCopyWithImpl<$Res>
    extends _$ConversationEntityCopyWithImpl<$Res, _$ConversationEntityImpl>
    implements _$$ConversationEntityImplCopyWith<$Res> {
  __$$ConversationEntityImplCopyWithImpl(
    _$ConversationEntityImpl _value,
    $Res Function(_$ConversationEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = null,
    Object? participants = null,
    Object? type = null,
    Object? lastMessage = freezed,
    Object? lastMessageAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? name = freezed,
    Object? imageUrl = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(
      _$ConversationEntityImpl(
        conversationId: null == conversationId
            ? _value.conversationId
            : conversationId // ignore: cast_nullable_to_non_nullable
                  as String,
        participants: null == participants
            ? _value._participants
            : participants // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ConversationType,
        lastMessage: freezed == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as LastMessageInfo?,
        lastMessageAt: freezed == lastMessageAt
            ? _value.lastMessageAt
            : lastMessageAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdBy: freezed == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ConversationEntityImpl implements _ConversationEntity {
  const _$ConversationEntityImpl({
    required this.conversationId,
    required final List<String> participants,
    required this.type,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.imageUrl,
    this.createdBy,
  }) : _participants = participants;

  @override
  final String conversationId;
  final List<String> _participants;
  @override
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  final ConversationType type;
  @override
  final LastMessageInfo? lastMessage;
  @override
  final DateTime? lastMessageAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  // 그룹 채팅용
  @override
  final String? name;
  @override
  final String? imageUrl;
  @override
  final String? createdBy;

  @override
  String toString() {
    return 'ConversationEntity(conversationId: $conversationId, participants: $participants, type: $type, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, createdAt: $createdAt, updatedAt: $updatedAt, name: $name, imageUrl: $imageUrl, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationEntityImpl &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    conversationId,
    const DeepCollectionEquality().hash(_participants),
    type,
    lastMessage,
    lastMessageAt,
    createdAt,
    updatedAt,
    name,
    imageUrl,
    createdBy,
  );

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationEntityImplCopyWith<_$ConversationEntityImpl> get copyWith =>
      __$$ConversationEntityImplCopyWithImpl<_$ConversationEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _ConversationEntity implements ConversationEntity {
  const factory _ConversationEntity({
    required final String conversationId,
    required final List<String> participants,
    required final ConversationType type,
    final LastMessageInfo? lastMessage,
    final DateTime? lastMessageAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? name,
    final String? imageUrl,
    final String? createdBy,
  }) = _$ConversationEntityImpl;

  @override
  String get conversationId;
  @override
  List<String> get participants;
  @override
  ConversationType get type;
  @override
  LastMessageInfo? get lastMessage;
  @override
  DateTime? get lastMessageAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt; // 그룹 채팅용
  @override
  String? get name;
  @override
  String? get imageUrl;
  @override
  String? get createdBy;

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationEntityImplCopyWith<_$ConversationEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LastMessageInfo {
  String get content => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of LastMessageInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LastMessageInfoCopyWith<LastMessageInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LastMessageInfoCopyWith<$Res> {
  factory $LastMessageInfoCopyWith(
    LastMessageInfo value,
    $Res Function(LastMessageInfo) then,
  ) = _$LastMessageInfoCopyWithImpl<$Res, LastMessageInfo>;
  @useResult
  $Res call({String content, String senderId, DateTime createdAt});
}

/// @nodoc
class _$LastMessageInfoCopyWithImpl<$Res, $Val extends LastMessageInfo>
    implements $LastMessageInfoCopyWith<$Res> {
  _$LastMessageInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LastMessageInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? senderId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$LastMessageInfoImplCopyWith<$Res>
    implements $LastMessageInfoCopyWith<$Res> {
  factory _$$LastMessageInfoImplCopyWith(
    _$LastMessageInfoImpl value,
    $Res Function(_$LastMessageInfoImpl) then,
  ) = __$$LastMessageInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String content, String senderId, DateTime createdAt});
}

/// @nodoc
class __$$LastMessageInfoImplCopyWithImpl<$Res>
    extends _$LastMessageInfoCopyWithImpl<$Res, _$LastMessageInfoImpl>
    implements _$$LastMessageInfoImplCopyWith<$Res> {
  __$$LastMessageInfoImplCopyWithImpl(
    _$LastMessageInfoImpl _value,
    $Res Function(_$LastMessageInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LastMessageInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? senderId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$LastMessageInfoImpl(
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
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

class _$LastMessageInfoImpl implements _LastMessageInfo {
  const _$LastMessageInfoImpl({
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  @override
  final String content;
  @override
  final String senderId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LastMessageInfo(content: $content, senderId: $senderId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LastMessageInfoImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content, senderId, createdAt);

  /// Create a copy of LastMessageInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LastMessageInfoImplCopyWith<_$LastMessageInfoImpl> get copyWith =>
      __$$LastMessageInfoImplCopyWithImpl<_$LastMessageInfoImpl>(
        this,
        _$identity,
      );
}

abstract class _LastMessageInfo implements LastMessageInfo {
  const factory _LastMessageInfo({
    required final String content,
    required final String senderId,
    required final DateTime createdAt,
  }) = _$LastMessageInfoImpl;

  @override
  String get content;
  @override
  String get senderId;
  @override
  DateTime get createdAt;

  /// Create a copy of LastMessageInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LastMessageInfoImplCopyWith<_$LastMessageInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
