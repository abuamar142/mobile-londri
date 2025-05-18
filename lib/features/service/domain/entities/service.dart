import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String? id;
  final String? name;
  final String? description;
  final int? price;

  const Service({
    this.id,
    this.name,
    this.description,
    this.price,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
      ];
}
