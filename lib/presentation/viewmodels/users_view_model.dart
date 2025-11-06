import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/local_storage_repository.dart';

class UsersViewModel extends ChangeNotifier {
  final LocalStorageRepository _storage;
  UsersViewModel(this._storage);

  List<User> _users = [];
  List<User> get users => List.unmodifiable(_users);

  User? _activeUser;
  User? get activeUser => _activeUser;

  Future<void> loadUsers() async {
    _users = await _storage.listUsers();
    if (_users.isNotEmpty && _activeUser == null) {
      _activeUser = _users.first;
    }
    notifyListeners();
  }

  Future<User> createUser(String firstName, String lastName, DateTime? birthDate) async {
    final newUser = await _storage.createUser(User(
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
    ));
    _users.add(newUser);
    _activeUser = newUser;
    notifyListeners();
    return newUser;
  }

  Future<void> updateUser(User u) async {
    await _storage.updateUser(u);
    final idx = _users.indexWhere((user) => user.id == u.id);
    if (idx != -1) {
      _users[idx] = u;
      if (_activeUser?.id == u.id) {
        _activeUser = u;
      }
      notifyListeners();
    }
  }

  Future<void> deleteUser(int id) async {
    await _storage.deleteUser(id);
    _users.removeWhere((u) => u.id == id);
    if (_activeUser?.id == id) {
      _activeUser = _users.isNotEmpty ? _users.first : null;
    }
    notifyListeners();
  }

  void setActiveUser(User u) {
    _activeUser = u;
    notifyListeners();
  }

  void reset() {
    _users.clear();
    _activeUser = null;
    notifyListeners();
  }
}
