import 'package:flutter/material.dart';
import '../services/user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    try {
      await UserService.registerUser(username, password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Register successful')));
      Navigator.of(context).pop(); // go back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter username' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: const Text('Register'))
            ],
          ),
        ),
      ),
    );
  }
}
