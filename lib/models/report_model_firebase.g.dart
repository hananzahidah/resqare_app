// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModelFirebase _$ReportModelFirebaseFromJson(Map<String, dynamic> json) =>
    ReportModelFirebase(
      id: json['id'] as String?,
      createdBy: json['createdBy'] as String,
      rescuedBy: json['rescuedBy'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      reportCategory: json['reportCategory'] as String,
      animalCategory: json['animalCategory'] as String,
      priorityLevel: json['priorityLevel'] as String,
      status: json['status'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      hasInjury: ReportModelFirebase._boolFromJson(json['hasInjury']),
      hasBleeding: ReportModelFirebase._boolFromJson(json['hasBleeding']),
      cannotWalk: ReportModelFirebase._boolFromJson(json['cannotWalk']),
      isTrapped: ReportModelFirebase._boolFromJson(json['isTrapped']),
      isSick: ReportModelFirebase._boolFromJson(json['isSick']),
      isAbandoned: ReportModelFirebase._boolFromJson(json['isAbandoned']),
      assignedAt: json['assignedAt'] as String?,
      onRescueAt: json['onRescueAt'] as String?,
      completedAt: json['completedAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$ReportModelFirebaseToJson(
  ReportModelFirebase instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdBy': instance.createdBy,
  'rescuedBy': instance.rescuedBy,
  'title': instance.title,
  'description': instance.description,
  'reportCategory': instance.reportCategory,
  'animalCategory': instance.animalCategory,
  'priorityLevel': instance.priorityLevel,
  'status': instance.status,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'address': instance.address,
  'hasInjury': ReportModelFirebase._boolToJson(instance.hasInjury),
  'hasBleeding': ReportModelFirebase._boolToJson(instance.hasBleeding),
  'cannotWalk': ReportModelFirebase._boolToJson(instance.cannotWalk),
  'isTrapped': ReportModelFirebase._boolToJson(instance.isTrapped),
  'isSick': ReportModelFirebase._boolToJson(instance.isSick),
  'isAbandoned': ReportModelFirebase._boolToJson(instance.isAbandoned),
  'assignedAt': instance.assignedAt,
  'onRescueAt': instance.onRescueAt,
  'completedAt': instance.completedAt,
  'cancelledAt': instance.cancelledAt,
  'cancelledBy': instance.cancelledBy,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
