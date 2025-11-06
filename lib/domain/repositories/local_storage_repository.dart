import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';

abstract class LocalStorageRepository {
  Future<User?> loadUser();
  Future<void> saveUser(User u);

  Future<List<Address>> loadAddresses();
  Future<void> addAddress(Address a);
  Future<void> deleteAddress(Address a);
  Future<void> updateAddressLine(Address oldAddress, String newLine1);
  Future<void> clearAll();

  // Multiuser
  Future<List<User>> listUsers();
  Future<User> createUser(User u);
  Future<void> updateUser(User u);
  Future<void> deleteUser(int id);
  Future<List<Address>> loadAddressesByUser(int userId);
  Future<void> addAddressForUser(int userId, Address a);
  Future<void> deleteAddressForUser(int userId, Address a);
  Future<void> updateAddressLineForUser(int userId, Address oldAddress, String newLine1);
}
