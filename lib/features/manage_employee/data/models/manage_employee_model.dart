class ManageEmployeeModel {
  final int id;
  final String userId;
  final String role;

  const ManageEmployeeModel({
    required this.id,
    required this.userId,
    required this.role,
  });

  factory ManageEmployeeModel.fromJson(Map<String, dynamic> json) {
    return ManageEmployeeModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
