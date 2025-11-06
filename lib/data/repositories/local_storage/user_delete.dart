import 'package:sqflite/sqflite.dart';

Future<void> deleteUser(Database db, int id) async {
  // Delete user's addresses first
  await db.delete('addresses', where: 'user_id = ?', whereArgs: [id]);
  // Delete user
  await db.delete('user', where: 'id = ?', whereArgs: [id]);
}
