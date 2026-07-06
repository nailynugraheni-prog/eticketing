/// Satu baris komentar/balasan, dengan label jelas siapa penulisnya.
/// authorLabel contoh: "Anda", "Budi (Helpdesk)", "Siti (Admin)".
class CommentEntry {
  final String authorLabel;
  final String message;
  final bool isMine;

  CommentEntry({
    required this.authorLabel,
    required this.message,
    required this.isMine,
  });
}

class TicketDetailModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String status;
  final String createdAt;

  /// Timeline komentar + balasan staff, digabung berurutan waktu,
  /// masing-masing baris punya label penulis (lihat CommentEntry).
  /// Sebelumnya field ini List<String> polos tanpa info penulis, jadi
  /// komentar user dan balasan staff kelihatan identik di UI padahal
  /// keduanya sama-sama insert ke tabel comments dengan user_id berbeda.
  final List<CommentEntry> timeline;

  /// Riwayat perubahan status (dari tabel ticket_tracking), TERPISAH
  /// dari timeline komentar. Sebelumnya field ini tidak ada sama sekali,
  /// itu sebabnya "Timeline" di halaman lama cuma nampilin comments dan
  /// tidak pernah menunjukkan histori open -> assigned -> in_progress dst.
  final List<String> statusHistory;

  final List<String> attachmentUrls;

  TicketDetailModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.timeline,
    this.statusHistory = const [],
    this.attachmentUrls = const [],
  });
}