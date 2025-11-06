import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/address.dart';

Future<void> deleteAddressForUser(Database db, int userId, Address a) async {
  await db.delete(
    'addresses',
    where: 'user_id = ? AND country_code=? AND department_code=? AND municipality_code=? AND line1=?',
    whereArgs: [
      userId,
      a.country.code,
      a.department.code,
      a.municipality.code,
      a.line1,
    ],
  );
}
