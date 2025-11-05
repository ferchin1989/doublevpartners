import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import '../widgets/futuristic_scaffold.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();
    return FuturisticScaffold(
      title: 'Usuario',
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: vm.user.firstName,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      onChanged: vm.updateFirstName,
                      validator: (v) => (v==null || v.trim().isEmpty) ? 'El nombre es requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: vm.user.lastName,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      onChanged: vm.updateLastName,
                      validator: (v) => (v==null || v.trim().isEmpty) ? 'El apellido es requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.cake_outlined),
                            label: Text(vm.user.birthDate == null
                                ? 'Fecha de nacimiento'
                                : vm.user.birthDate!.toLocal().toString().split(' ').first),
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(now.year, now.month, now.day),
                                initialDate: vm.user.birthDate ?? DateTime(2000,1,1),
                                helpText: 'Selecciona tu fecha de nacimiento',
                              );
                              if (picked != null && picked.isAfter(DateTime.now())) return;
                              vm.updateBirthDate(picked);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        vm.user.birthDate == null ? 'Selecciona tu fecha de nacimiento' : '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Preview: ${vm.user.firstName} ${vm.user.lastName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
