import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_sizes.dart';

class WidgetBottomBar extends StatelessWidget {
  final List<Widget> content;

  const WidgetBottomBar({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSizes.size16,
          right: AppSizes.size16,
          bottom: AppSizes.size8,
          top: AppSizes.size8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [...content],
        ),
      ),
    );
  }
}
