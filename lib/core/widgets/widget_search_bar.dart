import 'package:flutter/material.dart';

import '../../config/textstyle/app_sizes.dart';
import '../../config/textstyle/app_textstyle.dart';
import '../../src/generated/i18n/app_localizations.dart';

class WidgetSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String) onChanged;
  final Function onClear;

  const WidgetSearchBar({
    super.key,
    required this.controller,
    this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        style: AppTextStyle.body,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  tooltip: AppLocalizations.of(context)!.button_clear,
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();

                    onClear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.size8),
          ),
          hintStyle: AppTextStyle.body.copyWith(color: Colors.grey),
        ),
        onChanged: (value) => onChanged(value),
      ),
    );
  }
}
