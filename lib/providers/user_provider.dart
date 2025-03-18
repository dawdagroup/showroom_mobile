import 'package:flutter/material.dart';

import '../modals/user_modal.dart';

class UserProvider extends ChangeNotifier {
  UserModal? _user;

  UserModal? get user => _user;

  void setUser(UserModal user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void updateUser(UserModal user) {
    _user = user;
    notifyListeners();
  }

  void deleteUser() {
    _user = null;
    notifyListeners();
  }
}