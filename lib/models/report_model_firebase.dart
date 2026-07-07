import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_model_firebase.g.dart';

@JsonSerializable()
class ReportModelFirebase {
  final String? id;
  final String createdBy;
  final String? rescuedBy;
  final String title;
  final String? description;
  final String reportCategory;
  final String animalCategory;
  final String priorityLevel;
  final String status;
  final double latitude;
  final double longitude;
  final String address;

  @JsonKey(fromJson: _boolFromJson, toJson: _boolToJson)
  final bool hasInjury;

  @JsonKey(fromJson: _boolFromJson, toJson: _boolToJson)
  final bool hasBleeding;

  @JsonKey(fromJson: _boolFromJson, toJson: _boolToJson)
  final bool cannotWalk;

  @JsonKey(fromJson: _boolFromJson, toJson: _boolToJson)
  final bool isTrapped;

  @JsonKey(fromJson: _boolFromJson, toJson: _boolToJson)
  final bool isSick;

  @JsonKey(fromJson: _boolFromJson, toJson: _boolToJson)
  final bool isAbandoned;

  final String? assignedAt;
  final String? onRescueAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? cancelledBy;
  final String createdAt;
  final String? updatedAt;

  ReportModelFirebase({
    this.id,
    required this.createdBy,
    this.rescuedBy,
    required this.title,
    this.description,
    required this.reportCategory,
    required this.animalCategory,
    required this.priorityLevel,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.hasInjury,
    required this.hasBleeding,
    required this.cannotWalk,
    required this.isTrapped,
    required this.isSick,
    required this.isAbandoned,
    this.assignedAt,
    this.onRescueAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledBy,
    required this.createdAt,
    this.updatedAt,
  });

  static bool _boolFromJson(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;
    return false;
  }

  static dynamic _boolToJson(bool value) => value;

  ReportModelFirebase copyWith({
    String? id,
    String? createdBy,
    String? rescuedBy,
    String? title,
    String? description,
    String? reportCategory,
    String? animalCategory,
    String? priorityLevel,
    String? status,
    double? latitude,
    double? longitude,
    String? address,
    bool? hasInjury,
    bool? hasBleeding,
    bool? cannotWalk,
    bool? isTrapped,
    bool? isSick,
    bool? isAbandoned,
    String? assignedAt,
    String? onRescueAt,
    String? completedAt,
    String? cancelledAt,
    String? cancelledBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return ReportModelFirebase(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      rescuedBy: rescuedBy ?? this.rescuedBy,
      title: title ?? this.title,
      description: description ?? this.description,
      reportCategory: reportCategory ?? this.reportCategory,
      animalCategory: animalCategory ?? this.animalCategory,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      hasInjury: hasInjury ?? this.hasInjury,
      hasBleeding: hasBleeding ?? this.hasBleeding,
      cannotWalk: cannotWalk ?? this.cannotWalk,
      isTrapped: isTrapped ?? this.isTrapped,
      isSick: isSick ?? this.isSick,
      isAbandoned: isAbandoned ?? this.isAbandoned,
      assignedAt: assignedAt ?? this.assignedAt,
      onRescueAt: onRescueAt ?? this.onRescueAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  factory ReportModelFirebase.fromMap(Map<String, dynamic> map) => ReportModelFirebase.fromJson(map);

  factory ReportModelFirebase.fromJson(Map<String, dynamic> json) => _$ReportModelFirebaseFromJson(json);

  Map<String, dynamic> toJson() => _$ReportModelFirebaseToJson(this);

  factory ReportModelFirebase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReportModelFirebase.fromJson({
      ...data,
      'id': doc.id,
    });
  }
}
