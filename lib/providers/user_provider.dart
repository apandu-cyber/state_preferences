import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;

  UserProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    // Latihan 2: Counter Kunjungan
    int currentVisit = prefs.getInt('visit_count') ?? 0;
    currentVisit++;
    await prefs.setInt('visit_count', currentVisit);

    _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
    _isDarkMode = isDarkMode;
    _visitCount = currentVisit;
    _isLoading = false;

    notifyListeners(); // Update UI
  }

  Future<void> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;
    _isLoading = false;
    notifyListeners(); // Update UI
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);

    _user = _user.copyWith(name: '', isLoggedIn: false);
    notifyListeners(); // Update UI
  }

  Future<void> toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);

    _isDarkMode = value;
    notifyListeners(); // Update UI
  }
}
