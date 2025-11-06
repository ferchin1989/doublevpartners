import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  
  AuthViewModel(this._authService);

  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // Inicializar listener de auth
  void initAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Registro
  Future<void> signUp(String email, String password) async {
    try {
      final credential = await _authService.signUpWithEmail(email, password);
      _user = credential.user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<void> signIn(String email, String password) async {
    try {
      final credential = await _authService.signInWithEmail(email, password);
      _user = credential.user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
}
