import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';
import '../models/ticket_detail_model.dart';

class UserTicketRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _attachmentBucket = 'ticket-attachments';

  Future<List<TicketModel>> getMyTickets() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final data = await _supabase
        .from('tickets')
        .select('id, ticket_code, title, category, description, status, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (data as List).map((e) => TicketModel(
      id: (e['ticket_code'] ?? 'TCK-${e['id']}').toString(),
      title: e['title'] ?? '',
      category: e['category'] ?? '',
      description: e['description'] ?? '',
      status: e['status'] ?? 'open',
      createdAt: e['created_at']?.toString().split('T').first ?? '',
      comments: const [],
    )).toList();
  }

  /// Bikin tiket, lalu upload tiap lampiran dan link ke ticket_attachments.
  /// Kalau ada 1 file gagal upload, file lain tetap dicoba (nggak saling block).
  Future<TicketModel?> createTicket({
    required String title,
    required String category,
    required String description,
    String priority = 'medium',
    List<XFile> attachments = const [],
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final inserted = await _supabase
        .from('tickets')
        .insert({
      'user_id': user.id,
      'title': title,
      'category': category,
      'description': description,
      'priority': priority,
      'status': 'open',
    })
        .select('id, ticket_code, title, category, description, status, created_at')
        .single();

    final ticketId = inserted['id'] as int;

    for (var i = 0; i < attachments.length; i++) {
      try {
        await _uploadAttachment(
          ticketId: ticketId,
          userId: user.id,
          file: attachments[i],
          index: i,
        );
      } catch (e) {
        debugPrint('uploadAttachment error for ${attachments[i].name}: $e');
      }
    }

    return TicketModel(
      id: (inserted['ticket_code'] ?? 'TCK-$ticketId').toString(),
      title: inserted['title'] ?? '',
      category: inserted['category'] ?? '',
      description: inserted['description'] ?? '',
      status: inserted['status'] ?? 'open',
      createdAt: inserted['created_at']?.toString().split('T').first ?? '',
      comments: const [],
    );
  }

  Future<void> _uploadAttachment({
    required int ticketId,
    required String userId,
    required XFile file,
    required int index,
  }) async {
    final bytes = await file.readAsBytes();
    final ext = (file.name.contains('.') ? file.name.split('.').last : 'jpg')
        .toLowerCase();
    final safeName = '${DateTime.now().millisecondsSinceEpoch}_$index.$ext';
    final path = '$ticketId/$safeName';

    await _supabase.storage.from(_attachmentBucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: 'image/$ext'),
    );

    final publicUrl =
    _supabase.storage.from(_attachmentBucket).getPublicUrl(path);

    await _supabase.from('ticket_attachments').insert({
      'ticket_id': ticketId,
      'uploaded_by': userId,
      'file_url': publicUrl,
      'file_name': file.name,
      'file_type': 'image/$ext',
    });
  }

  Future<TicketDetailModel?> getDetail(String ticketCodeOrId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final asInt = int.tryParse(ticketCodeOrId);

      final baseQuery = _supabase
          .from('tickets')
          .select('id, ticket_code, title, category, description, status, created_at');

      final ticket = asInt != null
          ? await baseQuery.eq('id', asInt).maybeSingle()
          : await baseQuery.eq('ticket_code', ticketCodeOrId).maybeSingle();

      if (ticket == null) return null;

      final ticketId = ticket['id'];

      final currentUserId = user.id;

      // Join ke profiles untuk tau siapa penulis tiap komentar (nama + role).
      // Sebelumnya query ini cuma ambil message & created_at, jadi komentar
      // dari USER dan balasan dari STAFF tampil identik tanpa label penulis.
      final comments = await _supabase
          .from('comments')
          .select('message, created_at, user_id, profiles:user_id(full_name, username, role)')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      // BARU: query riwayat perubahan status, terpisah dari comments.
      // Sebelumnya query ini tidak ada sama sekali, itu sebabnya
      // "Timeline" hanya menunjukkan comments dan status tiket saat ini,
      // tidak pernah menunjukkan riwayat open -> assigned -> in_progress dst.
      final tracking = await _supabase
          .from('ticket_tracking')
          .select('old_status, new_status, created_at')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      final attachments = await _supabase
          .from('ticket_attachments')
          .select('file_url')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      final timeline = <CommentEntry>[
        CommentEntry(authorLabel: 'Sistem', message: 'Tiket dibuat', isMine: false),
        ...List<CommentEntry>.from(
          (comments as List).map((e) {
            final isMine = e['user_id'] == currentUserId;
            final profile = e['profiles'];

            String authorLabel;
            if (isMine) {
              authorLabel = 'Anda';
            } else if (profile is Map) {
              final name = (profile['full_name'] ?? profile['username'] ?? 'Staff').toString();
              final role = profile['role']?.toString();
              final roleLabel = role == 'admin'
                  ? 'Admin'
                  : role == 'helpdesk'
                  ? 'Helpdesk'
                  : null;
              authorLabel = roleLabel != null ? '$name ($roleLabel)' : name;
            } else {
              authorLabel = 'Staff';
            }

            return CommentEntry(
              authorLabel: authorLabel,
              message: e['message']?.toString() ?? '',
              isMine: isMine,
            );
          }),
        ),
      ];

      // Riwayat status TERPISAH dari timeline komentar di atas.
      final statusHistory = List<String>.from(
        (tracking as List).map((e) {
          final oldStatus = e['old_status']?.toString();
          final newStatus = e['new_status']?.toString() ?? '-';
          // baris pertama tracking biasanya old_status null (dari default
          // 'open' saat insert), tampilkan lebih ramah daripada "null -> assigned"
          return oldStatus == null
              ? 'Status ditetapkan: $newStatus'
              : 'Status: $oldStatus → $newStatus';
        }),
      );

      final attachmentUrls = List<String>.from(
        (attachments as List).map((e) => e['file_url']?.toString() ?? ''),
      ).where((url) => url.isNotEmpty).toList();

      return TicketDetailModel(
        id: (ticket['ticket_code'] ?? 'TCK-${ticket['id']}').toString(),
        title: ticket['title'] ?? '',
        category: ticket['category'] ?? '',
        description: ticket['description'] ?? '',
        status: ticket['status'] ?? 'open',
        createdAt: ticket['created_at']?.toString().split('T').first ?? '',
        timeline: timeline,
        statusHistory: statusHistory,
        attachmentUrls: attachmentUrls,
      );
    } catch (e) {
      debugPrint('getDetail error: $e');
      return null;
    }
  }

  Future<void> addComment({
    required String ticketCodeOrId,
    required String message,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // FIX: sebelumnya pakai .or('ticket_code.eq.X,id.eq.X') yang mencoba
    // menyamakan string "TCK-000018" ke KEDUA kolom sekaligus, termasuk
    // kolom id yang bertipe bigint -> Postgres gagal cast dan melempar
    // "invalid input syntax for type bigint". Sekarang pakai pola yang
    // sama seperti getDetail(): cek dulu apakah ini angka murni, baru
    // pilih SATU kolom yang sesuai.
    final asInt = int.tryParse(ticketCodeOrId);
    final baseQuery = _supabase.from('tickets').select('id');

    final ticket = asInt != null
        ? await baseQuery.eq('id', asInt).maybeSingle()
        : await baseQuery.eq('ticket_code', ticketCodeOrId).maybeSingle();

    if (ticket == null) return;

    await _supabase.from('comments').insert({
      'ticket_id': ticket['id'],
      'user_id': user.id,
      'message': message,
    });
  }
}