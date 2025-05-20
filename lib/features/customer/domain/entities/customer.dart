import 'package:equatable/equatable.dart';

enum Gender { male, female, other }

String getGenderText(Gender gender) {
  switch (gender) {
    case Gender.male:
      return 'Male';
    case Gender.female:
      return 'Female';
    default:
      return 'Other';
  }
}

class Customer extends Equatable {
  final int? id;
  final String? name;
  final String? phone;
  final Gender? gender;
  final String? description;
  final bool? isActive;

  const Customer({
    this.id,
    this.name,
    this.phone,
    this.gender = Gender.other,
    this.description,
    this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        gender,
        description,
        isActive,
      ];
}
