import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../src/generated/i18n/app_localizations.dart';
import '../../config/textstyle/app_textstyle.dart';

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
  required AppLocalizations appText,
}) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTextstyle.title,
          ),
        ),
        content: Text(
          content,
          style: AppTextstyle.body,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: Text(
                  appText.button_cancel,
                  style: AppTextstyle.body,
                ),
                onPressed: () {
                  context.pop();
                },
              ),
              TextButton(
                onPressed: onConfirm,
                child: const Text(
                  'Confirm',
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
