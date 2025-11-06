import 'package:flutter_test/flutter_test.dart';
import 'package:doublevpartners/presentation/viewmodels/user_view_model.dart';
import 'package:doublevpartners/domain/repositories/local_storage_repository.dart' as domain;
import 'package:doublevpartners/domain/entities/user.dart';
import 'package:doublevpartners/domain/entities/address.dart';

class FakeLocalStorageRepository implements domain.LocalStorageRepository {
  User? _user;
  @override
  Future<User?> loadUser() async => _user;
  @override
  Future<void> saveUser(User u) async { _user = u; }
  // Unused in these tests
  @override
  Future<void> addAddress(Address a) async {}
  @override
  Future<void> deleteAddress(Address a) async {}
  @override
  Future<List<Address>> loadAddresses() async => [];
}

void main() {
  group('UserViewModel', () {
    test('updates first and last name and birth date', () async {
      final vm = UserViewModel(FakeLocalStorageRepository());
      expect(vm.user.firstName, '');
      expect(vm.user.lastName, '');
      expect(vm.user.birthDate, isNull);

      await vm.updateFirstName('Ada');
      await vm.updateLastName('Lovelace');
      final d = DateTime(1815, 12, 10);
      await vm.updateBirthDate(d);

      expect(vm.user.firstName, 'Ada');
      expect(vm.user.lastName, 'Lovelace');
      expect(vm.user.birthDate, d);
    });
  });
}
