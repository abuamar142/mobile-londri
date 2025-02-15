import 'package:flutter/material.dart';

import 'app_bar.dart';

class AppThemes {
  AppThemes._();

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.blue,
    appBarTheme: darkAppBarTheme(),
  );

  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.blue.shade50,
    primaryColor: Colors.blue,
    appBarTheme: lightAppBarTheme(),
  );
}
