import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/textstyle/app_textstyle.dart';
import '../widgets/loading_widget.dart';

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(
        message,
        style: AppTextstyle.body,
      ),
    ),
  );
}

Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required bool isLoading,
  required VoidCallback onConfirm,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
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
          );
        },
      ) ??
      false;
}
