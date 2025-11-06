import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';
import '../screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;
  
  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    
    // Si el usuario está autenticado, muestra la app
    if (authVM.isAuthenticated) {
      return child;
    }
    
    // Si no está autenticado, muestra el login
    return const LoginScreen();
  }
}
