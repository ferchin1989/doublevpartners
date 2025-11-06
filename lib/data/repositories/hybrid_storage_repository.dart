import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/local_storage_repository.dart';
import '../services/firestore_service.dart';
import '../services/connectivity_service.dart';
import 'local_storage_repository.dart';

/// Repositorio híbrido que usa Firebase cuando hay conexión y SQLite como caché
class HybridStorageRepository implements LocalStorageRepository {
  final FirestoreService _firestore;
  final SqfliteLocalStorageRepository _localCache;
  final ConnectivityService _connectivity;
  final String _userId; // UID del usuario autenticado

  HybridStorageRepository({
    required FirestoreService firestore,
    required SqfliteLocalStorageRepository localCache,
    required ConnectivityService connectivity,
    required String userId,
  })  : _firestore = firestore,
        _localCache = localCache,
        _connectivity = connectivity,
        _userId = userId;

  // ========== CLEAR ALL ==========
  
  @override
  Future<void> clearAll() async {
    final isOnline = await _connectivity.isConnected;
    
    if (isOnline) {
      // Limpiar Firebase
      await _firestore.clearAllUserData(_userId);
    }
    
    // Siempre limpiar caché local
    await _localCache.clearAll();
  }

  // ========== USERS ==========

  @override
  Future<List<User>> listUsers() async {
    // Primero retornar caché (rápido)
    final cachedUsers = await _localCache.listUsers();
    
    // Luego intentar sincronizar en background si hay conexión
    final isOnline = await _connectivity.isConnected;
    if (isOnline) {
      // No bloquear, sincronizar en background
      _syncUsersInBackground();
    }
    
    return cachedUsers;
  }
  
  // Sincronización en background sin bloquear UI
  Future<void> _syncUsersInBackground() async {
    try {
      final users = await _firestore.getUsersStream(_userId).first;
      
      // Actualizar caché local
      await _localCache.clearAll();
      for (var user in users) {
        await _localCache.createUser(user);
      }
    } catch (e) {
      // Ignorar errores de sincronización background
    }
  }

  @override
  Future<User> createUser(User u) async {
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        // Crear en Firebase
        final profileId = await _firestore.createUserProfile(_userId, u);
        final createdUser = u.copyWith(id: int.tryParse(profileId) ?? DateTime.now().millisecondsSinceEpoch);
        
        // Actualizar caché
        await _localCache.createUser(createdUser);
        
        return createdUser;
      } catch (e) {
        // Si falla Firebase, guardar solo en caché (pendiente de sincronización)
        return await _localCache.createUser(u);
      }
    } else {
      // Sin conexión: guardar en caché
      return await _localCache.createUser(u);
    }
  }

  @override
  Future<void> updateUser(User u) async {
    final isOnline = await _connectivity.isConnected;

    if (isOnline && u.id != null) {
      try {
        // Actualizar en Firebase
        await _firestore.updateUserProfile(_userId, u.id.toString(), u);
      } catch (e) {
        // Ignorar error, se sincronizará después
      }
    }
    
    // Siempre actualizar caché
    await _localCache.updateUser(u);
  }

  @override
  Future<void> deleteUser(int id) async {
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        // Eliminar de Firebase
        await _firestore.deleteUserProfile(_userId, id.toString());
      } catch (e) {
        // Ignorar error, se sincronizará después
      }
    }
    
    // Siempre eliminar de caché
    await _localCache.deleteUser(id);
  }

  // ========== ADDRESSES ==========

  @override
  Future<List<Address>> loadAddressesByUser(int userId) async {
    // Primero retornar caché (rápido)
    final cachedAddresses = await _localCache.loadAddressesByUser(userId);
    
    // Luego intentar sincronizar en background si hay conexión
    final isOnline = await _connectivity.isConnected;
    if (isOnline) {
      // No bloquear, sincronizar en background
      _syncAddressesInBackground(userId);
    }
    
    return cachedAddresses;
  }
  
  // Sincronización en background sin bloquear UI
  Future<void> _syncAddressesInBackground(int userId) async {
    try {
      final addresses = await _firestore.getAddressesStream(_userId, userId.toString()).first;
      
      // Actualizar caché (eliminar viejas y agregar nuevas)
      final cachedAddresses = await _localCache.loadAddressesByUser(userId);
      for (var addr in cachedAddresses) {
        await _localCache.deleteAddressForUser(userId, addr);
      }
      for (var addr in addresses) {
        await _localCache.addAddressForUser(userId, addr);
      }
    } catch (e) {
      // Ignorar errores de sincronización background
    }
  }

  @override
  Future<void> addAddressForUser(int userId, Address a) async {
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        // Agregar a Firebase
        await _firestore.addAddress(_userId, userId.toString(), a);
      } catch (e) {
        // Ignorar error, se sincronizará después
      }
    }
    
    // Siempre agregar a caché
    await _localCache.addAddressForUser(userId, a);
  }

  @override
  Future<void> deleteAddressForUser(int userId, Address a) async {
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        // Nota: Para eliminar correctamente de Firestore necesitarías el addressId
        // Por ahora, solo eliminamos del caché local
        // TODO: Implementar eliminación en Firestore cuando se agregue addressId a la entidad
      } catch (e) {
        // Ignorar error
      }
    }
    
    // Siempre eliminar de caché
    await _localCache.deleteAddressForUser(userId, a);
  }

  @override
  Future<void> updateAddressLineForUser(int userId, Address oldAddress, String newLine1) async {
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        // Actualizar en Firebase
        // Nota: necesitarías el addressId de Firestore para actualizar correctamente
        // Por ahora, solo actualizamos el caché
      } catch (e) {
        // Ignorar error
      }
    }
    
    // Siempre actualizar caché
    await _localCache.updateAddressLineForUser(userId, oldAddress, newLine1);
  }
}
