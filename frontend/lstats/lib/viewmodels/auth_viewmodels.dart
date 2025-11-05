import 'package:flutter/material.dart';
import 'package:lstats/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? token; // JWT
  String? username; // 👈 store username locally for UI use

  // ✅ LOGIN
  Future<void> login(String username, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      // ApiService already saves everything to SharedPreferences
      token = await ApiService.login(username, password);

      // Fetch username from SharedPreferences (saved by ApiService)
      final prefs = await SharedPreferences.getInstance();
      this.username = prefs.getString("username");

    } catch (e) {
      token = null;
      this.username = null;
      throw Exception("Login error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ REGISTER
  Future<void> register(
    String username,
    String email,
    String password,
    String clgname,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await ApiService.register(username, email, password, clgname);
      this.username = username; // optional (before first login)
    } catch (e) {
      token = null;
      this.username = null;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ LOAD USER (for splash screen startup)
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("jwt");
    username = prefs.getString("username");
    notifyListeners();
  }

  // ✅ LOGOUT (clears both token & username)
  Future<void> logout() async {
    await AuthStorage.logout(); // since ApiService provides this
    token = null;
    username = null;
    notifyListeners();
  }
}
