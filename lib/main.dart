import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/mock_location_repository.dart';
import 'presentation/viewmodels/user_view_model.dart';
import 'presentation/viewmodels/address_view_model.dart';
import 'presentation/screens/user_screen.dart';
import 'presentation/screens/address_screen.dart';
import 'presentation/screens/summary_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => AddressViewModel(MockLocationRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Double V Partners - Prueba',
        theme: AppTheme.theme,
        home: const _HomeShell(),
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
