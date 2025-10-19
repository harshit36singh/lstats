import 'package:flutter/material.dart';
import 'package:lstats/services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? token; // JWT is a String, not int

  Future<void> login(String username, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      token = await ApiService.login(username, password);
    } catch (e) {
      token=null;
      throw Exception("Login error");
    }
finally
{    isLoading = false;
    notifyListeners();}
  }

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
     
    } catch (e) {
      token = null;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
