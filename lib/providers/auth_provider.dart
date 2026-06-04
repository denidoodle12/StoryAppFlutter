import 'package:flutter/material.dart';

import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider({required this.repository});

  bool get isLoggedIn => repository.isLoggedIn;
  String? get token => repository.token;
  String? get userName => repository.userName;

  bool _isLoadingLogin = false;
  bool get isLoadingLogin => _isLoadingLogin;

  bool _isLoadingRegister = false;
  bool get isLoadingRegister => _isLoadingRegister;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login({required String email, required String password}) async {
    _isLoadingLogin = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.login(email: email, password: password);
      _isLoadingLogin = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingLogin = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoadingRegister = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.register(name: name, email: email, password: password);
      _isLoadingRegister = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingRegister = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    notifyListeners();
  }
}
