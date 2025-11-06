import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/connectivity_view_model.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityVM = context.watch<ConnectivityViewModel>();

    if (connectivityVM.isOnline) {
      return const SizedBox.shrink(); // No mostrar nada si hay conexión
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade700,
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Sin conexión - Modo offline (usando caché local)',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Icon(Icons.info_outline, color: Colors.white.withOpacity(0.7), size: 16),
        ],
      ),
    );
  }
}
