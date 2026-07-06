import 'package:flutter/material.dart';
import '../features/dashboard/user/pages/user_dashboard_page.dart';
import '../features/dashboard/staff/pages/staff_dashboard_page.dart';
import '../features/tickets/user/presentation/pages/ticket_list_page.dart';
import '../features/tickets/staff/presentation/pages/ticket_queue_page.dart';
import '../features/notifications/user/presentation/pages/notification_page.dart';
import '../features/notifications/staff/presentation/pages/staff_notification_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

class AppShell extends StatefulWidget {
  final String role;

  const AppShell({
    super.key,
    required this.role,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.role == 'user';

    final pages = isUser
        ? const [
      UserDashboardPage(),
      TicketListPage(),
      NotificationPage(),
      ProfilePage(),
    ]
        : const [
      StaffDashboardPage(),
      TicketQueuePage(),
      StaffNotificationPage(),
      ProfilePage(),
    ];

    final items = isUser
        ? const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.confirmation_number),
        label: 'Tiket',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications),
        label: 'Notif',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ]
        : const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.inbox),
        label: 'Queue',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications),
        label: 'Notif',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: items,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}