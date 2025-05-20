import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocales {
  final SharedPreferences sharedPreferences;

  AppLocales({
    required this.sharedPreferences,
  });

  static final ValueNotifier<Locale> _localeNotifier = ValueNotifier<Locale>(
    Locale('id'),
  );

  void loadLocale() {
    final String? locale = sharedPreferences.getString('locale');

    if (locale != null) {
      _localeNotifier.value = Locale(locale);
    }
  }

  void setLocale(Locale locale) {
    _localeNotifier.value = locale;
    sharedPreferences.setString('locale', locale.languageCode);
  }

  static ValueNotifier<Locale> get localeNotifier => _localeNotifier;
}
