import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/route_names.dart';
import '../../data/models/register_request_model.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    await auth.register(
      RegisterRequestModel(
        name: _nameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        role: 'user',
      ),
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.userDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _submit,
              child: auth.isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}