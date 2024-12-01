import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String? nombre;
  final String? apellido;
  final String? username;
  final String? password;
  final String? email;
  final String? authToken;

  User({
    required this.id,
    this.nombre,
    this.apellido,
    this.username,
    this.password,
    this.email,
    this.authToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// lib/models/login_data.dart
@JsonSerializable()
class LoginData {
  final String? username;
  final String? password;

  LoginData({this.username, this.password});

  factory LoginData.fromJson(Map<String, dynamic> json) => _$LoginDataFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}

// lib/models/password_reset_data.dart
@JsonSerializable()
class PasswordResetData {
  final String? oldPassword;
  final String? newPassword;
  final String? confirmPassword;

  PasswordResetData({
    this.oldPassword,
    this.newPassword,
    this.confirmPassword,
  });

  factory PasswordResetData.fromJson(Map<String, dynamic> json) => _$PasswordResetDataFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordResetDataToJson(this);
}