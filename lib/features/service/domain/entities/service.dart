import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final int? id;
  final String? name;
  final String? description;
  final int? price;
  final DateTime? createdAt;
  final bool? isActive;

  const Service({
    this.id,
    this.name,
    this.description,
    this.price,
    this.createdAt,
    this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        createdAt,
        isActive,
      ];
}
