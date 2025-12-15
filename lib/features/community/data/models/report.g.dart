// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportImpl _$$ReportImplFromJson(Map<String, dynamic> json) => _$ReportImpl(
  reportId: json['reportId'] as String,
  targetType: json['targetType'] as String,
  targetId: json['targetId'] as String,
  reason: json['reason'] as String,
  reporterId: json['reporterId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ReportImplToJson(_$ReportImpl instance) =>
    <String, dynamic>{
      'reportId': instance.reportId,
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'reason': instance.reason,
      'reporterId': instance.reporterId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
