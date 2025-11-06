import 'package:sqflite/sqflite.dart';

Future<void> clearAll(Database db) async {
  await db.delete('addresses');
  await db.delete('user');
}
