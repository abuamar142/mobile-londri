import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';
import 'widget_dropdown_bottom_sheet_item.dart';

void showDropdownBottomSheet({
  required BuildContext context,
  required List<WidgetDropdownBottomSheetItem> items,
  required String title,
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
            children: [
              Text(
                title,
                style: AppTextStyle.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1),
        ...items,
        SizedBox(height: AppSizes.size16),
      ],
    ),
  );
}
