import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  final SharedPreferences _prefs;

  AuthPreferences(this._prefs);

  static const _tokenKey = 'auth_token';
  static const _sessionKey = 'is_logged_in';
  static const _nameKey = 'user_name';

  Future<void> saveSession({
    required String token,
    required String name,
  }) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_nameKey, name);
    await _prefs.setBool(_sessionKey, true);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_nameKey);
    await _prefs.setBool(_sessionKey, false);
  }

  bool get isLoggedIn => _prefs.getBool(_sessionKey) ?? false;

  String? get token => _prefs.getString(_tokenKey);

  String? get userName => _prefs.getString(_nameKey);
}
