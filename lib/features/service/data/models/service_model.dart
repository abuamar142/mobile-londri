import '../../domain/entities/service.dart';

class ServiceModel extends Service {
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const ServiceModel({
    super.id,
    super.name,
    super.description,
    super.price,
    super.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) : super(
          isActive: deletedAt == null,
        );

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
