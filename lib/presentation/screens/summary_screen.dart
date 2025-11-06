import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import '../viewmodels/address_view_model.dart';
import '../widgets/futuristic_scaffold.dart';
import '../../domain/repositories/local_storage_repository.dart' as domain;

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserViewModel>().user;
    final addresses = context.watch<AddressViewModel>().addresses;

    return FuturisticScaffold(
      title: 'Resumen',
      actions: [
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
              await context.read<domain.LocalStorageRepository>().clearAll();
              // Reset estado en memoria
              context.read<UserViewModel>().reset();
              await context.read<AddressViewModel>().loadFromStorage();
            }
          },
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${user.firstName} ${user.lastName}', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Nacimiento: ${user.birthDate?.toLocal().toString().split(' ').first ?? '—'}'),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Editar usuario',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                      await _showEditUserDialog(context);
                    },
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Direcciones', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (addresses.isEmpty)
            const Text('Sin direcciones aún')
          else
            Expanded(
              child: ListView.separated(
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final a = addresses[index];
                  return Card(
                    child: ExpansionTile(
                      title: Text(a.line1),
                      subtitle: Text('${a.country.name} • ${a.department.name} • ${a.municipality.name}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              FilledButton.icon(
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Editar'),
                                onPressed: () async {
                                  await _showEditAddressDialog(context, index, a.line1);
                                },
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Eliminar'),
                                onPressed: () => context.read<AddressViewModel>().removeAt(index),
                              ),
                            ],
                          ),
                        )
                      ],
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

Future<void> _showEditUserDialog(BuildContext context) async {
  final vm = context.read<UserViewModel>();
  final firstCtrl = TextEditingController(text: vm.user.firstName);
  final lastCtrl = TextEditingController(text: vm.user.lastName);
  DateTime? birth = vm.user.birthDate;
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
            await vm.updateFirstName(firstCtrl.text.trim());
            await vm.updateLastName(lastCtrl.text.trim());
            await vm.updateBirthDate(birth);
            // ignore: use_build_context_synchronously
            Navigator.pop(ctx);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

Future<void> _showEditAddressDialog(BuildContext context, int index, String currentLine) async {
  final vm = context.read<AddressViewModel>();
  final ctrl = TextEditingController(text: currentLine);
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
            await vm.updateLineAt(index, ctrl.text);
            // ignore: use_build_context_synchronously
            Navigator.pop(ctx);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
