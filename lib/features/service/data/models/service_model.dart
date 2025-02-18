import 'package:uuid/uuid.dart';

import '../../domain/entities/service.dart';

class ServiceModel extends Service {
  final DateTime? createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const ServiceModel({
    super.id,
    super.name,
    super.description,
    super.price,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
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
      'description': description,
      'price': price,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson(ServiceModel service) {
    Map<String, dynamic> data = service.toJson();

    data.removeWhere((key, value) => value == null);

    return data;
  }
}
