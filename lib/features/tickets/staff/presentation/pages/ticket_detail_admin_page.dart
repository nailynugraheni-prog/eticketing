import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/admin_ticket_model.dart';
import '../providers/staff_ticket_provider.dart';

class TicketDetailAdminPage extends StatefulWidget {
  final String ticketId;

  const TicketDetailAdminPage({super.key, required this.ticketId});

  @override
  State<TicketDetailAdminPage> createState() => _TicketDetailAdminPageState();
}

class _TicketDetailAdminPageState extends State<TicketDetailAdminPage> {
  final _responseCtrl = TextEditingController();
  String _selectedStatus = 'open';
  late Future<AdminTicketModel?> _ticketFuture;
  bool _isSubmitting = false;

  final _statusOptions = ['open', 'in_progress', 'resolved', 'closed'];

  @override
  void initState() {
    super.initState();
    _ticketFuture = context.read<StaffTicketProvider>().getTicket(widget.ticketId);
  }

  @override
  void dispose() {
    _responseCtrl.dispose();
    super.dispose();
  }

  void _openFullscreen(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                url,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendResponse() async {
    final text = _responseCtrl.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<StaffTicketProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final role = context.read<AuthProvider>().role;

    setState(() => _isSubmitting = true);

    try {
      await provider.addResponse(widget.ticketId, text, role: role);
      await provider.updateStatus(widget.ticketId, _selectedStatus, role: role);

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Respon & status berhasil disimpan'),
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
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: FutureBuilder<AdminTicketModel?>(
        future: _ticketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final ticket = snapshot.data;
          if (ticket == null) {
            return const Center(child: Text('Tiket tidak ditemukan'));
          }

          if (!_statusOptions.contains(_selectedStatus)) {
            _selectedStatus = 'open';
          }

          // Urutan section di bawah ini SENGAJA dibuat identik dengan
          // TicketDetailPage (user): Judul -> info dasar -> Deskripsi ->
          // Lampiran -> Timeline berlabel -> Riwayat Status -> form update.
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(ticket.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('ID: ${ticket.id}'),
              Text('User: ${ticket.userName}'),
              Text('Prioritas: ${ticket.priority}'),
              Text('Status: ${ticket.status}'),
              Text('Dibuat: ${ticket.createdAt}'),
              const SizedBox(height: 16),
              const Text('Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(ticket.description),

              if (ticket.attachmentUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Lampiran (${ticket.attachmentUrls.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ticket.attachmentUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final url = ticket.attachmentUrls[index];
                      return GestureDetector(
                        onTap: () => _openFullscreen(context, url),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Text('Timeline',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (ticket.timeline.isEmpty)
                const Text('Belum ada aktivitas')
              else
                ...ticket.timeline.map((e) => ListTile(
                  dense: true,
                  leading: Icon(
                    e.isMine ? Icons.person_outline : Icons.support_agent,
                    color: e.isMine ? Colors.blue : Colors.green,
                  ),
                  title: Text(
                    e.authorLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  subtitle: Text(e.message),
                )),

              const SizedBox(height: 16),
              const Text('Riwayat Status',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (ticket.statusHistory.isEmpty)
                const Text('Belum ada perubahan status')
              else
                ...ticket.statusHistory.map((e) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.sync_alt, color: Colors.orange),
                  title: Text(e),
                )),

              const Divider(height: 32),
              DropdownButtonFormField<String>(
                initialValue: _statusOptions.contains(ticket.status) ? ticket.status : 'open',
                items: _statusOptions
                    .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.replaceAll('_', ' ').toUpperCase()),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStatus = v ?? 'open'),
                decoration: const InputDecoration(
                  labelText: 'Update status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _responseCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Balasan / response',
                  hintText: 'Tulis balasan...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _sendResponse,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Kirim balasan'),
              ),
            ],
          );
        },
      ),
    );
  }
}