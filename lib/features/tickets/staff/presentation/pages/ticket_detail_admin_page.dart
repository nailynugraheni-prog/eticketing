import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_ticket_provider.dart';

class TicketDetailAdminPage extends StatelessWidget {
  final String ticketId;

  const TicketDetailAdminPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    final ticket = context.watch<StaffTicketProvider>().getTicket(ticketId);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(ticket.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('ID: ${ticket.id}'),
          Text('User: ${ticket.userName}'),
          Text('Prioritas: ${ticket.priority}'),
          Text('Status: ${ticket.status}'),
          const SizedBox(height: 16),
          const Text('Riwayat Aksi', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (ticket.actions.isEmpty)
            const Text('Belum ada aksi')
          else
            ...ticket.actions.map((e) => ListTile(
              dense: true,
              leading: const Icon(Icons.history),
              title: Text(e),
            )),
        ],
      ),
    );
  }
}