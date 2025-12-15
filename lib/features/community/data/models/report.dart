import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';
part 'report.g.dart';

/// 신고 모델 (Firestore /reports/{reportId} 컬렉션)
@freezed
class Report with _$Report {
  const factory Report({
    required String reportId,
    @JsonKey(name: 'targetType')
    required String targetType, // "post" | "comment" | "user"
    @JsonKey(name: 'targetId') required String targetId,
    @JsonKey(name: 'reason') required String reason,
    @JsonKey(name: 'reporterId') required String reporterId,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
  }) = _Report;

  const Report._();

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  /// Firestore Document에서 생성
  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final json = <String, dynamic>{
      'reportId': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
    return Report.fromJson(json);
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('reportId'); // reportId는 문서 ID이므로 제거
    json['createdAt'] = Timestamp.fromDate(createdAt);
    return json;
  }
}
