import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameCtrl = TextEditingController(text: profile.name);
    _emailCtrl = TextEditingController(text: profile.email);
    _phoneCtrl = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    context.read<ProfileProvider>().updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil disimpan (dummy)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              child: Text(
                profile.name.isNotEmpty
                    ? profile.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(
              labelText: 'No. HP',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _saveProfile,
            child: const Text('Simpan Profil'),
          ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}