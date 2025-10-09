import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseurl = "https://lstatsbackend-production.up.railway.app";

  // Login returns only JWT now
  static Future<String> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseurl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      print("Status: ${res.statusCode}, Body: ${res.body}"); 

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final body = jsonDecode(res.body);
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString("jwt", body["token"]);

        return body["token"]; 
      } else {
        throw Exception(
            "Login failed. Status: ${res.statusCode}, Body: ${res.body}");
      }
    } catch (e) {
      throw Exception("Login error: $e");
    }
  }
  static Future<void> register(
      String username, String email, String password,String collegename) async {
    final response = await http.post(
      Uri.parse("$baseurl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"username": username, "email": email, "password": password,"collegename":collegename}),
    );

    if (response.statusCode != 200) {
      throw Exception("Registration failed: ${response.body}");
    }
  }

 

  }

