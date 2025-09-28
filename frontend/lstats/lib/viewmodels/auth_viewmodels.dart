import 'package:flutter/material.dart';
import 'package:lstats/services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? token; // JWT is a String, not int

  Future<void> login(String username, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      // ApiService.login now returns only token
      token = await ApiService.login(username, password);
    } catch (e) {
      throw Exception("Login error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
Future<void> register(String username, String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      await ApiService.register(username, email, password);
      // Optional: you can automatically log in after register
      // await login(username, password);
    } catch (e) {
      throw Exception("Registration error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}

