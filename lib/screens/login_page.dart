import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final username = _userController.text.trim();
    final password = _passController.text;
    final ok = await UserService.validate(username, password);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      return;
    }
    await StorageService.saveUsername(username);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage(username: username)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Icon(Icons.rocket_launch, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 12),
              Text('Welcome to My Spaceflight', style: theme.textTheme.titleMedium?.copyWith(fontSize: 18)),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 10)],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline),
                          hintText: 'Username',
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: 'Password',
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple.shade100, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                          child: Text('Login', style: TextStyle(color: Colors.deepPurple.shade800)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: Text('Belum punya akun? Register', style: TextStyle(color: Colors.deepPurple.shade400)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
