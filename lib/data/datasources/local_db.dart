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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            birth_date TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE addresses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            country_code TEXT NOT NULL,
            country_name TEXT NOT NULL,
            department_code TEXT NOT NULL,
            department_name TEXT NOT NULL,
            municipality_code TEXT NOT NULL,
            municipality_name TEXT NOT NULL,
            line1 TEXT NOT NULL
          );
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses(user_id);');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add user_id with default 1 to existing rows
          await db.execute('ALTER TABLE addresses ADD COLUMN user_id INTEGER NOT NULL DEFAULT 1;');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses(user_id);');
        }
        if (oldVersion < 3) {
          // Recreate user table with AUTOINCREMENT id, migrating existing single row (assumed id=1)
          await db.execute('''
            CREATE TABLE user_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              first_name TEXT NOT NULL,
              last_name TEXT NOT NULL,
              birth_date TEXT
            );
          ''');
          // Try copy existing single user (ignore if fails - no data to migrate)
          try {
            await db.execute('INSERT INTO user_new (id, first_name, last_name, birth_date) SELECT 1, first_name, last_name, birth_date FROM user WHERE id = 1');
          } catch (_) {
            // No existing user to migrate - that's OK
          }
          await db.execute('DROP TABLE IF EXISTS user');
          await db.execute('ALTER TABLE user_new RENAME TO user');
        }
      },
    );
    return _db!;
  }
}
