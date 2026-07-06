import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_ticket_provider.dart';
import 'ticket_tracking_detail_page.dart';

/// List ringkas semua tiket milik user. Tap salah satu untuk membuka
/// riwayat status lengkap + kolom komentar (TicketTrackingDetailPage).
class TicketTrackingPage extends StatefulWidget {
  const TicketTrackingPage({super.key});

  @override
  State<TicketTrackingPage> createState() => _TicketTrackingPageState();
}

class _TicketTrackingPageState extends State<TicketTrackingPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<UserTicketProvider>().loadMyTickets();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.blue;
      case 'in_progress': return Colors.orange;
      case 'resolved': return Colors.green;
      case 'closed': return Colors.grey;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserTicketProvider>();
    final tickets = provider.tickets;

    return Scaffold(
      appBar: AppBar(title: const Text('Tracking Tiket')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
          ? const Center(child: Text('Belum ada tiket'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            child: ListTile(
              title: Text(ticket.title),
              subtitle: Text('${ticket.id} • ${ticket.createdAt}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(ticket.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _statusColor(ticket.status)),
                ),
                child: Text(
                  ticket.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: _statusColor(ticket.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketTrackingDetailPage(ticketId: ticket.id),
                  ),
                );

                if (!mounted) return;
                context.read<UserTicketProvider>().loadMyTickets();
              },
            ),
          );
        },
      ),
    );
  }
}