class UserRoleModel {
  final int id;
  final String userId;
  final String role;

  const UserRoleModel({
    required this.id,
    required this.userId,
    required this.role,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
