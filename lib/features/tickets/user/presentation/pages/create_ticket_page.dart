import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_ticket_provider.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'Application';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<UserTicketProvider>().createTicket(
      title: _titleCtrl.text.trim(),
      category: _category,
      description: _descCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tiket berhasil dibuat (dummy)')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tiket')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Judul Tiket',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            items: const [
              DropdownMenuItem(value: 'Application', child: Text('Application')),
              DropdownMenuItem(value: 'Network', child: Text('Network')),
              DropdownMenuItem(value: 'Hardware', child: Text('Hardware')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _category = v ?? 'Application'),
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Kirim Tiket'),
          ),
        ],
      ),
    );
  }
}