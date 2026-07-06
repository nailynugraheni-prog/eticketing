import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/ticket_detail_model.dart';
import '../providers/user_ticket_provider.dart';

/// Halaman detail untuk Tracking Tiket. Berbeda dari TicketDetailPage
/// (view-only), di sini ada 2 bagian riwayat TERPISAH:
///   1. Riwayat Status  -- dari ticket_tracking (statusHistory)
///   2. Komentar        -- dari comments (timeline), + kolom kirim komentar
class TicketTrackingDetailPage extends StatefulWidget {
  final String ticketId;

  const TicketTrackingDetailPage({super.key, required this.ticketId});

  @override
  State<TicketTrackingDetailPage> createState() => _TicketTrackingDetailPageState();
}

class _TicketTrackingDetailPageState extends State<TicketTrackingDetailPage> {
  final _commentCtrl = TextEditingController();
  late Future<TicketDetailModel?> _detailFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = context.read<UserTicketProvider>().getDetail(widget.ticketId);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<UserTicketProvider>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSubmitting = true);

    try {
      await provider.addComment(widget.ticketId, text);

      if (!mounted) return;

      setState(() {
        _detailFuture = context.read<UserTicketProvider>().getDetail(widget.ticketId);
        _isSubmitting = false;
      });

      _commentCtrl.clear();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Komentar terkirim'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim komentar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking Tiket')),
      body: FutureBuilder<TicketDetailModel?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final detail = snapshot.data;
          if (detail == null) {
            return const Center(child: Text('Tiket tidak ditemukan'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(detail.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('ID: ${detail.id}'),
              Text('Kategori: ${detail.category}'),
              Text('Status: ${detail.status}'),
              Text('Dibuat: ${detail.createdAt}'),

              const Divider(height: 32),

              // BAGIAN 1: Riwayat Status -- terpisah dari komentar
              const Text('Riwayat Status',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (detail.statusHistory.isEmpty)
                const Text('Belum ada perubahan status')
              else
                ...detail.statusHistory.map((e) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.sync_alt, color: Colors.orange),
                  title: Text(e),
                )),

              const Divider(height: 32),

              // BAGIAN 2: Komentar -- terpisah dari riwayat status
              const Text('Komentar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (detail.timeline.isEmpty)
                const Text('Belum ada komentar')
              else
                ...detail.timeline.map((e) => ListTile(
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
              TextField(
                controller: _commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tulis komentar...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _sendComment,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Kirim Komentar'),
              ),
            ],
          );
        },
      ),
    );
  }
}