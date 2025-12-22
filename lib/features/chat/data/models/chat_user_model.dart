import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/chat_user_entity.dart';

part 'chat_user_model.freezed.dart';
part 'chat_user_model.g.dart';

/// 채팅 사용자 모델 (Firestore 직렬화용)
@freezed
class ChatUserModel with _$ChatUserModel {
  const factory ChatUserModel({
    required String userId,
    required String nickname,
    String? profileImageUrl,
    @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
    DateTime? lastOnlineAt,
  }) = _ChatUserModel;

  const ChatUserModel._();

  factory ChatUserModel.fromJson(Map<String, dynamic> json) =>
      _$ChatUserModelFromJson(json);

  factory ChatUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatUserModel.fromJson({
      'userId': doc.id,
      ...data,
    });
  }

  /// Entity로 변환
  ChatUserEntity toEntity() {
    return ChatUserEntity(
      userId: userId,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      lastOnlineAt: lastOnlineAt,
    );
  }

  /// Entity에서 생성
  factory ChatUserModel.fromEntity(ChatUserEntity entity) {
    return ChatUserModel(
      userId: entity.userId,
      nickname: entity.nickname,
      profileImageUrl: entity.profileImageUrl,
      lastOnlineAt: entity.lastOnlineAt,
    );
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

