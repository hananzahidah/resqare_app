import 'dart:convert';

class UserModelSql {
  final int? id;
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final String role;
  final int isVerified;
  final String? imgProfile;
  final double? currentLatitude;
  final double? currentLongitude;

  UserModelSql({
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'isVerified': isVerified,
      'imgProfile': imgProfile,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
    };
  }

  factory UserModelSql.fromMap(Map<String, dynamic> map) {
    return UserModelSql(
      id: map['id'] != null ? map['id'] as int : null,
      email: map['email'] as String,
      password: map['password'] as String,
      fullName: map['fullName'] as String,
      phone: map['phone'] != null ? map['phone'] as String : null,
      role: map['role'] as String,
      isVerified: map['isVerified'] as int,
      imgProfile: map['imgProfile'] != null ? map['imgProfile'] as String : null,
      currentLatitude: map['currentLatitude'] != null
          ? (map['currentLatitude'] as num).toDouble()
          : null,
      currentLongitude: map['currentLongitude'] != null
          ? (map['currentLongitude'] as num).toDouble()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModelSql.fromJson(String source) =>
      UserModelSql.fromMap(json.decode(source) as Map<String, dynamic>);
}
