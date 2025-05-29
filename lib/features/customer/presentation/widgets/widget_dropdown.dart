import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';

class WidgetDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnable;
  final void Function()? showModalBottomSheet;

  const WidgetDropdown({
    super.key,
    required this.icon,
    required this.label,
    this.isEnable = true,
    this.showModalBottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnable ? showModalBottomSheet : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.size12,
          horizontal: AppSizes.size16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.size4),
          border: Border.all(
            color: isEnable ? AppColors.onSecondary : AppColors.gray,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSizes.size24,
              color: isEnable ? AppColors.onSecondary : AppColors.gray,
            ),
            SizedBox(width: AppSizes.size12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.body1.copyWith(
                  color: isEnable ? AppColors.onSecondary : AppColors.gray,
                ),
              ),
            ),
            if (isEnable)
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.onSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
