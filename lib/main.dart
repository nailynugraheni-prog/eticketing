import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/tickets/user/presentation/providers/user_ticket_provider.dart';
import 'features/tickets/staff/presentation/providers/staff_ticket_provider.dart';

// TAMBAHKAN IMPORT INI (Sesuaikan path foldernya kalau beda dikit)
import 'features/dashboard/user/providers/user_dashboard_provider.dart';
import 'features/dashboard/staff/providers/staff_dashboard_provider.dart';

void main() {
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
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserTicketProvider()),
        ChangeNotifierProvider(create: (_) => StaffTicketProvider()),

        // TAMBAHKAN DUA BARIS INI
        ChangeNotifierProvider(create: (_) => UserDashboardProvider()),
        ChangeNotifierProvider(create: (_) => StaffDashboardProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MyApp(
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}
