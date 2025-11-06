import 'package:flutter/foundation.dart';
import '../../data/services/connectivity_service.dart';

class ConnectivityViewModel extends ChangeNotifier {
  final ConnectivityService _connectivityService;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  ConnectivityViewModel(this._connectivityService) {
    _initConnectivity();
  }

  void _initConnectivity() async {
    // Verificar estado inicial
    _isOnline = await _connectivityService.isConnected;
    notifyListeners();
    
    // Escuchar cambios
    _connectivityService.connectivityStream.listen((isConnected) {
      if (_isOnline != isConnected) {
        _isOnline = isConnected;
        notifyListeners();
        
        // Mostrar notificación al usuario
        if (_isOnline) {
          debugPrint('✅ Conexión restaurada - Sincronizando con Firebase...');
        } else {
          debugPrint('⚠️ Sin conexión - Trabajando en modo offline (caché local)');
        }
      }
    });
  }
}
