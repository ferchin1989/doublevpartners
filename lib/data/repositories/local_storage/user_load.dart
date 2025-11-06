import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/user.dart';

Future<User?> loadUser(Database db) async {
  final rows = await db.query('user', where: 'id = 1');
  if (rows.isEmpty) return null;
  final r = rows.first;
  return User(
    firstName: r['first_name'] as String,
    lastName: r['last_name'] as String,
    birthDate: (r['birth_date'] as String?) != null
        ? DateTime.tryParse(r['birth_date'] as String)
        : null,
  );
}
