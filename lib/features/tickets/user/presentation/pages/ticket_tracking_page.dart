import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_ticket_provider.dart';

class TicketTrackingPage extends StatelessWidget {
  const TicketTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = context.watch<UserTicketProvider>().tickets;

    return Scaffold(
      appBar: AppBar(title: const Text('Tracking Tiket')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            child: ListTile(
              title: Text(ticket.title),
              subtitle: Text('${ticket.id} • ${ticket.status}'),
              trailing: const Icon(Icons.track_changes),
            ),
          );
        },
      ),
    );
  }
}