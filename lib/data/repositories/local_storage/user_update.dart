import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/user.dart';

Future<void> updateUser(Database db, User u) async {
  await db.update(
    'user',
    {
      'first_name': u.firstName,
      'last_name': u.lastName,
      'birth_date': u.birthDate?.toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [u.id],
  );
}
