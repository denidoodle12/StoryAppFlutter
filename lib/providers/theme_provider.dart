import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const _themeKey = 'is_dark_mode';

  ThemeProvider(this._prefs);

  bool get isDarkMode => _prefs.getBool(_themeKey) ?? false;

  Future<void> toggleTheme() async {
    await _prefs.setBool(_themeKey, !isDarkMode);
    notifyListeners();
  }
}
