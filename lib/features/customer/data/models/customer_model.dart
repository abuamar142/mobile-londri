import '../../domain/entities/customer.dart';

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
      gender: json['gender'] != null
          ? Gender.values.firstWhere(
              (e) => e.name == json['gender'],
              orElse: () => Gender.other,
            )
          : Gender.other,
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'gender': gender?.name ?? 'other',
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
