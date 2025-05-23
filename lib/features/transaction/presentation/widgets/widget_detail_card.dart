import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';

class WidgetDetailCard extends StatelessWidget {
  final String title;
  final List<Widget> content;
  const WidgetDetailCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      surfaceTintColor: AppColors.primary,
      color: AppColors.onPrimary,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.size12),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSizes.size16,
          right: AppSizes.size16,
          top: AppSizes.size16,
          bottom: AppSizes.size8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...content,
          ],
        ),
      ),
    );
  }
}
