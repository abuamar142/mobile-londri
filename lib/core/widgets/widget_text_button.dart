import 'package:flutter/material.dart';

import '../../config/textstyle/app_textstyle.dart';
import 'widget_loading.dart';

class WidgetTextButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final void Function() onPressed;

  const WidgetTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? WidgetLoading()
          : Text(
              label,
              style: AppTextstyle.body,
            ),
    );
  }
}
