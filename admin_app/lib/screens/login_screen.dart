import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();
  static const _defaultPin = '1234';

  Future<void> _login() async {
    final pin = _pinController.text.trim();
    if (pin == _defaultPin) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('admin_logged_in', true);
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const Text('Enter Admin PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _pinController, decoration: const InputDecoration(labelText: 'PIN'), keyboardType: TextInputType.number, obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _login, child: const Text('Login')),
        ]),
      ),
    );
  }
}
