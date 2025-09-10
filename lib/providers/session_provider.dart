import 'user_provider.dart';
import 'package:flutter/material.dart';
import '../modals/user_modal.dart';
import 'auth_provider.dart';

class SessionProvider with ChangeNotifier {
  AuthProvider authProvider;
  UserProvider userProvider;

  SessionProvider({required this.authProvider, required this.userProvider});

  UserModal? get user => userProvider.user;

  void updateUserActivity() {
    // _lastActivity = DateTime.now();
    // if (!_isSessionActive) {
    //   _isSessionActive = true;
    //   notifyListeners();
    // }
  }

  void startIdleCheck(BuildContext context) {
    // Future.delayed(_timeoutDuration).then((_) {
    //   if (DateTime.now().difference(_lastActivity) >= _timeoutDuration) {
    //     _isSessionActive = false;
    //     // authProvider.logout();
        
    //     // notifyListeners();
    //     // Navigator.pushReplacementNamed(context, '/login');
    //   } else {
    //     startIdleCheck(context);
    //   }
    // });
  }

  void setAuthProvider(AuthProvider authProvider) {
    this.authProvider = authProvider;
  }

  void setUserProvider(UserProvider userProvider) {
    this.userProvider = userProvider;
  }

}
