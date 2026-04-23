import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_ticket_provider.dart';

class TicketStatusUpdatePage extends StatefulWidget {
  const TicketStatusUpdatePage({super.key});

  @override
  State<TicketStatusUpdatePage> createState() => _TicketStatusUpdatePageState();
}

class _TicketStatusUpdatePageState extends State<TicketStatusUpdatePage> {
  final _ticketIdCtrl = TextEditingController(text: 'TCK-001');
  String _status = 'In Progress';

  @override
  void dispose() {
    _ticketIdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<StaffTicketProvider>().updateStatus(
      _ticketIdCtrl.text.trim(),
      _status,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status berhasil diubah (dummy)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Status Tiket')),
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
          DropdownButtonFormField<String>(
            value: _status,
            items: const [
              DropdownMenuItem(value: 'Open', child: Text('Open')),
              DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
              DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
              DropdownMenuItem(value: 'Closed', child: Text('Closed')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'In Progress'),
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Update Status'),
          ),
        ],
      ),
    );
  }
}