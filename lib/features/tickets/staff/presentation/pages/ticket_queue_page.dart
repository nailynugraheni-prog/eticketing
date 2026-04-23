import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_ticket_provider.dart';
import 'ticket_detail_admin_page.dart';

class TicketQueuePage extends StatelessWidget {
  const TicketQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = context.watch<StaffTicketProvider>().tickets;

    return Scaffold(
      appBar: AppBar(title: const Text('Antrian Tiket')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            child: ListTile(
              title: Text(ticket.title),
              subtitle: Text('${ticket.id} • ${ticket.userName} • ${ticket.status}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketDetailAdminPage(ticketId: ticket.id),
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