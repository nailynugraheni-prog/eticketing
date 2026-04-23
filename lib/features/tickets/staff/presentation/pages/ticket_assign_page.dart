import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_ticket_provider.dart';

class TicketAssignPage extends StatefulWidget {
  const TicketAssignPage({super.key});

  @override
  State<TicketAssignPage> createState() => _TicketAssignPageState();
}

class _TicketAssignPageState extends State<TicketAssignPage> {
  final _ticketIdCtrl = TextEditingController(text: 'TCK-001');
  final _assigneeCtrl = TextEditingController(text: 'Petugas 1');

  @override
  void dispose() {
    _ticketIdCtrl.dispose();
    _assigneeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<StaffTicketProvider>().assignTicket(
      _ticketIdCtrl.text.trim(),
      _assigneeCtrl.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tiket berhasil di-assign (dummy)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Tiket')),
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
            controller: _assigneeCtrl,
            decoration: const InputDecoration(
              labelText: 'Nama Petugas',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}