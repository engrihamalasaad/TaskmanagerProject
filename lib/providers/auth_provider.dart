import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository});

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String username, String password) async {
    try {
      await authRepository.login(username, password);
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      throw e;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> checkAuthentication() async {
    _isAuthenticated = await authRepository.isLoggedIn();
    notifyListeners();
  }
}
