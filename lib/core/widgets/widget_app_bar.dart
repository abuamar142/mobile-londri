import 'package:flutter/material.dart';

import '../../config/textstyle/app_textstyle.dart';

class WidgetAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconButton? action;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const WidgetAppBar({
    super.key,
    required this.title,
    this.action,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: AppTextStyle.heading3.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        if (action != null) action!,
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => bottom != null
      ? Size.fromHeight(
          kToolbarHeight + bottom!.preferredSize.height,
        )
      : Size.fromHeight(kToolbarHeight);
}
