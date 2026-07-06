import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/notifications/user/presentation/providers/notification_provider.dart';
import 'features/notifications/staff/presentation/providers/staff_notification_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/tickets/user/presentation/providers/user_ticket_provider.dart';
import 'features/tickets/staff/presentation/providers/staff_ticket_provider.dart';
import 'features/dashboard/user/providers/user_dashboard_provider.dart';
import 'features/dashboard/staff/providers/staff_dashboard_provider.dart';
import 'features/user_management/presentation/providers/user_management_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jfjjrushomlsoiequzar.supabase.co',
    anonKey: 'sb_publishable_TUA17LnP6o7SMLZZyANZJg_DVyPk9i3',
  );

  runApp(const ETicketingApp());
}

class ETicketingApp extends StatelessWidget {
  const ETicketingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => StaffNotificationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserTicketProvider()),
        ChangeNotifierProvider(create: (_) => StaffTicketProvider()),
        ChangeNotifierProvider(create: (_) => UserDashboardProvider()),
        ChangeNotifierProvider(create: (_) => StaffDashboardProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MyApp(
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
          );
        },
      ),
    );
  }
}