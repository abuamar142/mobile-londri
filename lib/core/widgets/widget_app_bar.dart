import 'package:flutter/material.dart';

import '../../config/textstyle/app_textstyle.dart';

class WidgetAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final IconButton? action;

  const WidgetAppBar({
    super.key,
    required this.label,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        label,
        style: AppTextStyle.heading3,
      ),
      centerTitle: true,
      actions: [
        if (action != null) action!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
