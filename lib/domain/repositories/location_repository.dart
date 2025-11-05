import '../entities/location.dart';

abstract class LocationRepository {
  Future<List<Country>> getCountries();
  Future<List<Department>> getDepartments(String countryCode);
  Future<List<Municipality>> getMunicipalities(String departmentCode);
}
