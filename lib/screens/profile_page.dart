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
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final user = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Profile Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [BoxShadow(color: Colors.deepOrange.withOpacity(0.1), blurRadius: 15, spreadRadius: 2)],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.deepOrange, width: 4),
                              boxShadow: [BoxShadow(color: Colors.deepOrange.withOpacity(0.3), blurRadius: 15, spreadRadius: 5)],
                            ),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: user.photoPath != null ? FileImage(File(user.photoPath!)) : null,
                              child: user.photoPath == null
                                  ? const Icon(Icons.person, size: 65, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _editProfile(user),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.edit, size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(user.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      const SizedBox(height: 4),
                      Text('@${user.username}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Info Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        icon: Icons.person_outline,
                        label: 'Nama Lengkap',
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
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade500,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.deepOrange.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.deepOrange.withOpacity(0.08), blurRadius: 8, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: Colors.deepOrange),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}
