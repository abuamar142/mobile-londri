import 'package:flutter/material.dart';

import '../../config/textstyle/app_colors.dart';
import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';
import '../../src/generated/i18n/app_localizations.dart';

class WidgetEmptyList extends StatelessWidget {
  final String emptyMessage;
  final VoidCallback? onRefresh;

  const WidgetEmptyList({
    super.key,
    required this.emptyMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: AppSizes.size64,
              color: AppColors.primary,
            ),
            AppSizes.spaceHeight12,
            Text(
              emptyMessage,
              style: AppTextStyle.body1,
              textAlign: TextAlign.center,
            ),
            AppSizes.spaceHeight16,
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(
                AppLocalizations.of(context)!.button_refresh,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.size8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
