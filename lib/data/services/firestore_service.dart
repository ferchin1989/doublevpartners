import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/entities/address.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencia a la colección de usuarios
  CollectionReference get _usersCollection => _firestore.collection('users');

  // ========== USERS ==========

  // Crear usuario en Firestore
  Future<void> createUser(String uid, domain.User user) async {
    await _usersCollection.doc(uid).set({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'birthDate': user.birthDate?.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Obtener usuarios del usuario autenticado
  Stream<List<domain.User>> getUsersStream(String uid) {
    return _usersCollection
        .doc(uid)
        .collection('userProfiles')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return domain.User(
                id: int.tryParse(doc.id),
                firstName: data['firstName'] ?? '',
                lastName: data['lastName'] ?? '',
                birthDate: data['birthDate'] != null
                    ? DateTime.parse(data['birthDate'])
                    : null,
              );
            }).toList());
  }

  // Crear perfil de usuario
  Future<String> createUserProfile(String uid, domain.User user) async {
    final docRef = await _usersCollection
        .doc(uid)
        .collection('userProfiles')
        .add({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'birthDate': user.birthDate?.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile(String uid, String profileId, domain.User user) async {
    await _usersCollection
        .doc(uid)
        .collection('userProfiles')
        .doc(profileId)
        .update({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'birthDate': user.birthDate?.toIso8601String(),
    });
  }

  // Eliminar perfil de usuario
  Future<void> deleteUserProfile(String uid, String profileId) async {
    // Eliminar todas las direcciones del perfil
    final addressesSnapshot = await _usersCollection
        .doc(uid)
        .collection('userProfiles')
        .doc(profileId)
        .collection('addresses')
        .get();
    
    for (var doc in addressesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Eliminar el perfil
    await _usersCollection
        .doc(uid)
        .collection('userProfiles')
        .doc(profileId)
        .delete();
  }

  // ========== ADDRESSES ==========

  // Obtener direcciones de un perfil
  Stream<List<Address>> getAddressesStream(String uid, String profileId) {
    return _usersCollection
        .doc(uid)
        .collection('userProfiles')
        .doc(profileId)
        .collection('addresses')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Address(
                country: data['country'],
                department: data['department'],
                municipality: data['municipality'],
                line1: data['line1'] ?? '',
              );
            }).toList());
  }

  // Agregar dirección
  Future<void> addAddress(String uid, String profileId, Address address) async {
    await _usersCollection
        .doc(uid)
        .collection('userProfiles')
        .doc(profileId)
        .collection('addresses')
        .add({
      'country': {
        'code': address.country.code,
        'name': address.country.name,
      },
      'department': {
        'code': address.department.code,
        'name': address.department.name,
      },
      'municipality': {
        'code': address.municipality.code,
        'name': address.municipality.name,
      },
      'line1': address.line1,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Actualizar dirección
  Future<void> updateAddress(
    String uid,
    String profileId,
    String addressId,
    String newLine1,
  ) async {
    await _usersCollection
        .doc(uid)
        .collection('userProfiles')
        .doc(profileId)
        .collection('addresses')
        .doc(addressId)
        .update({'line1': newLine1});
  }

  // Eliminar dirección
  Future<void> deleteAddress(String uid, String profileId, String addressId) async {
    await _usersCollection
        .doc(uid)
        .collection('userProfiles')
        .doc(profileId)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  // Limpiar todos los datos del usuario
  Future<void> clearAllUserData(String uid) async {
    final profilesSnapshot = await _usersCollection
        .doc(uid)
        .collection('userProfiles')
        .get();

    for (var profile in profilesSnapshot.docs) {
      await deleteUserProfile(uid, profile.id);
    }
  }
}
