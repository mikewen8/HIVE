// fetch commands for the login page

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      "http://127.0.0.1:5000/api"; // Change this to your backend's URL

  Future<String> signup(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return "Signup successful!";
    } else {
      final error = jsonDecode(response.body)['error'] ?? "Error occurred!";
      return "Signup failed: $error";
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Contains message and user data
    } else {
      final error = jsonDecode(response.body)['error'] ?? "Error occurred!";
      throw Exception("Login failed: $error");
    }
  }
}
