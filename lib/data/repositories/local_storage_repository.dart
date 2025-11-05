import 'package:sqflite/sqflite.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/location.dart';
import '../datasources/local_db.dart';

class LocalStorageRepository {
  final Future<Database> Function() _dbFactory;
  LocalStorageRepository({Future<Database> Function()? dbFactory})
      : _dbFactory = dbFactory ?? LocalDb.instance;

  Future<User?> loadUser() async {
    final db = await _dbFactory();
    final rows = await db.query('user', where: 'id = 1');
    if (rows.isEmpty) return null;
    final r = rows.first;
    return User(
      firstName: r['first_name'] as String,
      lastName: r['last_name'] as String,
      birthDate: (r['birth_date'] as String?) != null ? DateTime.tryParse(r['birth_date'] as String) : null,
    );
  }

  Future<void> saveUser(User u) async {
    final db = await _dbFactory();
    await db.insert(
      'user',
      {
        'id': 1,
        'first_name': u.firstName,
        'last_name': u.lastName,
        'birth_date': u.birthDate?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Address>> loadAddresses() async {
    final db = await _dbFactory();
    final rows = await db.query('addresses', orderBy: 'id ASC');
    return rows.map((r) {
      final country = Country(r['country_code'] as String, r['country_name'] as String);
      final department = Department(
        r['department_code'] as String,
        r['department_name'] as String,
        r['country_code'] as String,
      );
      final municipality = Municipality(
        r['municipality_code'] as String,
        r['municipality_name'] as String,
        r['department_code'] as String,
      );
      return Address(
        country: country,
        department: department,
        municipality: municipality,
        line1: r['line1'] as String,
      );
    }).toList();
  }

  Future<void> addAddress(Address a) async {
    final db = await _dbFactory();
    await db.insert('addresses', {
      'country_code': a.country.code,
      'country_name': a.country.name,
      'department_code': a.department.code,
      'department_name': a.department.name,
      'municipality_code': a.municipality.code,
      'municipality_name': a.municipality.name,
      'line1': a.line1,
    });
  }

  Future<void> deleteAddress(Address a) async {
    final db = await _dbFactory();
    await db.delete(
      'addresses',
      where:
          'country_code=? AND department_code=? AND municipality_code=? AND line1=?',
      whereArgs: [
        a.country.code,
        a.department.code,
        a.municipality.code,
        a.line1,
      ],
    );
  }
}
