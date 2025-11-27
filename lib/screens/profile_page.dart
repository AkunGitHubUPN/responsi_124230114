import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/profile_service.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    _userFuture = ProfileService.getOrCreateProfile(widget.username);
  }

  Future<void> _logout(BuildContext context) async {
    await StorageService.clearUsername();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _editProfile(User user) async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EditProfilePage(user: user),
    ));
    if (result == true) {
      setState(() {
        _loadUser();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: user.photoPath != null ? FileImage(File(user.photoPath!)) : null,
                        child: user.photoPath == null
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _editProfile(user),
                    icon: Icon(Icons.edit, size: 16, color: Colors.purple.shade400),
                    label: Text('Edit Profil', style: TextStyle(color: Colors.purple.shade400, fontSize: 12)),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'Nama',
                    value: user.name,
                  ),
                  const SizedBox(height: 12),
                  if (user.email != null && user.email!.isNotEmpty)
                    Column(
                      children: [
                        _buildInfoCard(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email!,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (user.phone != null && user.phone!.isNotEmpty)
                    Column(
                      children: [
                        _buildInfoCard(
                          icon: Icons.phone_outlined,
                          label: 'Nomor Telepon',
                          value: user.phone!,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  _buildInfoCard(
                    icon: Icons.alternate_email,
                    label: 'Username',
                    value: user.username,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 102, 102),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(fontSize: 16, color: Colors.white),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.purple.shade400),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
