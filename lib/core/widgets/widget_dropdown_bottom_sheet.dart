import 'package:flutter/material.dart';

import '../../config/textstyle/app_colors.dart';
import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';
import 'widget_dropdown_bottom_sheet_item.dart';

void showDropdownBottomSheet({
  required BuildContext context,
  required String title,
  required List<WidgetDropdownBottomSheetItem> items,
  bool? isAscending,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.size16),
      ),
    ),
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: AppSizes.size16,
            left: AppSizes.size16,
            right: AppSizes.size16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyle.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isAscending != null)
                Icon(
                  isAscending == true ? Icons.arrow_upward : Icons.arrow_downward,
                  color: AppColors.primary,
                )
            ],
          ),
        ),
        const Divider(thickness: 1),
        ...items,
      ],
    ),
  );
}
