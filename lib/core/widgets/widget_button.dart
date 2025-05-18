import 'package:flutter/material.dart';

import '../../config/textstyle/app_colors.dart';
import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';
import 'widget_loading.dart';

class WidgetButton extends StatelessWidget {
  final String label;
  final void Function() onPressed;
  final bool isLoading;

  const WidgetButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isLoading ? AppColors.gray : AppColors.primary,
        ),
        minimumSize: WidgetStateProperty.all(
          const Size(double.infinity, AppSizes.size56),
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? WidgetLoading()
          : Text(
              label,
              style: AppTextStyle.button.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
    );
  }
}
