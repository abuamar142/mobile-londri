import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required super.id,
    required super.email,
    required super.name,
    super.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
