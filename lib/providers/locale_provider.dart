import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const _localeKey = 'app_locale';

  LocaleProvider(this._prefs);

  Locale get locale {
    final code = _prefs.getString(_localeKey);
    return Locale(code ?? 'en');
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }
}
