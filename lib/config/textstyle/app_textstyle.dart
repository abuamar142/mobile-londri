import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextstyle {
  AppTextstyle._();

  static final TextStyle _baseTextStyle = GoogleFonts.gabarito();

  static final TextStyle title = _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle subtitle = _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle body = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle label = _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle textField = _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle tileTitle = _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle tileSubtitle = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle tileSubtitleSmall = _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle tileTrailing = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}
