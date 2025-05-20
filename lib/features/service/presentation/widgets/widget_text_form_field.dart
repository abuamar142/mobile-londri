import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_textstyle.dart';

class WidgetTextFormField extends StatelessWidget {
  final String label;
  final String? Function(String?)? validator;
  final TextInputType textInputType;
  final bool enabled;
  final TextEditingController controller;
  final int maxLines;

  const WidgetTextFormField({
    super.key,
    required this.label,
    this.validator,
    this.textInputType = TextInputType.text,
    this.enabled = true,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyle.label,
        ),
        style: AppTextStyle.textField,
        enabled: enabled,
        controller: controller,
        keyboardType: textInputType,
        validator: validator ?? (value) => null,
        minLines: 1,
        maxLines: maxLines,
      ),
    );
  }
}
