import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';

abstract class LocalStorageRepository {
  // Database management
  Future<void> clearAll();

  // User operations
  Future<List<User>> listUsers();
  Future<User> createUser(User u);
  Future<void> updateUser(User u);
  Future<void> deleteUser(int id);

  // Address operations (by user)
  Future<List<Address>> loadAddressesByUser(int userId);
  Future<void> addAddressForUser(int userId, Address a);
  Future<void> deleteAddressForUser(int userId, Address a);
  Future<void> updateAddressLineForUser(int userId, Address oldAddress, String newLine1);
}
