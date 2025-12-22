// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) {
  return _ConversationModel.fromJson(json);
}

/// @nodoc
mixin _$ConversationModel {
  String get conversationId => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  LastMessageModel? get lastMessage => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;

  /// Serializes this ConversationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationModelCopyWith<ConversationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationModelCopyWith<$Res> {
  factory $ConversationModelCopyWith(
    ConversationModel value,
    $Res Function(ConversationModel) then,
  ) = _$ConversationModelCopyWithImpl<$Res, ConversationModel>;
  @useResult
  $Res call({
    String conversationId,
    List<String> participants,
    String type,
    LastMessageModel? lastMessage,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? lastMessageAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime updatedAt,
    String? name,
    String? imageUrl,
    String? createdBy,
  });

  $LastMessageModelCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$ConversationModelCopyWithImpl<$Res, $Val extends ConversationModel>
    implements $ConversationModelCopyWith<$Res> {
  _$ConversationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationModel
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
                      as String,
            lastMessage: freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as LastMessageModel?,
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

  /// Create a copy of ConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LastMessageModelCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $LastMessageModelCopyWith<$Res>(_value.lastMessage!, (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConversationModelImplCopyWith<$Res>
    implements $ConversationModelCopyWith<$Res> {
  factory _$$ConversationModelImplCopyWith(
    _$ConversationModelImpl value,
    $Res Function(_$ConversationModelImpl) then,
  ) = __$$ConversationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String conversationId,
    List<String> participants,
    String type,
    LastMessageModel? lastMessage,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? lastMessageAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime updatedAt,
    String? name,
    String? imageUrl,
    String? createdBy,
  });

  @override
  $LastMessageModelCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$ConversationModelImplCopyWithImpl<$Res>
    extends _$ConversationModelCopyWithImpl<$Res, _$ConversationModelImpl>
    implements _$$ConversationModelImplCopyWith<$Res> {
  __$$ConversationModelImplCopyWithImpl(
    _$ConversationModelImpl _value,
    $Res Function(_$ConversationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationModel
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
      _$ConversationModelImpl(
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
                  as String,
        lastMessage: freezed == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as LastMessageModel?,
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
@JsonSerializable()
class _$ConversationModelImpl extends _ConversationModel {
  const _$ConversationModelImpl({
    required this.conversationId,
    required final List<String> participants,
    required this.type,
    this.lastMessage,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    this.lastMessageAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required this.createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required this.updatedAt,
    this.name,
    this.imageUrl,
    this.createdBy,
  }) : _participants = participants,
       super._();

  factory _$ConversationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationModelImplFromJson(json);

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
  final String type;
  @override
  final LastMessageModel? lastMessage;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  final DateTime? lastMessageAt;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;
  @override
  final String? name;
  @override
  final String? imageUrl;
  @override
  final String? createdBy;

  @override
  String toString() {
    return 'ConversationModel(conversationId: $conversationId, participants: $participants, type: $type, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, createdAt: $createdAt, updatedAt: $updatedAt, name: $name, imageUrl: $imageUrl, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of ConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationModelImplCopyWith<_$ConversationModelImpl> get copyWith =>
      __$$ConversationModelImplCopyWithImpl<_$ConversationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationModelImplToJson(this);
  }
}

abstract class _ConversationModel extends ConversationModel {
  const factory _ConversationModel({
    required final String conversationId,
    required final List<String> participants,
    required final String type,
    final LastMessageModel? lastMessage,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    final DateTime? lastMessageAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required final DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required final DateTime updatedAt,
    final String? name,
    final String? imageUrl,
    final String? createdBy,
  }) = _$ConversationModelImpl;
  const _ConversationModel._() : super._();

  factory _ConversationModel.fromJson(Map<String, dynamic> json) =
      _$ConversationModelImpl.fromJson;

  @override
  String get conversationId;
  @override
  List<String> get participants;
  @override
  String get type;
  @override
  LastMessageModel? get lastMessage;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get lastMessageAt;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get updatedAt;
  @override
  String? get name;
  @override
  String? get imageUrl;
  @override
  String? get createdBy;

  /// Create a copy of ConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationModelImplCopyWith<_$ConversationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LastMessageModel _$LastMessageModelFromJson(Map<String, dynamic> json) {
  return _LastMessageModel.fromJson(json);
}

/// @nodoc
mixin _$LastMessageModel {
  String get content => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LastMessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LastMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LastMessageModelCopyWith<LastMessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LastMessageModelCopyWith<$Res> {
  factory $LastMessageModelCopyWith(
    LastMessageModel value,
    $Res Function(LastMessageModel) then,
  ) = _$LastMessageModelCopyWithImpl<$Res, LastMessageModel>;
  @useResult
  $Res call({
    String content,
    String senderId,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
  });
}

/// @nodoc
class _$LastMessageModelCopyWithImpl<$Res, $Val extends LastMessageModel>
    implements $LastMessageModelCopyWith<$Res> {
  _$LastMessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LastMessageModel
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
abstract class _$$LastMessageModelImplCopyWith<$Res>
    implements $LastMessageModelCopyWith<$Res> {
  factory _$$LastMessageModelImplCopyWith(
    _$LastMessageModelImpl value,
    $Res Function(_$LastMessageModelImpl) then,
  ) = __$$LastMessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String content,
    String senderId,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
  });
}

/// @nodoc
class __$$LastMessageModelImplCopyWithImpl<$Res>
    extends _$LastMessageModelCopyWithImpl<$Res, _$LastMessageModelImpl>
    implements _$$LastMessageModelImplCopyWith<$Res> {
  __$$LastMessageModelImplCopyWithImpl(
    _$LastMessageModelImpl _value,
    $Res Function(_$LastMessageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LastMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? senderId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$LastMessageModelImpl(
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
@JsonSerializable()
class _$LastMessageModelImpl extends _LastMessageModel {
  const _$LastMessageModelImpl({
    required this.content,
    required this.senderId,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required this.createdAt,
  }) : super._();

  factory _$LastMessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LastMessageModelImplFromJson(json);

  @override
  final String content;
  @override
  final String senderId;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  @override
  String toString() {
    return 'LastMessageModel(content: $content, senderId: $senderId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LastMessageModelImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, content, senderId, createdAt);

  /// Create a copy of LastMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LastMessageModelImplCopyWith<_$LastMessageModelImpl> get copyWith =>
      __$$LastMessageModelImplCopyWithImpl<_$LastMessageModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LastMessageModelImplToJson(this);
  }
}

abstract class _LastMessageModel extends LastMessageModel {
  const factory _LastMessageModel({
    required final String content,
    required final String senderId,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required final DateTime createdAt,
  }) = _$LastMessageModelImpl;
  const _LastMessageModel._() : super._();

  factory _LastMessageModel.fromJson(Map<String, dynamic> json) =
      _$LastMessageModelImpl.fromJson;

  @override
  String get content;
  @override
  String get senderId;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt;

  /// Create a copy of LastMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LastMessageModelImplCopyWith<_$LastMessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
