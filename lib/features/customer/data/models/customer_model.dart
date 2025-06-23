import '../../domain/entities/customer.dart';
import '../../domain/entities/gender.dart';

class CustomerModel extends Customer {
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const CustomerModel({
    super.id,
    super.name,
    super.phone,
    super.gender,
    super.description,
    super.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) : super(
          isActive: deletedAt == null,
        );

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      name: json['name'],
      phone: json['phone'],
      gender: json['gender'] != null ? Gender.fromString(json['gender']) : Gender.other,
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'gender': gender?.name,
      'description': description,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}
