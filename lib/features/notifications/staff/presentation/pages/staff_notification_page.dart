import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_notification_provider.dart';
import '../../../../tickets/staff/presentation/pages/ticket_detail_admin_page.dart';

class StaffNotificationPage extends StatefulWidget {
  const StaffNotificationPage({super.key});

  @override
  State<StaffNotificationPage> createState() => _StaffNotificationPageState();
}

class _StaffNotificationPageState extends State<StaffNotificationPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<StaffNotificationProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffNotificationProvider>();
    final items = provider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi (${provider.unreadCount})'),
        actions: [
          TextButton(
            onPressed: provider.unreadCount == 0 ? null : provider.markAllAsRead,
            child: const Text('Tandai semua'),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text('Belum ada notifikasi'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: Icon(
                item.isRead
                    ? Icons.notifications_none
                    : Icons.notifications_active,
                color: item.isRead ? Colors.grey : Colors.blue,
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
              subtitle: Text('${item.message}\n${item.time}'),
              isThreeLine: true,
              trailing: item.isRead
                  ? const Icon(Icons.done_all, color: Colors.grey)
                  : const Icon(Icons.circle, size: 12, color: Colors.blue),
              onTap: () {
                context.read<StaffNotificationProvider>().markAsRead(item.id);

                if (item.ticketId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tiket terkait tidak ditemukan')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketDetailAdminPage(ticketId: item.ticketId!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}