import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'gamelist.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final String baseUrl = 'http://165.227.117.48';

  Future<void> registerUser(BuildContext context) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Registration successful: ${data['message']}');
      print('Access Token: ${data['access_token']}');
      saveTokenLocally(data['access_token']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User registered successfully'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameList(
            username: usernameController.text,
            accessToken: data['access_token'],
          ),
        ),
      );
    } else if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      print('Registration failed. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (data['message'] == 'User already exists') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User already exists'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User already exists'),
          ),
        );
      }
    } else {
      print('Registration failed. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  Future<void> loginUser(BuildContext context) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Login successful: ${data['message']}');
      print('Access Token: ${data['access_token']}');
      saveTokenLocally(data['access_token']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged in successfully'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameList(
            username: usernameController.text,
            accessToken: data['access_token'],
          ),
        ),
      );
    } else if (response.statusCode == 401) {
      print('Login failed. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password'),
        ),
      );
    } else {
      print('Login failed. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  void saveTokenLocally(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sessionToken', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Adjust the width breakpoint as needed
              bool isWideScreen = constraints.maxWidth > 600;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  isWideScreen
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                loginUser(context);
                              },
                              child: const Text('Login'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                registerUser(context);
                              },
                              child: const Text('Register'),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                loginUser(context);
                              },
                              child: const Text('Login'),
                            ),
                            const SizedBox(height: 8.0),
                            ElevatedButton(
                              onPressed: () {
                                registerUser(context);
                              },
                              child: const Text('Register'),
                            ),
                          ],
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
