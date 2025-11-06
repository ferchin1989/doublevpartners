import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/location.dart';
import '../viewmodels/address_view_model.dart';
import '../viewmodels/users_view_model.dart';
import '../widgets/futuristic_scaffold.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AddressViewModel>().loadCountries());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddressViewModel>();
    final activeUser = context.watch<UsersViewModel>().activeUser;
    
    return FuturisticScaffold(
      title: 'Direcciones',
      body: activeUser == null
          ? Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_off, size: 64, color: Colors.white70),
                      const SizedBox(height: 16),
                      Text(
                        'Debes crear primero un usuario',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ve a la pestaña Usuario para crear uno',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Usuario: ${activeUser.firstName} ${activeUser.lastName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<Country>(
                    value: vm.selectedCountry,
                    items: vm.countries
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.name, style: const TextStyle(color: Colors.white))))
                        .toList(),
                    onChanged: (c) => vm.onCountryChanged(c),
                    dropdownColor: const Color(0xFF1B2233),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'País'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Department>(
                    value: vm.selectedDepartment,
                    items: vm.departments
                        .map((d) => DropdownMenuItem(value: d, child: Text(d.name, style: const TextStyle(color: Colors.white))))
                        .toList(),
                    onChanged: (d) => vm.onDepartmentChanged(d),
                    dropdownColor: const Color(0xFF1B2233),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Departamento'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Municipality>(
                    value: vm.selectedMunicipality,
                    items: vm.municipalities
                        .map((m) => DropdownMenuItem(value: m, child: Text(m.name, style: const TextStyle(color: Colors.white))))
                        .toList(),
                    onChanged: (m) => vm.onMunicipalityChanged(m),
                    dropdownColor: const Color(0xFF1B2233),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Municipio'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Dirección física'),
                    onChanged: vm.onLine1Changed,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: vm.selectedCountry != null && vm.selectedDepartment != null && vm.selectedMunicipality != null && vm.line1.isNotEmpty
                          ? () => vm.addAddressForUser(activeUser.id!)
                          : null,
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Agregar dirección'),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: vm.addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final a = vm.addresses[index];
                return Card(
                  child: ListTile(
                    title: Text(a.line1),
                    subtitle: Text('${a.country.name} • ${a.department.name} • ${a.municipality.name}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => vm.removeAt(index),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
