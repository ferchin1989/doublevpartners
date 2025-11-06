import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/users_view_model.dart';
import '../widgets/futuristic_scaffold.dart';
import '../../core/router/app_router.dart';

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
      body: Column(
        children: [
          // Formulario de creación
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Card(
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
                            context.go(AppRouter.addresses);
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
          ),
          
          // Lista de usuarios creados
          const SizedBox(height: 16),
          if (usersVM.users.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Usuarios creados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: usersVM.users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = usersVM.users[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user.firstName[0].toUpperCase()),
                      ),
                      title: Text('${user.firstName} ${user.lastName}'),
                      subtitle: Text(
                        'Nacimiento: ${user.birthDate?.toLocal().toString().split(' ').first ?? '—'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        // Guardar el contexto antes del diálogo
                        final scaffoldContext = context;
                        
                        // Mostrar diálogo para agregar dirección
                        final shouldNavigate = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1B2233),
                            title: Text(
                              '${user.firstName} ${user.lastName}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              '¿Deseas agregar una dirección para este usuario?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton.icon(
                                onPressed: () => Navigator.pop(ctx, true),
                                icon: const Icon(Icons.add_location_alt),
                                label: const Text('Agregar dirección'),
                              ),
                            ],
                          ),
                        );
                        
                        if (shouldNavigate == true && mounted) {
                          // Establecer como usuario activo
                          usersVM.setActiveUser(user);
                          // Navegar a la pestaña de direcciones
                          scaffoldContext.go(AppRouter.addresses);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
