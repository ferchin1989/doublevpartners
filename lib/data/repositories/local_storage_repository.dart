import 'package:sqflite/sqflite.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/local_storage_repository.dart' as domain;
import '../datasources/local_db.dart';
import 'local_storage/user_load.dart' as user_load;
import 'local_storage/user_save.dart' as user_save;
import 'local_storage/addresses_load.dart' as addresses_load;
import 'local_storage/address_add.dart' as address_add;
import 'local_storage/address_delete.dart' as address_delete;
import 'local_storage/address_update.dart' as address_update;
import 'local_storage/clear_all.dart' as clear_all;

class SqfliteLocalStorageRepository implements domain.LocalStorageRepository {
  final Future<Database> Function() _dbFactory;
  SqfliteLocalStorageRepository({Future<Database> Function()? dbFactory})
      : _dbFactory = dbFactory ?? LocalDb.instance;

  @override
  Future<User?> loadUser() async {
    final db = await _dbFactory();
    return user_load.loadUser(db);
  }

  @override
  Future<void> saveUser(User u) async {
    final db = await _dbFactory();
    await user_save.saveUser(db, u);
  }

  @override
  Future<List<Address>> loadAddresses() async {
    final db = await _dbFactory();
    return addresses_load.loadAddresses(db);
  }

  @override
  Future<void> addAddress(Address a) async {
    final db = await _dbFactory();
    await address_add.addAddress(db, a);
  }

  @override
  Future<void> deleteAddress(Address a) async {
    final db = await _dbFactory();
    await address_delete.deleteAddress(db, a);
  }

  @override
  Future<void> updateAddressLine(Address oldAddress, String newLine1) async {
    final db = await _dbFactory();
    await address_update.updateAddressLine(db, oldAddress, newLine1);
  }

  @override
  Future<void> clearAll() async {
    final db = await _dbFactory();
    await clear_all.clearAll(db);
  }
}
