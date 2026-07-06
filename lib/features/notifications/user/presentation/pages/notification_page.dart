import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../../../../tickets/user/presentation/pages/ticket_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<NotificationProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
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
                context.read<NotificationProvider>().markAsRead(item.id);

                if (item.ticketId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tiket terkait tidak ditemukan')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketDetailPage(ticketId: item.ticketId!),
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