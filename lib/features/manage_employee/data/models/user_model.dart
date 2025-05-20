import '../../domain/entities/user.dart';

class UserModel extends User {
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role_id']['role'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
