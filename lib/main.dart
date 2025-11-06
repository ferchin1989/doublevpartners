import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/repositories/mock_location_repository.dart';
import 'data/repositories/local_storage_repository.dart';
import 'data/repositories/hybrid_storage_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/firestore_service.dart';
import 'data/services/connectivity_service.dart';
import 'domain/repositories/local_storage_repository.dart' as domain;
import 'presentation/viewmodels/address_view_model.dart';
import 'presentation/viewmodels/users_view_model.dart';
import 'presentation/viewmodels/auth_view_model.dart';
import 'presentation/viewmodels/connectivity_view_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<ConnectivityService>(create: (_) => ConnectivityService()),
        Provider<SqfliteLocalStorageRepository>(
          create: (_) => SqfliteLocalStorageRepository(),
        ),
        Provider<MockLocationRepository>(
          create: (_) => MockLocationRepository(),
        ),
        
        // ViewModels (notifican cambios)
        ChangeNotifierProvider(
          create: (ctx) => AuthViewModel(ctx.read<AuthService>())
            ..initAuthListener(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (ctx) => ConnectivityViewModel(ctx.read<ConnectivityService>()),
          lazy: false,
        ),
        // Repositorio híbrido (Firebase + SQLite caché)
        // Se crea después de que el usuario esté autenticado
        ProxyProvider<AuthViewModel, domain.LocalStorageRepository?>(
          update: (ctx, authVM, _) {
            if (authVM.user == null) return null;
            return HybridStorageRepository(
              firestore: ctx.read<FirestoreService>(),
              localCache: ctx.read<SqfliteLocalStorageRepository>(),
              connectivity: ctx.read<ConnectivityService>(),
              userId: authVM.user!.uid,
            );
          },
        ),
        ChangeNotifierProxyProvider<domain.LocalStorageRepository?, UsersViewModel?>(
          create: (_) => null,
          update: (ctx, repo, previous) {
            if (repo == null) return null;
            return previous ?? UsersViewModel(repo);
          },
        ),
        ChangeNotifierProxyProvider<domain.LocalStorageRepository?, AddressViewModel?>(
          create: (_) => null,
          update: (ctx, repo, previous) {
            if (repo == null) return null;
            return previous ?? AddressViewModel(
              ctx.read<MockLocationRepository>(),
              repo,
            );
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final authVM = context.watch<AuthViewModel>();
          final router = AppRouter.createRouter(authVM);
          
          // Cargar datos iniciales cuando el usuario se autentica
          if (authVM.isAuthenticated) {
            Future.microtask(() {
              final usersVM = context.read<UsersViewModel?>();
              final addressVM = context.read<AddressViewModel?>();
              
              if (usersVM != null) {
                usersVM.loadUsers();
              }
              if (addressVM != null) {
                addressVM.loadCountries();
              }
            });
          }
          
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Double V Partners - Prueba',
            theme: AppTheme.theme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

