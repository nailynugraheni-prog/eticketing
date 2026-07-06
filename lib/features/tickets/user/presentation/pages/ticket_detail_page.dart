import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/ticket_detail_model.dart';
import '../providers/user_ticket_provider.dart';

/// Halaman detail tiket, VIEW-ONLY. Tidak ada kolom komentar di sini --
/// untuk kirim komentar, user perlu masuk lewat Tracking Tiket
/// (lihat ticket_tracking_detail_page.dart).
class TicketDetailPage extends StatefulWidget {
  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  late Future<TicketDetailModel?> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = context.read<UserTicketProvider>().getDetail(widget.ticketId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
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
              const SizedBox(height: 16),
              const Text('Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(detail.description),

              if (detail.attachmentUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Lampiran (${detail.attachmentUrls.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: detail.attachmentUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final url = detail.attachmentUrls[index];
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
              if (detail.timeline.isEmpty)
                const Text('Belum ada aktivitas')
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

              // Catatan: TIDAK ADA lagi bagian "Tambah Komentar" di halaman
              // ini. Untuk kirim komentar, arahkan user ke Tracking Tiket
              // -> TicketTrackingDetailPage.
            ],
          );
        },
      ),
    );
  }
}