import 'dart:async';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';

class MockLocationRepository implements LocationRepository {
  final _countries = const [
    Country('CO', 'Colombia'),
    Country('MX', 'México'),
  ];

  final _departments = const [
    Department('ANT', 'Antioquia', 'CO'),
    Department('CUN', 'Cundinamarca', 'CO'),
    Department('CMX', 'Ciudad de México', 'MX'),
  ];

  final _municipalities = const [
    Municipality('MED', 'Medellín', 'ANT'),
    Municipality('ENV', 'Envigado', 'ANT'),
    Municipality('BOG', 'Bogotá', 'CUN'),
    Municipality('COY', 'Coyoacán', 'CMX'),
  ];

  @override
  Future<List<Country>> getCountries() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _countries;
    }

  @override
  Future<List<Department>> getDepartments(String countryCode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _departments.where((d) => d.countryCode == countryCode).toList();
  }

  @override
  Future<List<Municipality>> getMunicipalities(String departmentCode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _municipalities.where((m) => m.departmentCode == departmentCode).toList();
  }
}
