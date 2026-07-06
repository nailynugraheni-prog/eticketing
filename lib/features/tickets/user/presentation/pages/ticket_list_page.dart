import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_ticket_provider.dart';
import 'ticket_detail_page.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<UserTicketProvider>().loadMyTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserTicketProvider>();
    final tickets = provider.tickets;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tiket')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
          ? const Center(child: Text('Belum ada tiket'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            child: ListTile(
              title: Text(ticket.title),
              subtitle: Text('${ticket.id} • ${ticket.status}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TicketDetailPage(ticketId: ticket.id),
                  ),
                ).then((_) {
                  if (mounted) {
                    context.read<UserTicketProvider>().loadMyTickets();
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}