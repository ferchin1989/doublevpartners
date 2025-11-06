import 'package:sqflite/sqflite.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/local_storage_repository.dart' as domain;
import '../datasources/local_db.dart';
import 'local_storage/clear_all.dart' as clear_all;
import 'local_storage/user_list.dart' as user_list;
import 'local_storage/user_create.dart' as user_create;
import 'local_storage/user_update.dart' as user_update;
import 'local_storage/user_delete.dart' as user_delete;
import 'local_storage/addresses_load_by_user.dart' as addresses_load_by_user;
import 'local_storage/address_add_for_user.dart' as address_add_for_user;
import 'local_storage/address_delete_for_user.dart' as address_delete_for_user;
import 'local_storage/address_update_for_user.dart' as address_update_for_user;

class SqfliteLocalStorageRepository implements domain.LocalStorageRepository {
  final Future<Database> Function() _dbFactory;
  SqfliteLocalStorageRepository({Future<Database> Function()? dbFactory})
      : _dbFactory = dbFactory ?? LocalDb.instance;

  // Legacy single-user methods removed - use multiuser methods instead

  @override
  Future<void> clearAll() async {
    final db = await _dbFactory();
    await clear_all.clearAll(db);
  }

  @override
  Future<List<User>> listUsers() async {
    final db = await _dbFactory();
    return user_list.listUsers(db);
  }

  @override
  Future<User> createUser(User u) async {
    final db = await _dbFactory();
    return user_create.createUser(db, u);
  }

  @override
  Future<void> updateUser(User u) async {
    final db = await _dbFactory();
    await user_update.updateUser(db, u);
  }

  @override
  Future<void> deleteUser(int id) async {
    final db = await _dbFactory();
    await user_delete.deleteUser(db, id);
  }

  @override
  Future<List<Address>> loadAddressesByUser(int userId) async {
    final db = await _dbFactory();
    return addresses_load_by_user.loadAddressesByUser(db, userId);
  }

  @override
  Future<void> addAddressForUser(int userId, Address a) async {
    final db = await _dbFactory();
    await address_add_for_user.addAddressForUser(db, userId, a);
  }

  @override
  Future<void> deleteAddressForUser(int userId, Address a) async {
    final db = await _dbFactory();
    await address_delete_for_user.deleteAddressForUser(db, userId, a);
  }

  @override
  Future<void> updateAddressLineForUser(int userId, Address oldAddress, String newLine1) async {
    final db = await _dbFactory();
    await address_update_for_user.updateAddressLineForUser(db, userId, oldAddress, newLine1);
  }
}
