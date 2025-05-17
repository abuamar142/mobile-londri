import 'package:flutter/material.dart';

class AppSizes {
  AppSizes._();

  static const double size12 = 12;
  static const double size16 = 16;
  static const double size20 = 20;
  static const double size24 = 24;
  static const double size56 = 56;

  static const SizedBox spaceHeight12 = SizedBox(height: size12);
  static const SizedBox spaceHeight16 = SizedBox(height: size16);
  static const SizedBox spaceHeight24 = SizedBox(height: size24);

  static const EdgeInsetsGeometry paddingAll16 = EdgeInsets.all(size16);
}
