import 'package:flutter/material.dart';

import '../../config/textstyle/app_colors.dart';
import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';

class WidgetListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final Widget? trailing;
  final VoidCallback? onLongPress;
  final Color? tileColor;
  final VoidCallback? onTap;

  const WidgetListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    this.trailing,
    this.onLongPress,
    this.tileColor = AppColors.background,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.size8),
      ),
      tileColor: tileColor,
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppSizes.size8,
        horizontal: AppSizes.size16,
      ),
      leading: CircleAvatar(
        radius: AppSizes.size24,
        backgroundColor: AppColors.primary.withValues(
          alpha: 0.1,
        ),
        child: Icon(
          leadingIcon,
          color: AppColors.primary,
          size: AppSizes.size32,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyle.body1.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSizes.spaceHeight4,
          Text(
            subtitle,
            style: AppTextStyle.body2,
          ),
        ],
      ),
      trailing: trailing,
      onLongPress: onLongPress,
      onTap: onTap,
    );
  }
}
