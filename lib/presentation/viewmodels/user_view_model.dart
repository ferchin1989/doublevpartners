import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/local_storage_repository.dart';

class UserViewModel extends ChangeNotifier {
  final LocalStorageRepository _storage;
  UserViewModel(this._storage);

  User _user = User.empty;
  User get user => _user;

  Future<void> loadFromStorage() async {
    final u = await _storage.loadUser();
    if (u != null) {
      _user = u;
      notifyListeners();
    }
  }

  Future<void> updateFirstName(String v) async {
    _user = _user.copyWith(firstName: v); notifyListeners();
    await _storage.saveUser(_user);
  }

  Future<void> updateLastName(String v) async {
    _user = _user.copyWith(lastName: v); notifyListeners();
    await _storage.saveUser(_user);
  }

  Future<void> updateBirthDate(DateTime? d) async {
    _user = _user.copyWith(birthDate: d); notifyListeners();
    await _storage.saveUser(_user);
  }

  void reset() {
    _user = User.empty;
    notifyListeners();
  }
}
