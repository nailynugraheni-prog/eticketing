import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_ticket_provider.dart';

class TicketAssignPage extends StatefulWidget {
  const TicketAssignPage({super.key});

  @override
  State<TicketAssignPage> createState() => _TicketAssignPageState();
}

class _TicketAssignPageState extends State<TicketAssignPage> {
  String? _selectedTicketId;
  String? _selectedAssigneeId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final role = context.read<AuthProvider>().role;
        context.read<StaffTicketProvider>().loadAllTickets(role: role);
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedTicketId == null || _selectedAssigneeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tiket dan petugas dulu')),
      );
      return;
    }

    final provider = context.read<StaffTicketProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final role = context.read<AuthProvider>().role;

    setState(() => _isSubmitting = true);

    try {
      await provider.assignTicket(
        _selectedTicketId!,
        _selectedAssigneeId!,
        role: role,
      );

      if (!mounted) return;

      setState(() {
        _selectedTicketId = null;
        _selectedAssigneeId = null;
        _isSubmitting = false;
      });

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tiket berhasil di-assign'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      navigator.popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal assign: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffTicketProvider>();
    final tickets = provider.tickets;
    final helpdesks = provider.helpdeskList;

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Tiket')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : helpdesks.isEmpty
          ? const Center(child: Text('Belum ada helpdesk terdaftar'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedTicketId,
            hint: const Text('Pilih nomor tiket'),
            isExpanded: true,
            items: tickets.map((t) {
              return DropdownMenuItem(
                value: t.id,
                child: Text(
                  '${t.id} - ${t.title}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedTicketId = v),
            decoration: const InputDecoration(
              labelText: 'Nomor tiket',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedAssigneeId,
            hint: const Text('Pilih petugas'),
            isExpanded: true,
            items: helpdesks.map((h) {
              return DropdownMenuItem(
                value: h['id'] as String?,
                child: Text(
                  (h['full_name'] ?? h['username'] ?? '-').toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedAssigneeId = v),
            decoration: const InputDecoration(
              labelText: 'Petugas (helpdesk)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: _isSubmitting
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text('Assign tiket'),
          ),
        ],
      ),
    );
  }
}