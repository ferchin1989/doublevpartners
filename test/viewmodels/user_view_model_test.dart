import 'package:flutter_test/flutter_test.dart';
import 'package:doublevpartners/presentation/viewmodels/user_view_model.dart';

void main() {
  group('UserViewModel', () {
    test('updates first and last name and birth date', () {
      final vm = UserViewModel();
      expect(vm.user.firstName, '');
      expect(vm.user.lastName, '');
      expect(vm.user.birthDate, isNull);

      vm.updateFirstName('Ada');
      vm.updateLastName('Lovelace');
      final d = DateTime(1815, 12, 10);
      vm.updateBirthDate(d);

      expect(vm.user.firstName, 'Ada');
      expect(vm.user.lastName, 'Lovelace');
      expect(vm.user.birthDate, d);
    });
  });
}
