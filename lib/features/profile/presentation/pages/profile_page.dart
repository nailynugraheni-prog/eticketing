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
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // FIX: sebelumnya pakai flag bool `_controllersInitialized` yang cuma
  // dicek "sudah pernah sync atau belum". Kalau ProfilePage tidak pernah
  // benar-benar di-dispose antar sesi login (misal karena hidup di dalam
  // IndexedStack milik AppShell), flag ini tetap `true` dari sesi
  // sebelumnya, dan controller TIDAK PERNAH disinkron ulang dengan profile
  // baru -- text field tetap menampilkan nama/email akun yang login
  // SEBELUMNYA, meski ProfileProvider.profile di baliknya sudah benar.
  //
  // Sekarang disimpan USERNAME dari profile yang terakhir di-sync. Setiap
  // build, dibandingkan dengan username profile saat ini -- kalau beda
  // (ganti akun) atau belum pernah sync, baru controller diisi ulang.
  String? _syncedUsername;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      await context.read<ProfileProvider>().loadProfile();
      // setState kosong untuk memicu rebuild -> _maybeSyncControllers
      // di build() akan jalan dengan data profile yang baru saja di-load
      if (mounted) setState(() {});
    });
  }

  /// Sinkronkan controller HANYA kalau profile yang aktif sekarang beda
  /// dari yang terakhir kali disinkronkan (dideteksi lewat username, yang
  /// unik per akun). Ini juga otomatis menangani kasus profile jadi null
  /// (misal clearProfile() saat logout) -- _syncedUsername ikut direset.
  void _maybeSyncControllers(profile) {
    if (profile == null) {
      _syncedUsername = null;
      return;
    }
    if (_syncedUsername == profile.username) return;

    _nameCtrl.text = profile.name;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.phone;
    _syncedUsername = profile.username;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    final provider = context.read<ProfileProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await provider.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    if (!mounted) return;

    messenger.showSnackBar(
      const SnackBar(content: Text('Profil berhasil disimpan ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final themeProvider = context.watch<ThemeProvider>();

    _maybeSyncControllers(profile);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileProvider.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              child: Text(
                (profile?.name.isNotEmpty ?? false)
                    ? profile!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (profile != null)
            Center(
              child: Text(
                profile.role.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          const SizedBox(height: 20),
          if (profileProvider.isLoading)
            const LinearProgressIndicator(),
          const SizedBox(height: 12),
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
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
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
            onChanged: themeProvider.toggleTheme,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: profileProvider.isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: const Text('Simpan Profil'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final authProvider = context.read<AuthProvider>();
              final profileProv = context.read<ProfileProvider>();

              await authProvider.logout();
              profileProv.clearProfile();

              if (!mounted) return;
              navigator.pushNamedAndRemoveUntil(
                '/login',
                    (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}