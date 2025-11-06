import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/address.dart';

Future<void> updateAddressLineForUser(Database db, int userId, Address oldAddress, String newLine1) async {
  await db.update(
    'addresses',
    {
      'line1': newLine1,
    },
    where: 'user_id = ? AND country_code=? AND department_code=? AND municipality_code=? AND line1=?',
    whereArgs: [
      userId,
      oldAddress.country.code,
      oldAddress.department.code,
      oldAddress.municipality.code,
      oldAddress.line1,
    ],
  );
}
