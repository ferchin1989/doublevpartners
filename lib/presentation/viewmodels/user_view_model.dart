import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';

class UserViewModel extends ChangeNotifier {
  User _user = User.empty;
  User get user => _user;

  void updateFirstName(String v) { _user = _user.copyWith(firstName: v); notifyListeners(); }
  void updateLastName(String v) { _user = _user.copyWith(lastName: v); notifyListeners(); }
  void updateBirthDate(DateTime? d) { _user = _user.copyWith(birthDate: d); notifyListeners(); }
}
