import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/routes/route_names.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _goNext);
  }

  void _goNext() {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      if (auth.role == 'user') {
        Navigator.pushReplacementNamed(context, RouteNames.userDashboard);
      } else {
        Navigator.pushReplacementNamed(context, RouteNames.staffDashboard);
      }
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number_outlined, size: 72),
            SizedBox(height: 16),
            Text(
              'E-Ticketing Helpdesk',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Frontend Flutter'),
          ],
        ),
      ),
    );
  }
}