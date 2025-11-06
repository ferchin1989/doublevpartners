import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/entities/location.dart';

Future<List<Address>> loadAddresses(Database db) async {
  final rows = await db.query('addresses', orderBy: 'id ASC');
  return rows.map((r) {
    final country = Country(r['country_code'] as String, r['country_name'] as String);
    final department = Department(
      r['department_code'] as String,
      r['department_name'] as String,
      r['country_code'] as String,
    );
    final municipality = Municipality(
      r['municipality_code'] as String,
      r['municipality_name'] as String,
      r['department_code'] as String,
    );
    return Address(
      country: country,
      department: department,
      municipality: municipality,
      line1: r['line1'] as String,
    );
  }).toList();
}
