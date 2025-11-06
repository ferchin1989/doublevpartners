import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/user.dart';

Future<void> saveUser(Database db, User u) async {
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
