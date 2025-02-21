import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String? id;
  final String? name;
  final String? phone;
  final String? description;

  const Customer({
    this.id,
    this.name,
    this.phone,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        description,
      ];
}
