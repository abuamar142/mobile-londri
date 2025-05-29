import 'package:equatable/equatable.dart';

import 'gender.dart';

class Customer extends Equatable {
  final int? id;
  final String? name;
  final String? phone;
  final Gender? gender;
  final String? description;
  final bool? isActive;
  final DateTime? createdAt;

  const Customer({
    this.id,
    this.name,
    this.phone,
    this.gender = Gender.other,
    this.description,
    this.isActive,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        gender,
        description,
        isActive,
        createdAt,
      ];
}
