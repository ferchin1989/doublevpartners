import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/users_view_model.dart';
import '../viewmodels/auth_view_model.dart';
import '../widgets/futuristic_scaffold.dart';
import '../../domain/repositories/local_storage_repository.dart' as domain;
import '../../domain/entities/user.dart' as domain;
import '../../domain/entities/address.dart' as domain;

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usersVM = context.watch<UsersViewModel>();
    final storage = context.read<domain.LocalStorageRepository>();

    return FuturisticScaffold(
      title: 'Resumen',
      actions: [
        IconButton(
          tooltip: 'Cerrar sesión',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1B2233),
                title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                content: const Text('¿Deseas cerrar sesión?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cerrar sesión')),
                ],
              ),
            );
            if (confirm == true) {
              await context.read<AuthViewModel>().signOut();
            }
          },
        ),
        IconButton(
          tooltip: 'Borrar base de datos',
          icon: const Icon(Icons.delete_forever_outlined),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1B2233),
                title: const Text('Borrar datos', style: TextStyle(color: Colors.white)),
                content: const Text('Esto eliminará usuario y direcciones. ¿Continuar?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Borrar')),
                ],
              ),
            );
            if (confirm == true) {
              await storage.clearAll();
              usersVM.reset();
            }
          },
        ),
      ],
      body: usersVM.users.isEmpty
          ? const Center(
              child: Text('No hay usuarios creados', style: TextStyle(fontSize: 18)),
            )
          : ListView.separated(
              itemCount: usersVM.users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = usersVM.users[index];
                return _UserCard(user: user, storage: storage, usersVM: usersVM);
              },
            ),
    );
  }
}

class _UserCard extends StatefulWidget {
  final domain.User user;
  final domain.LocalStorageRepository storage;
  final UsersViewModel usersVM;

  const _UserCard({required this.user, required this.storage, required this.usersVM});

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  List<domain.Address>? _addresses;

  Future<void> _loadAddresses() async {
    if (_addresses == null && widget.user.id != null) {
      final addrs = await widget.storage.loadAddressesByUser(widget.user.id!);
      if (mounted) {
        setState(() => _addresses = addrs);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('${widget.user.firstName} ${widget.user.lastName}'),
            subtitle: Text('Nacimiento: ${widget.user.birthDate?.toLocal().toString().split(' ').first ?? '—'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar usuario',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditUserDialog(context),
                ),
                IconButton(
                  tooltip: 'Eliminar usuario',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1B2233),
                        title: const Text('Eliminar usuario', style: TextStyle(color: Colors.white)),
                        content: const Text('¿Eliminar este usuario y todas sus direcciones?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
                        ],
                      ),
                    );
                    if (confirm == true && widget.user.id != null) {
                      await widget.usersVM.deleteUser(widget.user.id!);
                    }
                  },
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: const Text('Direcciones disponibles'),
            onExpansionChanged: (expanded) {
              if (expanded) _loadAddresses();
            },
            children: [
              if (_addresses == null)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else if (_addresses!.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Este usuario no tiene direcciones'),
                )
              else
                ..._addresses!.map((addr) => ListTile(
                      title: Text(addr.line1),
                      subtitle: Text('${addr.country.name} • ${addr.department.name} • ${addr.municipality.name}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showEditAddressDialog(context, addr),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              if (widget.user.id != null) {
                                await widget.storage.deleteAddressForUser(widget.user.id!, addr);
                                _addresses!.remove(addr);
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditUserDialog(BuildContext context) async {
  final firstCtrl = TextEditingController(text: widget.user.firstName);
  final lastCtrl = TextEditingController(text: widget.user.lastName);
  DateTime? birth = widget.user.birthDate;
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1B2233),
      title: const Text('Editar usuario', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: firstCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: lastCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Apellido'),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.cake_outlined),
              label: Text(birth == null ? 'Fecha de nacimiento' : birth!.toLocal().toString().split(' ').first),
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: ctx,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(now.year, now.month, now.day),
                  initialDate: birth ?? DateTime(2000, 1, 1),
                );
                if (picked != null) {
                  birth = picked;
                }
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () async {
            if (widget.user.id != null) {
              final updated = widget.user.copyWith(
                firstName: firstCtrl.text.trim(),
                lastName: lastCtrl.text.trim(),
                birthDate: birth,
              );
              await widget.usersVM.updateUser(updated);
            }
            // ignore: use_build_context_synchronously
            Navigator.pop(ctx);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  }

  Future<void> _showEditAddressDialog(BuildContext context, domain.Address addr) async {
  final ctrl = TextEditingController(text: addr.line1);
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1B2233),
      title: const Text('Editar dirección', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(labelText: 'Dirección física'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () async {
            if (widget.user.id != null) {
              await widget.storage.updateAddressLineForUser(widget.user.id!, addr, ctrl.text.trim());
              final idx = _addresses!.indexOf(addr);
              if (idx != -1) {
                _addresses![idx] = domain.Address(
                  country: addr.country,
                  department: addr.department,
                  municipality: addr.municipality,
                  line1: ctrl.text.trim(),
                );
                setState(() {});
              }
            }
            // ignore: use_build_context_synchronously
            Navigator.pop(ctx);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  }
}
