import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../app/app_shell.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/tickets/user/presentation/pages/create_ticket_page.dart';
import '../../features/tickets/user/presentation/pages/ticket_list_page.dart';
import '../../features/tickets/user/presentation/pages/ticket_tracking_page.dart';
import '../../features/tickets/staff/presentation/pages/ticket_queue_page.dart';
import '../../features/tickets/staff/presentation/pages/ticket_detail_admin_page.dart';
import '../../features/tickets/staff/presentation/pages/ticket_assign_page.dart';
import '../../features/notifications/user/presentation/pages/notification_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/user_management/presentation/pages/manage_user_page.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case RouteNames.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordPage());

    // RUTE DASHBOARD (Tadi yang kurang ini)
      case RouteNames.userDashboard:
        return MaterialPageRoute(builder: (_) => const AppShell(role: 'user'));
      case RouteNames.staffDashboard:
        return MaterialPageRoute(builder: (_) => const AppShell(role: 'staff'));

      case RouteNames.ticketCreate:
        return MaterialPageRoute(builder: (_) => const CreateTicketPage());
      case RouteNames.ticketList:
        return MaterialPageRoute(builder: (_) => const TicketListPage());
      case RouteNames.ticketTracking:
        return MaterialPageRoute(builder: (_) => const TicketTrackingPage());
      case RouteNames.ticketQueue:
        return MaterialPageRoute(builder: (_) => const TicketQueuePage());
      case RouteNames.ticketDetailAdmin:
        return MaterialPageRoute(builder: (_) => const TicketDetailAdminPage(ticketId: 'TCK-001'));
      case RouteNames.ticketAssign:
        return MaterialPageRoute(builder: (_) => const TicketAssignPage());
      case RouteNames.manageUser:
        return MaterialPageRoute(builder: (_) => const ManageUserPage());
      case RouteNames.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}