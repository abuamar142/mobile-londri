import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int? id;
  final String? name;
  final String? phone;
  final String? description;
  final bool? isActive;

  const Customer({
    this.id,
    this.name,
    this.phone,
    this.description,
    this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        description,
        isActive,
      ];
}
