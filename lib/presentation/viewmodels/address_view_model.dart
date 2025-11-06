import 'package:flutter/foundation.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/local_storage_repository.dart';

class AddressViewModel extends ChangeNotifier {
  final LocationRepository repo;
  final LocalStorageRepository storage;
  AddressViewModel(this.repo, this.storage);

  final List<Address> _addresses = [];
  List<Address> get addresses => List.unmodifiable(_addresses);

  List<Country> countries = [];
  List<Department> departments = [];
  List<Municipality> municipalities = [];

  Country? selectedCountry;
  Department? selectedDepartment;
  Municipality? selectedMunicipality;
  String line1 = '';

  Future<void> loadFromStorage() async {
    final loaded = await storage.loadAddresses();
    _addresses
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<void> loadCountries() async {
    countries = await repo.getCountries();
    notifyListeners();
  }

  Future<void> onCountryChanged(Country? c) async {
    selectedCountry = c; selectedDepartment = null; selectedMunicipality = null;
    departments = c == null ? [] : await repo.getDepartments(c.code);
    municipalities = [];
    notifyListeners();
  }

  Future<void> onDepartmentChanged(Department? d) async {
    selectedDepartment = d; selectedMunicipality = null;
    municipalities = d == null ? [] : await repo.getMunicipalities(d.code);
    notifyListeners();
  }

  void onMunicipalityChanged(Municipality? m) { selectedMunicipality = m; notifyListeners(); }
  void onLine1Changed(String v) { line1 = v; notifyListeners(); }

  void addAddress() {
    if (selectedCountry != null && selectedDepartment != null && selectedMunicipality != null && line1.isNotEmpty) {
      final a = Address(
        country: selectedCountry!,
        department: selectedDepartment!,
        municipality: selectedMunicipality!,
        line1: line1,
      );
      _addresses.add(a);
      storage.addAddress(a);
      line1 = '';
      notifyListeners();
    }
  }

  void removeAt(int index) {
    if (index>=0 && index<_addresses.length) {
      final a = _addresses.removeAt(index);
      storage.deleteAddress(a);
      notifyListeners();
    }
  }
}
