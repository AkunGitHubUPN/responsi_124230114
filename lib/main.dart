import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('userProfiles');
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('username');
  runApp(MainApp(initialUsername: username));
}

class MainApp extends StatelessWidget {
  final String? initialUsername;
  const MainApp({super.key, this.initialUsername});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsi App',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: initialUsername == null ? const LoginPage() : HomePage(username: initialUsername!),
    );
  }
}
