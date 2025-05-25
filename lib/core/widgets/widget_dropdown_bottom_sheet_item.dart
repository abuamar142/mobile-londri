import 'package:flutter/material.dart';

import '../../config/textstyle/app_colors.dart';
import '../../config/textstyle/app_textstyle.dart';

class WidgetDropdownBottomSheetItem extends StatelessWidget {
  final bool isSelected;
  final IconData leadingIcon;
  final String title;
  final VoidCallback onTap;

  const WidgetDropdownBottomSheetItem({
    super.key,
    required this.isSelected,
    required this.leadingIcon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: isSelected ? AppColors.primary : AppColors.gray,
      ),
      title: Text(
        title,
        style: AppTextStyle.body1.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.onSecondary,
        ),
      ),
      onTap: onTap,
    );
  }
}
