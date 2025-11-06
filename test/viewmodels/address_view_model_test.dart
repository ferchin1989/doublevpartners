import 'package:flutter_test/flutter_test.dart';
import 'package:doublevpartners/presentation/viewmodels/address_view_model.dart';
import 'package:doublevpartners/data/repositories/mock_location_repository.dart';
import 'package:doublevpartners/domain/repositories/local_storage_repository.dart' as domain;
import 'package:doublevpartners/domain/entities/user.dart';
import 'package:doublevpartners/domain/entities/address.dart';

class FakeLocalStorageRepository implements domain.LocalStorageRepository {
  final List<Address> _addresses = [];
  
  @override
  Future<void> clearAll() async { _addresses.clear(); }
  
  @override
  Future<List<User>> listUsers() async => [];
  @override
  Future<User> createUser(User u) async => u.copyWith(id: 1);
  @override
  Future<void> updateUser(User u) async {}
  @override
  Future<void> deleteUser(int id) async {}
  
  @override
  Future<List<Address>> loadAddressesByUser(int userId) async => List.unmodifiable(_addresses);
  @override
  Future<void> addAddressForUser(int userId, Address a) async { _addresses.add(a); }
  @override
  Future<void> deleteAddressForUser(int userId, Address a) async { 
    _addresses.removeWhere((x) => x.line1==a.line1 && x.municipality.code==a.municipality.code); 
  }
  @override
  Future<void> updateAddressLineForUser(int userId, Address oldAddress, String newLine1) async {
    final idx = _addresses.indexWhere((x) => x.line1==oldAddress.line1 && x.municipality.code==oldAddress.municipality.code);
    if (idx != -1) {
      _addresses[idx] = Address(
        country: oldAddress.country,
        department: oldAddress.department,
        municipality: oldAddress.municipality,
        line1: newLine1,
      );
    }
  }
}

void main() {
  group('AddressViewModel', () {
    test('loads countries and dependent lists; adds and removes address', () async {
      final vm = AddressViewModel(MockLocationRepository(), FakeLocalStorageRepository());

      expect(vm.countries, isEmpty);
      await vm.loadCountries();
      expect(vm.countries, isNotEmpty);

      // Select first country
      await vm.onCountryChanged(vm.countries.first);
      expect(vm.departments, isNotEmpty);
      expect(vm.municipalities, isEmpty);

      // Select first department
      await vm.onDepartmentChanged(vm.departments.first);
      expect(vm.municipalities, isNotEmpty);

      // Select first municipality and set line1
      vm.onMunicipalityChanged(vm.municipalities.first);
      vm.onLine1Changed('Calle 123 #45-67');

      // Add address
      await vm.addAddressForUser(1);
      expect(vm.addresses.length, 1);

      // Remove address
      await vm.removeAtForUser(1, 0);
      expect(vm.addresses, isEmpty);
    });
  });
}
