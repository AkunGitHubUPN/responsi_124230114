import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  String? _photoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _photoPath = widget.user.photoPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoPath = pickedFile.path;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final updatedUser = User(
        username: widget.user.username,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        photoPath: _photoPath,
      );
      await ProfileService.saveUserProfile(updatedUser);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.of(context).pop(true); // Return true to indicate update
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
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
                    backgroundImage: _photoPath != null ? FileImage(File(_photoPath!)) : null,
                    child: _photoPath == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtrl,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(236, 184, 245, 1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
