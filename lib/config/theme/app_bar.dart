
import 'package:flutter/material.dart';

AppBarTheme darkAppBarTheme() {
  return const AppBarTheme(
    color: Colors.blue,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18,
    ),
  );
}

AppBarTheme lightAppBarTheme() {
  return const AppBarTheme(
    color: Colors.blue,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18,
    ),
  );
}
