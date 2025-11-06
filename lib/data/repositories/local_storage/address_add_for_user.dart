import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/address.dart';

Future<void> addAddressForUser(Database db, int userId, Address a) async {
  await db.insert('addresses', {
    'user_id': userId,
    'country_code': a.country.code,
    'country_name': a.country.name,
    'department_code': a.department.code,
    'department_name': a.department.name,
    'municipality_code': a.municipality.code,
    'municipality_name': a.municipality.name,
    'line1': a.line1,
  });
}
