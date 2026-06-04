import '../api/api_service.dart';
import '../models/user.dart';
import '../preferences/auth_preferences.dart';

class AuthRepository {
  final ApiService apiService;
  final AuthPreferences preferences;

  AuthRepository({required this.apiService, required this.preferences});

  bool get isLoggedIn => preferences.isLoggedIn;

  String? get token => preferences.token;

  String? get userName => preferences.userName;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await apiService.register(name: name, email: email, password: password);
  }

  Future<User> login({required String email, required String password}) async {
    final user = await apiService.login(email: email, password: password);
    await preferences.saveSession(token: user.token, name: user.name);
    return user;
  }

  Future<void> logout() async {
    await preferences.clearSession();
  }
}
