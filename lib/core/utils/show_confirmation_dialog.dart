import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../config/textstyle/app_textstyle.dart';
import '../widgets/loading_widget.dart';

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required bool isLoading,
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
                  appText.buttonCancel,
                  style: AppTextstyle.body,
                ),
                onPressed: () {
                  context.pop();
                },
              ),
              TextButton(
                onPressed: onConfirm,
                child: isLoading
                    ? const LoadingWidget()
                    : const Text(
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
