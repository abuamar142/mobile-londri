import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../src/generated/i18n/app_localizations.dart';
import '../../config/textstyle/app_colors.dart';
import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        actionsPadding: EdgeInsets.only(
          bottom: AppSizes.size16,
        ),
        contentPadding: EdgeInsets.only(
          top: AppSizes.size16,
          left: AppSizes.size16,
          right: AppSizes.size16,
          bottom: AppSizes.size12,
        ),
        title: Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTextStyle.heading2.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Text(
          content,
          style: AppTextStyle.body2,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.button_cancel,
                  style: AppTextStyle.body2.copyWith(
                    color: AppColors.error,
                  ),
                ),
                onPressed: () {
                  context.pop();
                },
              ),
              TextButton(
                onPressed: onConfirm,
                child: Text(
                  AppLocalizations.of(context)!.button_confirm,
                  style: AppTextStyle.body2.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
