import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _usernameCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await context.read<AuthProvider>().resetPassword(_usernameCtrl.text.trim());
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link reset password dikirim (dummy)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _submit,
              child: const Text('Kirim Reset'),
            ),
          ],
        ),
      ),
    );
  }
}