import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/auth";

  // Signup API Call
  Future<Map<String, dynamic>?> signup(String firstName, String lastName,
      String email, String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone_no": phone,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {"error": json.decode(response.body)["detail"]};
    }
  }

  // Login API Call
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {"error": json.decode(response.body)["detail"]};
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("❌ Error getting current user: ${response.body}");
      return null;
    }
  }
}
