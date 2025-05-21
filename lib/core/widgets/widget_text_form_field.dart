import 'package:flutter/material.dart';

import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';

class WidgetTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isEnabled;
  final bool isLoading;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconButton? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int maxLines;

  const WidgetTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isEnabled = true,
    this.isLoading = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: isEnabled && !isLoading,
      keyboardType: keyboardType,
      style: AppTextStyle.textField,
      validator: validator,
      onChanged: onChanged,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyle.body1,
        hintStyle: AppTextStyle.body1,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          vertical: AppSizes.size20,
          horizontal: AppSizes.size16,
        ),
        border: OutlineInputBorder(),
      ),
    );
  }
}
