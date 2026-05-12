import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _isOffline = false;
  bool _isLoggedIn = false;

  bool get isOffline => _isOffline;
  bool get isLoggedIn => _isLoggedIn;

  void setOffline() {
    _isOffline = true;
    _isLoggedIn = false;
    notifyListeners();
  }

  void setLoggedIn() {
    _isLoggedIn = true;
    _isOffline = false;
    notifyListeners();
  }

  void setLoggedOut() {
    _isLoggedIn = false;
    _isOffline = false;
    notifyListeners();
  }
}