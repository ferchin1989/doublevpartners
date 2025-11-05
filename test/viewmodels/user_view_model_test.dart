import 'package:flutter_test/flutter_test.dart';
import 'package:doublevpartners/presentation/viewmodels/user_view_model.dart';
import 'package:doublevpartners/data/repositories/local_storage_repository.dart';
import 'package:doublevpartners/domain/entities/user.dart';

class FakeLocalStorageRepository extends LocalStorageRepository {
  User? _user;
  FakeLocalStorageRepository(): super(dbFactory: () async => throw UnimplementedError());
  @override
  Future<User?> loadUser() async => _user;
  @override
  Future<void> saveUser(User u) async { _user = u; }
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
