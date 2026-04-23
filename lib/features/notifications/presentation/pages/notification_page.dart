import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: Icon(
                item.isRead ? Icons.notifications_none : Icons.notifications_active,
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text('${item.message}\n${item.time}'),
              isThreeLine: true,
              trailing: item.isRead
                  ? const Icon(Icons.done_all)
                  : const Icon(Icons.circle, size: 12),
              onTap: () {
                context.read<NotificationProvider>().markAsRead(item.id);
              },
            ),
          );
        },
      ),
    );
  }
}