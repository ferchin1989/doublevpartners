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
}
