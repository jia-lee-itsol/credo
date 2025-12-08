import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/parish_entity.dart';

part 'parish_model.freezed.dart';
part 'parish_model.g.dart';

/// 교회 데이터 모델
@freezed
class ParishModel with _$ParishModel {
  const factory ParishModel({
    @JsonKey(name: 'parish_id') required String parishId,
    required String name,
    required String prefecture,
    required String address,
    String? phone,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'official_site') String? officialSite,
    @JsonKey(name: 'has_official_account') @Default(false) bool hasOfficialAccount,
    @JsonKey(name: 'nearest_station') String? nearestStation,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'mass_times') @Default([]) List<MassTimeModel> massTimes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ParishModel;

  const ParishModel._();

  factory ParishModel.fromJson(Map<String, dynamic> json) =>
      _$ParishModelFromJson(json);

  /// Firestore Document에서 생성
  factory ParishModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // mass_times 처리
    List<Map<String, dynamic>> massTimesData = [];
    if (data['mass_times'] != null) {
      massTimesData = List<Map<String, dynamic>>.from(data['mass_times']);
    }

    return ParishModel.fromJson({
      'parish_id': doc.id,
      ...data,
      'mass_times': massTimesData,
      'created_at': (data['created_at'] as Timestamp?)?.toDate().toIso8601String(),
      'updated_at': (data['updated_at'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  /// Entity로 변환
  ParishEntity toEntity() {
    return ParishEntity(
      parishId: parishId,
      name: name,
      prefecture: prefecture,
      address: address,
      phone: phone,
      latitude: latitude,
      longitude: longitude,
      officialSite: officialSite,
      hasOfficialAccount: hasOfficialAccount,
      nearestStation: nearestStation,
      imageUrl: imageUrl,
      massTimes: massTimes.map((mt) => mt.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'prefecture': prefecture,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'official_site': officialSite,
      'has_official_account': hasOfficialAccount,
      'nearest_station': nearestStation,
      'image_url': imageUrl,
      'mass_times': massTimes.map((mt) => mt.toJson()).toList(),
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updated_at': Timestamp.fromDate(DateTime.now()),
    };
  }
}

/// 미사 시간 데이터 모델
@freezed
class MassTimeModel with _$MassTimeModel {
  const factory MassTimeModel({
    @JsonKey(name: 'mass_id') required String massId,
    @JsonKey(name: 'parish_id') required String parishId,
    required int weekday,
    required String time,
    required String language,
    String? note,
  }) = _MassTimeModel;

  const MassTimeModel._();

  factory MassTimeModel.fromJson(Map<String, dynamic> json) =>
      _$MassTimeModelFromJson(json);

  /// Entity로 변환
  MassTimeEntity toEntity() {
    return MassTimeEntity(
      massId: massId,
      parishId: parishId,
      weekday: weekday,
      time: time,
      language: language,
      note: note,
    );
  }

  /// Entity에서 생성
  factory MassTimeModel.fromEntity(MassTimeEntity entity) {
    return MassTimeModel(
      massId: entity.massId,
      parishId: entity.parishId,
      weekday: entity.weekday,
      time: entity.time,
      language: entity.language,
      note: entity.note,
    );
  }
}
