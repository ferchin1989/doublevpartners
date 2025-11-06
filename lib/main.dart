import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
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
import 'presentation/screens/user_screen.dart';
import 'presentation/screens/address_screen.dart';
import 'presentation/screens/summary_screen.dart';
import 'presentation/widgets/auth_wrapper.dart';
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Double V Partners - Prueba',
        theme: AppTheme.theme,
        home: const AuthWrapper(child: _HomeShell()),
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();
  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int index = 0;
  final pages = const [UserScreen(), AddressScreen(), SummaryScreen()];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carga lazy: solo una vez después de que el repositorio esté listo
    if (!_initialized) {
      _initialized = true;
      // Carga en background sin bloquear UI
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Usuario'),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), label: 'Direcciones'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Resumen'),
        ],
        onDestinationSelected: (i) => setState(() => index = i),
      ),
    );
  }
}
