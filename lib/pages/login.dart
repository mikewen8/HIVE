import 'package:flutter/material.dart';
import 'package:hive/pages/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRegistering = false;
  String message = '';
  String accessToken = '';

  final String apiBase = 'http://127.0.0.1:5000'; // Flask backend URL

  Future<void> authenticate(String endpoint) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        message = 'Username and password are required';
      });
      return;
    }

    final url = Uri.parse('$apiBase/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        setState(() {
          message = responseData['message'];
          if (endpoint == 'login') {
            accessToken = responseData['access_token'];
          }
        });

        if (endpoint == 'login') {
          // Corrected navigation logic
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          message = responseData['error'] ?? 'An error occurred';
        });
      }
    } catch (error) {
      setState(() {
        message = 'Failed to connect to the server';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isRegistering ? 'Register' : 'Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  authenticate(isRegistering ? 'register' : 'login'),
              child: Text(isRegistering ? 'Register' : 'Login'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isRegistering = !isRegistering;
                  message = '';
                });
              },
              child: Text(isRegistering
                  ? 'Already have an account? Login'
                  : 'Don’t have an account? Register'),
            ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  message,
                  style: TextStyle(
                    color: message.startsWith('Failed') ||
                            message.startsWith('Invalid')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
