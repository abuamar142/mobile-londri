import 'package:uuid/uuid.dart';

import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  final DateTime? createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const CustomerModel({
    required super.id,
    super.name,
    super.phone,
    super.description,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) : super(
          isActive: deletedAt == null,
        );

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
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
      'id': id ?? Uuid().v4(),
      'name': name,
      'phone': phone,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson(CustomerModel customer) {
    Map<String, dynamic> data = customer.toJson();

    data.removeWhere((key, value) => value == null);

    return data;
  }
}
