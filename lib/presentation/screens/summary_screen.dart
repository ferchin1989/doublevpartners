import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import '../viewmodels/address_view_model.dart';
import '../widgets/futuristic_scaffold.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserViewModel>().user;
    final addresses = context.watch<AddressViewModel>().addresses;

    return FuturisticScaffold(
      title: 'Resumen',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              title: Text('${user.firstName} ${user.lastName}'),
              subtitle: Text('Nacimiento: ${user.birthDate?.toLocal().toString().split(' ').first ?? '—'}'),
            ),
          ),
          const SizedBox(height: 16),
          Text('Direcciones', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...addresses.map((a) => Card(
                child: ListTile(
                  title: Text(a.line1),
                  subtitle: Text('${a.country.name} • ${a.department.name} • ${a.municipality.name}'),
                ),
              )),
          if (addresses.isEmpty) const Text('Sin direcciones aún')
        ],
      ),
    );
  }
}
