import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_user_entity.freezed.dart';

/// 채팅 사용자 정보 엔티티
@freezed
class ChatUserEntity with _$ChatUserEntity {
  const factory ChatUserEntity({
    required String userId,
    required String nickname,
    String? profileImageUrl,
    DateTime? lastOnlineAt,
  }) = _ChatUserEntity;
}

