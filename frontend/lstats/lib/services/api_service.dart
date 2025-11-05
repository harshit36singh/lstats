import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseurl = "https://lstats-railway-backend-production.up.railway.app";

  // Login returns only JWT now
  static Future<String> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseurl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );


      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final body = jsonDecode(res.body);
        final token = body["token"];
        final user = body["user"];
        final userId = user["id"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt", token);
        await prefs.setInt("userId", userId);
        await prefs.setString("username", user["username"]);
        await prefs.setString("email", user["email"]);
        await prefs.setString("college", user["collegename"]);

        return token; 
      } else {
        throw Exception(
            "Login failed. Status: ${res.statusCode}, Body: ${res.body}");
      }
    } catch (e) {
      throw Exception("Login error: $e");
    }
  }
  static Future<String> register(
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
    return "done";
  }
   }

class AuthStorage{

  static Future<int?> getuserid() async {
    final p=await SharedPreferences.getInstance();
    return p.getInt("userId");
  }
  static Future<String?> getToken() async{
    final p=await SharedPreferences.getInstance();
    return p.getString("jwt");

  }
  static Future<String?> getUsername() async{
    final p=await SharedPreferences.getInstance();
    return  p.getString("username");
  }

  static Future<void> logout() async{
    final p=await SharedPreferences.getInstance();
    await p.clear();
  }

}