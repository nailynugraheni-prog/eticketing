import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_ticket_provider.dart';

class TicketDetailPage extends StatefulWidget {
  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    context.read<UserTicketProvider>().addComment(widget.ticketId, text);
    _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserTicketProvider>();
    final detail = provider.getDetail(widget.ticketId);
    final ticket = provider.tickets.firstWhere((e) => e.id == widget.ticketId);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(ticket.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('ID: ${ticket.id}'),
          Text('Kategori: ${ticket.category}'),
          Text('Status: ${ticket.status}'),
          const SizedBox(height: 16),
          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(ticket.description),
          const SizedBox(height: 16),
          const Text('Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
          ...detail.timeline.map((e) => ListTile(
            dense: true,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(e),
          )),
          const SizedBox(height: 16),
          const Text('Komentar', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...ticket.comments.map(
                (e) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(e),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentCtrl,
            decoration: const InputDecoration(
              labelText: 'Tambah komentar',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _sendComment,
            child: const Text('Kirim Komentar'),
          ),
        ],
      ),
    );
  }
}