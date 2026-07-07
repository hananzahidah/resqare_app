import 'package:json_annotation/json_annotation.dart';

part 'auth_result_firebase.g.dart';

@JsonSerializable()
class AuthResultFirebase {
  final bool success;
  final String message;

  AuthResultFirebase({
    required this.success,
    required this.message,
  });

  factory AuthResultFirebase.fromJson(Map<String, dynamic> json) => _$AuthResultFirebaseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResultFirebaseToJson(this);
}
