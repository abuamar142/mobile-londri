import 'package:flutter/material.dart';

import '../../config/textstyle/app_colors.dart';
import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';

class WidgetDetailCardItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Widget? trailing;

  const WidgetDetailCardItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: AppSizes.size16,
      leading: Container(
        padding: EdgeInsets.all(AppSizes.size8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: AppSizes.size20,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.caption.copyWith(color: AppColors.gray),
          ),
          Text(
            value,
            style: AppTextStyle.body1.copyWith(color: AppColors.onSecondary),
          ),
        ],
      ),
      trailing: trailing,
    );
  }
}
