// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String?,
      apellido: json['apellido'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      authToken: json['authToken'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'apellido': instance.apellido,
      'username': instance.username,
      'password': instance.password,
      'email': instance.email,
      'authToken': instance.authToken,
    };

LoginData _$LoginDataFromJson(Map<String, dynamic> json) => LoginData(
      username: json['username'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$LoginDataToJson(LoginData instance) => <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

PasswordResetData _$PasswordResetDataFromJson(Map<String, dynamic> json) =>
    PasswordResetData(
      oldPassword: json['oldPassword'] as String?,
      newPassword: json['newPassword'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
    );

Map<String, dynamic> _$PasswordResetDataToJson(PasswordResetData instance) =>
    <String, dynamic>{
      'oldPassword': instance.oldPassword,
      'newPassword': instance.newPassword,
      'confirmPassword': instance.confirmPassword,
    };
