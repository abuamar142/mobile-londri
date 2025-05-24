import 'package:flutter/material.dart';

import '../../config/textstyle/app_textstyle.dart';
import '../../src/generated/i18n/app_localizations.dart';

extension ContextExtensions on BuildContext {
  // Get localization text
  AppLocalizations get appText => AppLocalizations.of(this)!;

  // Show snackbar
  void showSnackbar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          message,
          style: AppTextStyle.body,
        ),
      ),
    );
  }
}
