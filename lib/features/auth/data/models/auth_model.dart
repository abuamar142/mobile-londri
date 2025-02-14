import '../../domain/entities/auth.dart';

class AuthModel extends Auth {
  const AuthModel({
    required super.accessToken,
    required super.id,
    required super.email,
    required super.name,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['accessToken'],
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }
}
