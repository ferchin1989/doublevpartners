import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/user.dart';

Future<User> createUser(Database db, User u) async {
  final id = await db.insert('user', {
    'first_name': u.firstName,
    'last_name': u.lastName,
    'birth_date': u.birthDate?.toIso8601String(),
  });
  return u.copyWith(id: id);
}
