import 'package:flutter/material.dart';

import '../../../../core/utils/context_extensions.dart';

enum Gender {
  male(value: 'Male', icon: Icons.man),
  female(value: 'Female', icon: Icons.woman),
  other(value: 'Other', icon: Icons.person);

  final String value;
  final IconData icon;

  const Gender({
    required this.value,
    required this.icon,
  });

  factory Gender.fromString(String value) {
    return Gender.values.firstWhere(
      (gender) => gender.value == value,
      orElse: () => Gender.other,
    );
  }
}

String getGenderValue(BuildContext context, Gender gender) {
  switch (gender) {
    case Gender.male:
      return context.appText.gender_male;
    case Gender.female:
      return context.appText.gender_female;
    default:
      return context.appText.gender_other;
  }
}
