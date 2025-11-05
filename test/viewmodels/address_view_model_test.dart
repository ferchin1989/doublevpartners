import 'package:flutter_test/flutter_test.dart';
import 'package:doublevpartners/presentation/viewmodels/address_view_model.dart';
import 'package:doublevpartners/data/repositories/mock_location_repository.dart';

void main() {
  group('AddressViewModel', () {
    test('loads countries and dependent lists; adds and removes address', () async {
      final vm = AddressViewModel(MockLocationRepository());

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
