import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model_firebase.g.dart';

@JsonSerializable()
class UserModelFirebase {
  final String? id;
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final String role;
  
  @JsonKey(fromJson: _isVerifiedFromJson, toJson: _isVerifiedToJson)
  final int isVerified;
  
  final String? imgProfile;
  final double? currentLatitude;
  final double? currentLongitude;

  UserModelFirebase({
    this.id,
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    required this.role,
    required this.isVerified,
    this.imgProfile,
    this.currentLatitude,
    this.currentLongitude,
  });

  // Custom parser to handle isVerified boolean or number formats in JSON/Firestore
  static int _isVerifiedFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static dynamic _isVerifiedToJson(int value) => value;

  // Getter to check if user is verified as a boolean
  bool get isUserVerified => isVerified == 1;

  // CopyWith method for easy modification of immutable instances
  UserModelFirebase copyWith({
    String? id,
    String? email,
    String? password,
    String? fullName,
    String? phone,
    String? role,
    int? isVerified,
    String? imgProfile,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return UserModelFirebase(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      imgProfile: imgProfile ?? this.imgProfile,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  factory UserModelFirebase.fromMap(Map<String, dynamic> map) => UserModelFirebase.fromJson(map);

  factory UserModelFirebase.fromJson(Map<String, dynamic> json) => _$UserModelFirebaseFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelFirebaseToJson(this);

  // Helper factory to instantiate from a Firestore DocumentSnapshot
  factory UserModelFirebase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModelFirebase.fromJson({
      'password': '',
      ...data,
      'id': doc.id,
    });
  }
}
