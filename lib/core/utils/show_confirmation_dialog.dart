import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/loading_widget.dart';

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required bool isLoading,
  required VoidCallback onConfirm,
}) async {
  return await showDialog(
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
  );
}
