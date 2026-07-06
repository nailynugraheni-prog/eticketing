/// Satu baris komentar/balasan, dengan label jelas siapa penulisnya.
/// SAMA PERSIS dengan CommentEntry di ticket_detail_model.dart (user).
/// authorLabel contoh: "Anda", "Budi (Helpdesk)", "Siti (Admin)".
class StaffCommentEntry {
  final String authorLabel;
  final String message;
  final bool isMine;

  StaffCommentEntry({
    required this.authorLabel,
    required this.message,
    required this.isMine,
  });
}

class AdminTicketModel {
  final String id;
  final String title;
  final String userName;
  final String category;
  final String description;
  final String priority;
  final String status;
  final String createdAt;

  /// Timeline komentar + balasan, berlabel siapa penulisnya.
  /// SAMA PERSIS strukturnya dengan TicketDetailModel.timeline (user).
  /// Sebelumnya field ini bernama `actions` (List<String> polos), isinya
  /// gabungan status+komentar tanpa label penulis, dan tanpa kategori/
  /// deskripsi/lampiran sama sekali -- itu sebabnya UI staff selama ini
  /// tidak pernah sejajar dengan UI user.
  final List<StaffCommentEntry> timeline;

  /// Riwayat perubahan status, TERPISAH dari timeline komentar di atas.
  /// SAMA PERSIS dengan TicketDetailModel.statusHistory (user).
  final List<String> statusHistory;

  final List<String> attachmentUrls;

  AdminTicketModel({
    required this.id,
    required this.title,
    required this.userName,
    required this.category,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.timeline = const [],
    this.statusHistory = const [],
    this.attachmentUrls = const [],
  });

  AdminTicketModel copyWith({
    String? id,
    String? title,
    String? userName,
    String? category,
    String? description,
    String? priority,
    String? status,
    String? createdAt,
    List<StaffCommentEntry>? timeline,
    List<String>? statusHistory,
    List<String>? attachmentUrls,
  }) {
    return AdminTicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      userName: userName ?? this.userName,
      category: category ?? this.category,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      timeline: timeline ?? this.timeline,
      statusHistory: statusHistory ?? this.statusHistory,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
    );
  }
}