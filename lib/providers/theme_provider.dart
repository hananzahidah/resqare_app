import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _isDarkMode = PreferenceHandler.isDarkMode;
    AppColors.isDark = _isDarkMode;
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    AppColors.isDark = isDark;
    await PreferenceHandler.setDarkMode(isDark);
    notifyListeners();
  }
}
