import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/friend_entity.dart';

part 'friend_model.freezed.dart';
part 'friend_model.g.dart';

/// 친구 관계 모델 (Firestore 직렬화용)
@freezed
class FriendModel with _$FriendModel {
  const factory FriendModel({
    required String odId,
    required String userId,
    required String friendId,
    required String status,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
    DateTime? updatedAt,
    String? nickname,
  }) = _FriendModel;

  const FriendModel._();

  factory FriendModel.fromJson(Map<String, dynamic> json) =>
      _$FriendModelFromJson(json);

  factory FriendModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendModel.fromJson({
      'odId': doc.id,
      ...data,
    });
  }

  /// Entity로 변환
  FriendEntity toEntity() {
    return FriendEntity(
      odId: odId,
      userId: userId,
      friendId: friendId,
      status: _statusFromString(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
      nickname: nickname,
    );
  }

  /// Entity에서 생성
  factory FriendModel.fromEntity(FriendEntity entity) {
    return FriendModel(
      odId: entity.odId,
      userId: entity.userId,
      friendId: entity.friendId,
      status: _statusToString(entity.status),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nickname: entity.nickname,
    );
  }
}

// FriendStatus 변환
FriendStatus _statusFromString(String status) {
  switch (status) {
    case 'pending':
      return FriendStatus.pending;
    case 'accepted':
      return FriendStatus.accepted;
    case 'blocked':
      return FriendStatus.blocked;
    default:
      return FriendStatus.none;
  }
}

String _statusToString(FriendStatus status) {
  switch (status) {
    case FriendStatus.pending:
      return 'pending';
    case FriendStatus.accepted:
      return 'accepted';
    case FriendStatus.blocked:
      return 'blocked';
    case FriendStatus.none:
      return 'none';
  }
}

// Timestamp 변환 헬퍼 (nullable)
DateTime? _timestampFromJsonNullable(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return null;
}

dynamic _timestampToJsonNullable(DateTime? dateTime) {
  if (dateTime == null) return null;
  return Timestamp.fromDate(dateTime);
}

// Timestamp 변환 헬퍼 (non-nullable)
DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

dynamic _timestampToJson(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}

