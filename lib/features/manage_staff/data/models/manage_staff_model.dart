class ManageStaffModel {
  final int id;
  final String userId;
  final String role;

  const ManageStaffModel({
    required this.id,
    required this.userId,
    required this.role,
  });

  factory ManageStaffModel.fromJson(Map<String, dynamic> json) {
    return ManageStaffModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
