import 'package:flutter/material.dart';

import '../../config/textstyle/app_colors.dart';
import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';

class WidgetTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isLoading;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconButton? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const WidgetTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isLoading = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: !isLoading,
      keyboardType: keyboardType,
      style: AppTextStyle.textField,
      validator: validator,
      onChanged: onChanged,
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
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.onSecondary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
