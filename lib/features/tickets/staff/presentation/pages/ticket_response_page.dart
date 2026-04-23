import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_ticket_provider.dart';

class TicketResponsePage extends StatefulWidget {
  const TicketResponsePage({super.key});

  @override
  State<TicketResponsePage> createState() => _TicketResponsePageState();
}

class _TicketResponsePageState extends State<TicketResponsePage> {
  final _ticketIdCtrl = TextEditingController(text: 'TCK-001');
  final _responseCtrl = TextEditingController();

  @override
  void dispose() {
    _ticketIdCtrl.dispose();
    _responseCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<StaffTicketProvider>().addResponse(
      _ticketIdCtrl.text.trim(),
      _responseCtrl.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Response terkirim (dummy)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Respon Tiket')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _ticketIdCtrl,
            decoration: const InputDecoration(
              labelText: 'Ticket ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _responseCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Pesan respon',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Kirim Respon'),
          ),
        ],
      ),
    );
  }
}