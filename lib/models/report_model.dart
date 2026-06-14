import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ReportModel {
  final int? id;

  final int createdBy;
  final int? rescuedBy;

  final String title;
  final String? description;

  final String reportCategory;
  final String animalCategory;

  final String priorityLevel;
  final String status;

  final double latitude;
  final double longitude;
  final String address;

  final bool hasInjury;
  final bool hasBleeding;
  final bool cannotWalk;
  final bool isTrapped;
  final bool isSick;
  final bool isAbandoned;

  final String? assignedAt;
  final String? onRescueAt;
  final String? completedAt;
  final String? cancelledAt;
  final int? cancelledBy;

  final String createdAt;
  final String? updatedAt;
  ReportModel({
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'createdBy': createdBy,
      'rescuedBy': rescuedBy,
      'title': title,
      'description': description,
      'reportCategory': reportCategory,
      'animalCategory': animalCategory,
      'priorityLevel': priorityLevel,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'hasInjury': hasInjury,
      'hasBleeding': hasBleeding,
      'cannotWalk': cannotWalk,
      'isTrapped': isTrapped,
      'isSick': isSick,
      'isAbandoned': isAbandoned,
      'assignedAt': assignedAt,
      'onRescueAt': onRescueAt,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'cancelledBy': cancelledBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] != null ? map['id'] as int : null,
      createdBy: map['createdBy'] as int,
      rescuedBy: map['rescuedBy'] != null ? map['rescuedBy'] as int : null,
      title: map['title'] as String,
      description: map['description'] != null
          ? map['description'] as String
          : null,
      reportCategory: map['reportCategory'] as String? ?? 'Rescue',
      animalCategory: map['animalCategory'] as String,
      priorityLevel: map['priorityLevel'] as String,
      status: map['status'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String,
      hasInjury: map['hasInjury'] == 1 || map['hasInjury'] == true,
      hasBleeding: map['hasBleeding'] == 1 || map['hasBleeding'] == true,
      cannotWalk: map['cannotWalk'] == 1 || map['cannotWalk'] == true,
      isTrapped: map['isTrapped'] == 1 || map['isTrapped'] == true,
      isSick: map['isSick'] == 1 || map['isSick'] == true,
      isAbandoned: map['isAbandoned'] == 1 || map['isAbandoned'] == true,
      assignedAt: map['assignedAt'] != null
          ? map['assignedAt'] as String
          : null,
      onRescueAt: map['onRescueAt'] != null
          ? map['onRescueAt'] as String
          : null,
      completedAt: map['completedAt'] != null
          ? map['completedAt'] as String
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? map['cancelledAt'] as String
          : null,
      cancelledBy: map['cancelledBy'] != null ? map['cancelledBy'] as int : null,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] != null ? map['updatedAt'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReportModel.fromJson(String source) =>
      ReportModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
