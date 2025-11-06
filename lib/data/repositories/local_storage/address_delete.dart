import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/address.dart';

Future<void> deleteAddress(Database db, Address a) async {
  await db.delete(
    'addresses',
    where: 'country_code=? AND department_code=? AND municipality_code=? AND line1=?',
    whereArgs: [
      a.country.code,
      a.department.code,
      a.municipality.code,
      a.line1,
    ],
  );
}
