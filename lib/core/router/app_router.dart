import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/auth_view_model.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/user_screen.dart';
import '../../presentation/screens/address_screen.dart';
import '../../presentation/screens/summary_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String users = '/users';
  static const String addresses = '/addresses';
  static const String summary = '/summary';

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: login,
      redirect: (context, state) {
        final isAuthenticated = authViewModel.isAuthenticated;
        final isGoingToLogin = state.matchedLocation == login;
        final isGoingToRegister = state.matchedLocation == register;

        // Si no está autenticado y no va a login/register, redirigir a login
        if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister) {
          return login;
        }

        // Si está autenticado y va a login, redirigir a home
        if (isAuthenticated && (isGoingToLogin || isGoingToRegister)) {
          return home;
        }

        return null; // No redirigir
      },
      routes: [
        // Auth routes
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),

        // App routes (requieren autenticación)
        ShellRoute(
          builder: (context, state, child) {
            return _HomeShell(child: child);
          },
          routes: [
            GoRoute(
              path: home,
              redirect: (context, state) => users,
            ),
            GoRoute(
              path: users,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: UserScreen(),
              ),
            ),
            GoRoute(
              path: addresses,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AddressScreen(),
              ),
            ),
            GoRoute(
              path: summary,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SummaryScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Shell para la navegación con tabs
class _HomeShell extends StatefulWidget {
  final Widget child;
  
  const _HomeShell({required this.child});

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0:
        context.go(AppRouter.users);
        break;
      case 1:
        context.go(AppRouter.addresses);
        break;
      case 2:
        context.go(AppRouter.summary);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sincronizar el índice con la ruta actual
    final location = GoRouterState.of(context).matchedLocation;
    if (location == AppRouter.users) {
      _selectedIndex = 0;
    } else if (location == AppRouter.addresses) {
      _selectedIndex = 1;
    } else if (location == AppRouter.summary) {
      _selectedIndex = 2;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Usuario',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Direcciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            selectedIcon: Icon(Icons.summarize),
            label: 'Resumen',
          ),
        ],
      ),
    );
  }
}
