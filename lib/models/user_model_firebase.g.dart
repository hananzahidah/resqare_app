// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModelFirebase _$UserModelFirebaseFromJson(Map<String, dynamic> json) =>
    UserModelFirebase(
      id: json['id'] as String?,
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      isVerified: UserModelFirebase._isVerifiedFromJson(json['isVerified']),
      imgProfile: json['imgProfile'] as String?,
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UserModelFirebaseToJson(UserModelFirebase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'password': instance.password,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'role': instance.role,
      'isVerified': UserModelFirebase._isVerifiedToJson(instance.isVerified),
      'imgProfile': instance.imgProfile,
      'currentLatitude': instance.currentLatitude,
      'currentLongitude': instance.currentLongitude,
    };
