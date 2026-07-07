import 'package:json_annotation/json_annotation.dart';

part 'login_model_firebase.g.dart';

@JsonSerializable()
class LoginModelFirebase {
  final String email;
  final String password;

  LoginModelFirebase({
    required this.email,
    required this.password,
  });

  factory LoginModelFirebase.fromJson(Map<String, dynamic> json) => _$LoginModelFirebaseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginModelFirebaseToJson(this);
}
