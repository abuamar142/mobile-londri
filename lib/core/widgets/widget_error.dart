import 'package:flutter/material.dart';

import '../../config/textstyle/app_colors.dart';
import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';
import '../../src/generated/i18n/app_localizations.dart';

class WidgetError extends StatelessWidget {
  final String? message;

  const WidgetError({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppSizes.size64,
            color: AppColors.error.withValues(
              alpha: 0.5,
            ),
          ),
          AppSizes.spaceHeight16,
          Text(
            AppLocalizations.of(context)!.error_occurred_message,
            style: AppTextStyle.body1,
            textAlign: TextAlign.center,
          ),
          AppSizes.spaceHeight8,
          if (message != null)
            Text(
              message!,
              style: AppTextStyle.body2,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
