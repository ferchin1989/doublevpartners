import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/user.dart';

Future<List<User>> listUsers(Database db) async {
  final rows = await db.query('user', orderBy: 'id ASC');
  return rows
      .map((r) => User(
            id: r['id'] as int,
            firstName: r['first_name'] as String,
            lastName: r['last_name'] as String,
            birthDate: (r['birth_date'] as String?) != null
                ? DateTime.tryParse(r['birth_date'] as String)
                : null,
          ))
      .toList();
}
