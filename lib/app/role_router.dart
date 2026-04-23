import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/user/pages/user_dashboard_page.dart';
import '../features/dashboard/staff/pages/staff_dashboard_page.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const LoginPage();
    }

    if (auth.role == 'user') {
      return const UserDashboardPage();
    }

    return const StaffDashboardPage();
  }
}