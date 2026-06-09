import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final bool error;
  final String message;
  final User? loginResult;

  LoginResponse({required this.error, required this.message, this.loginResult});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
