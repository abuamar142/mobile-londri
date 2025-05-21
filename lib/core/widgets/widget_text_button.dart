import 'package:flutter/material.dart';

import '../../config/textstyle/app_colors.dart';
import '../../config/textstyle/app_textstyle.dart';

class WidgetTextButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final void Function() onPressed;
  final Color? color;

  const WidgetTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: Text(
        label,
        style: AppTextStyle.body.copyWith(
          color: color ?? AppColors.onPrimary,
        ),
      ),
    );
  }
}
