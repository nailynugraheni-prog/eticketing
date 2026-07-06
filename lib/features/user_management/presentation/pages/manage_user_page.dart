import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_management_provider.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final _roleOptions = ['user', 'helpdesk', 'admin'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<UserManagementProvider>().loadUsers();
    });
  }

  Future<void> _showEditRoleDialog(Map<String, dynamic> user) async {
    String selectedRole = user['role'] ?? 'user';
    final provider = context.read<UserManagementProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Ubah role: ${user['full_name']}'),
          content: DropdownButtonFormField<String>(
            initialValue: selectedRole,
            items: _roleOptions
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setDialogState(() => selectedRole = v ?? 'user'),
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    await provider.updateRole(user['id'], selectedRole);

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Role berhasil diubah')),
    );
  }

  Future<void> _confirmToggleActive(Map<String, dynamic> user) async {
    final isCurrentlyActive = user['is_active'] as bool? ?? true;
    final provider = context.read<UserManagementProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isCurrentlyActive ? 'Non-aktifkan akun?' : 'Aktifkan akun?'),
        content: Text(
          isCurrentlyActive
              ? '${user['full_name']} tidak akan bisa login setelah dinonaktifkan.'
              : '${user['full_name']} akan bisa login kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, lanjutkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await provider.toggleActive(user['id'], !isCurrentlyActive);

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(isCurrentlyActive ? 'Akun dinonaktifkan' : 'Akun diaktifkan')),
    );
  }

  Future<void> _sendPasswordReset(Map<String, dynamic> user) async {
    final email = user['email'] as String?;
    final messenger = ScaffoldMessenger.of(context);

    if (email == null || email.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('User ini tidak punya email terdaftar')),
      );
      return;
    }

    final provider = context.read<UserManagementProvider>();
    await provider.sendPasswordReset(email);

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Email reset password terkirim ke $email')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();
    final users = provider.users;

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Pengguna')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('Belum ada pengguna'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = users[index];
          final isActive = user['is_active'] as bool? ?? true;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user['full_name'] ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('@${user['username'] ?? '-'}'),
                  Text(user['email'] ?? '-'),
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${user['role'] ?? 'user'}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showEditRoleDialog(user),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Ubah role'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _sendPasswordReset(user),
                        icon: const Icon(Icons.lock_reset, size: 16),
                        label: const Text('Reset password'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _confirmToggleActive(user),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isActive ? Colors.red : Colors.green,
                        ),
                        icon: Icon(
                          isActive ? Icons.block : Icons.check_circle_outline,
                          size: 16,
                        ),
                        label: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}