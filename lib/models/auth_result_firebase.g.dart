// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_result_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResultFirebase _$AuthResultFirebaseFromJson(Map<String, dynamic> json) =>
    AuthResultFirebase(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$AuthResultFirebaseToJson(AuthResultFirebase instance) =>
    <String, dynamic>{'success': instance.success, 'message': instance.message};
