// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationSettingsImpl(
  enabled: json['enabled'] as bool? ?? true,
  notices: json['notices'] as bool? ?? true,
  comments: json['comments'] as bool? ?? true,
  likes: json['likes'] as bool? ?? false,
  dailyMass: json['dailyMass'] as bool? ?? false,
  quietHoursStart: (json['quietHoursStart'] as num?)?.toInt() ?? 22,
  quietHoursEnd: (json['quietHoursEnd'] as num?)?.toInt() ?? 7,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$NotificationSettingsImplToJson(
  _$NotificationSettingsImpl instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'notices': instance.notices,
  'comments': instance.comments,
  'likes': instance.likes,
  'dailyMass': instance.dailyMass,
  'quietHoursStart': instance.quietHoursStart,
  'quietHoursEnd': instance.quietHoursEnd,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
