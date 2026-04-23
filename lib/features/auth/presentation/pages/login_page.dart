import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/route_names.dart';
import '../../data/models/login_request_model.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'user';

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    await auth.login(
      LoginRequestModel(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        role: _role,
      ),
    );

    if (!mounted) return;

    if (_role == 'user') {
      Navigator.pushReplacementNamed(context, RouteNames.userDashboard);
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.staffDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Masuk ke aplikasi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(
                labelText: 'Login sebagai',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'user', child: Text('User')),
                DropdownMenuItem(value: 'staff', child: Text('Admin / Helpdesk')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _role = value);
                }
              },
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
                  : const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.register);
              },
              child: const Text('Belum punya akun? Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.resetPassword);
              },
              child: const Text('Lupa password?'),
            ),
          ],
        ),
      ),
    );
  }
}