import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_textstyle.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String? Function(String?)? validator;
  final TextInputType textInputType;
  final bool enabled;
  final TextEditingController controller;

  const CustomTextFormField({
    super.key,
    required this.label,
    this.validator,
    this.textInputType = TextInputType.text,
    this.enabled = true,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextstyle.label,
      ),
      enabled: enabled,
      controller: controller,
      keyboardType: textInputType,
      validator: validator ?? (value) => null,
    );
  }
}
