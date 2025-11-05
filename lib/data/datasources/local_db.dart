import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDb {
  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'doublevpartners.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            birth_date TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE addresses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            country_code TEXT NOT NULL,
            country_name TEXT NOT NULL,
            department_code TEXT NOT NULL,
            department_name TEXT NOT NULL,
            municipality_code TEXT NOT NULL,
            municipality_name TEXT NOT NULL,
            line1 TEXT NOT NULL
          );
        ''');
      },
    );
    return _db!;
  }
}
