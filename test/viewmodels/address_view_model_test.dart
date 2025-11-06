import 'package:flutter_test/flutter_test.dart';
import 'package:doublevpartners/presentation/viewmodels/address_view_model.dart';
import 'package:doublevpartners/data/repositories/mock_location_repository.dart';
import 'package:doublevpartners/domain/repositories/local_storage_repository.dart' as domain;
import 'package:doublevpartners/domain/entities/user.dart';
import 'package:doublevpartners/domain/entities/address.dart';

class FakeLocalStorageRepository implements domain.LocalStorageRepository {
  final List<Address> _addresses = [];
  @override
  Future<List<Address>> loadAddresses() async => List.unmodifiable(_addresses);
  @override
  Future<void> addAddress(Address a) async { _addresses.add(a); }
  @override
  Future<void> deleteAddress(Address a) async { _addresses.removeWhere((x) => x.line1==a.line1 && x.municipality.code==a.municipality.code); }
  // User methods not used here but must exist
  @override
  Future<User?> loadUser() async => null;
  @override
  Future<void> saveUser(User u) async {}
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
      vm.addAddress();
      expect(vm.addresses.length, 1);

      // Remove address
      vm.removeAt(0);
      expect(vm.addresses, isEmpty);
    });
  });
}
