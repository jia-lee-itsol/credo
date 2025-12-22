import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings.freezed.dart';
part 'notification_settings.g.dart';

/// 알림 설정 모델
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    /// 전체 알림 ON/OFF
    @Default(true) bool enabled,

    /// 공지사항 알림
    @Default(true) bool notices,

    /// 댓글 알림
    @Default(true) bool comments,

    /// 좋아요 알림 (선택사항)
    @Default(false) bool likes,

    /// 일일 미사 독서 알림 (선택사항)
    @Default(false) bool dailyMass,

    /// 채팅 메시지 알림
    @Default(true) bool chatMessages,

    /// 조용한 시간 활성화 여부
    @Default(false) bool quietHoursEnabled,

    /// 조용한 시간 시작 (24시간 형식, 0-23)
    @Default(22) int quietHoursStart,

    /// 조용한 시간 종료 (24시간 형식, 0-23)
    @Default(7) int quietHoursEnd,

    /// 업데이트 시간
    @Default(null) DateTime? updatedAt,
  }) = _NotificationSettings;

  const NotificationSettings._();

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  /// Firestore Document에서 생성
  factory NotificationSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return const NotificationSettings();
    }

    return NotificationSettings(
      enabled: data['enabled'] as bool? ?? true,
      notices: data['notices'] as bool? ?? true,
      comments: data['comments'] as bool? ?? true,
      likes: data['likes'] as bool? ?? false,
      dailyMass: data['dailyMass'] as bool? ?? false,
      chatMessages: data['chatMessages'] as bool? ?? true,
      quietHoursEnabled: data['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: data['quietHoursStart'] as int? ?? 22,
      quietHoursEnd: data['quietHoursEnd'] as int? ?? 7,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'enabled': enabled,
      'notices': notices,
      'comments': comments,
      'likes': likes,
      'dailyMass': dailyMass,
      'chatMessages': chatMessages,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };

    if (updatedAt != null) {
      map['updatedAt'] = Timestamp.fromDate(updatedAt!);
    } else {
      map['updatedAt'] = FieldValue.serverTimestamp();
    }

    return map;
  }
}

