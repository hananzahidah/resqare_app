import 'dart:convert';

class LoginModel {
  final String email;
  final String password;
  LoginModel({required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'email': email, 'password': password};
  }

  factory LoginModel.fromMap(Map<String, dynamic> map) {
    return LoginModel(
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginModel.fromJson(String source) =>
      LoginModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

// class LoginModel {
//   final String id;
//   final String email;
//   final String password;
//   LoginModel({required this.id, required this.email, required this.password});

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{'id': id, 'email': email, 'password': password};
//   }

//   factory LoginModel.fromMap(Map<String, dynamic> map) {
//     return LoginModel(
//       id: map['id'] as String,
//       email: map['email'] as String,
//       password: map['password'] as String,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory LoginModel.fromJson(String source) =>
//       LoginModel.fromMap(json.decode(source) as Map<String, dynamic>);
// }
