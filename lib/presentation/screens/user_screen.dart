import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/users_view_model.dart';
import '../widgets/futuristic_scaffold.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  DateTime? _birthDate;

  bool get _canCreate => _firstName.trim().isNotEmpty && _lastName.trim().isNotEmpty && _birthDate != null;

  @override
  Widget build(BuildContext context) {
    final usersVM = context.watch<UsersViewModel?>();
    
    // Si el ViewModel no está listo (usuario no autenticado), mostrar loading
    if (usersVM == null) {
      return FuturisticScaffold(
        title: 'Usuario',
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
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
                      style: const TextStyle(color: Colors.white),
                      initialValue: _firstName,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      onChanged: (v) {
                        setState(() => _firstName = v);
                      },
                      validator: (v) => (v==null || v.trim().isEmpty) ? 'El nombre es requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      initialValue: _lastName,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      onChanged: (v) {
                        setState(() => _lastName = v);
                      },
                      validator: (v) => (v==null || v.trim().isEmpty) ? 'El apellido es requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.cake_outlined),
                            label: Text(_birthDate == null
                                ? 'Fecha de nacimiento'
                                : _birthDate!.toLocal().toString().split(' ').first),
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(now.year, now.month, now.day),
                                initialDate: _birthDate ?? DateTime(2000,1,1),
                                helpText: 'Selecciona tu fecha de nacimiento',
                              );
                              if (picked != null && !picked.isAfter(DateTime.now())) {
                                setState(() => _birthDate = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _canCreate ? () async {
                        if (_formKey.currentState!.validate()) {
                          await usersVM.createUser(_firstName.trim(), _lastName.trim(), _birthDate);
                          if (mounted) {
                            // Limpiar formulario
                            setState(() {
                              _firstName = '';
                              _lastName = '';
                              _birthDate = null;
                            });
                            _formKey.currentState!.reset();
                            
                            // Navegar a la pestaña de direcciones
                            DefaultTabController.of(context).animateTo(1);
                          }
                        }
                      } : null,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Crear usuario'),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
