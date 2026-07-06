import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_ticket_model.dart';

class StaffTicketRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Satu-satunya tempat yang boleh menerjemahkan ticketCodeOrId.
  // Semua fungsi lain WAJIB lewat sini, tidak boleh bikin int.tryParse sendiri.
  Future<Map<String, dynamic>> _findTicket(
      String ticketCodeOrId, {
        String columns = 'id',
      }) async {
    final asInt = int.tryParse(ticketCodeOrId);
    final baseQuery = _supabase.from('tickets').select(columns);

    return asInt != null
        ? await baseQuery.eq('id', asInt).single()
        : await baseQuery.eq('ticket_code', ticketCodeOrId).single();
  }

  Future<List<Map<String, dynamic>>> getHelpdeskList() async {
    final data = await _supabase
        .from('profiles')
        .select('id, full_name, username')
        .eq('role', 'helpdesk');

    return List<Map<String, dynamic>>.from(data);
  }

  // List ringkas untuk Antrian Tiket, TIDAK query kategori/deskripsi/
  // lampiran/timeline -- itu semua cuma untuk halaman Detail (getTicket),
  // biar tidak jadi N+1 query yang boros untuk data yang tidak dipakai.
  //
  // filterByHelpdeskId BARU: dipakai admin untuk melihat tiket milik
  // helpdesk tertentu saja (FR-007.3 "Melihat semua tiket berdasarkan
  // helpdesk yang ditugaskan"). Ini TERPISAH dari filter role di bawah --
  // filter role menentukan "siapa yang login", filterByHelpdeskId
  // menentukan "helpdesk mana yang admin mau lihat". Kalau helpdesk yang
  // login mengirim ini, diabaikan (helpdesk sudah otomatis ke-filter oleh
  // baris assigned_to di bawah, tidak boleh melihat tiket helpdesk lain).
  Future<List<AdminTicketModel>> getAllTickets({
    required String role,
    String? filterByHelpdeskId,
  }) async {
    final user = _supabase.auth.currentUser;

    var query = _supabase
        .from('tickets')
        .select('''
        id,
        ticket_code,
        title,
        priority,
        status,
        created_at,
        profiles:user_id (
          full_name,
          username
        )
      ''');

    // Helpdesk cuma lihat tiket yang ditugaskan ke dia (FR-006.2)
    // Admin tetap lihat semua tiket masuk (FR-007.2), KECUALI admin
    // sedang memfilter berdasarkan helpdesk tertentu (FR-007.3) --
    // makanya kondisi kedua di bawah cuma berlaku untuk role == 'admin'.
    if (role == 'helpdesk' && user != null) {
      query = query.eq('assigned_to', user.id);
    } else if (role == 'admin' &&
        filterByHelpdeskId != null &&
        filterByHelpdeskId.isNotEmpty) {
      query = query.eq('assigned_to', filterByHelpdeskId);
    }

    final data = await query.order('created_at', ascending: false);

    return (data as List)
        .map((e) {
      final profile = e['profiles'];
      final userName = profile is Map
          ? (profile['full_name'] ?? profile['username'] ?? '-').toString()
          : '-';

      return AdminTicketModel(
        id: (e['ticket_code'] ?? 'TCK-${e['id']}').toString(),
        title: e['title'] ?? '',
        userName: userName,
        category: e['category'] ?? '',
        description: e['description'] ?? '',
        priority: e['priority'] ?? 'medium',
        status: e['status'] ?? 'open',
        createdAt: e['created_at']?.toString().split('T').first ?? '',
      );
    })
        .toList();
  }

  // REWRITE TOTAL: sekarang sejajar 1:1 dengan UserTicketRepository.getDetail().
  // Query kategori & deskripsi (sebelumnya tidak ada), join profiles ke
  // comments untuk label penulis (sebelumnya cuma "Response: xxx" generik
  // tanpa tau siapa penulisnya), dan statusHistory dipisah dari timeline
  // komentar (sebelumnya digabung jadi satu list `actions`).
  Future<AdminTicketModel?> getTicket(String ticketCodeOrId) async {
    final ticket = await _findTicket(
      ticketCodeOrId,
      columns: '''
        id,
        ticket_code,
        title,
        category,
        description,
        priority,
        status,
        created_at,
        assigned_to,
        profiles:user_id (
          full_name,
          username
        )
      ''',
    );

    final ticketId = ticket['id'];
    final currentUserId = _supabase.auth.currentUser?.id;

    // Join ke profiles, SAMA PERSIS seperti UserTicketRepository.getDetail(),
    // supaya staff juga bisa lihat siapa penulis tiap komentar/balasan.
    final comments = await _supabase
        .from('comments')
        .select('message, created_at, user_id, profiles:user_id(full_name, username, role)')
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

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

    final profile = ticket['profiles'];
    final userName = profile is Map
        ? (profile['full_name'] ?? profile['username'] ?? '-').toString()
        : '-';

    // Timeline berlabel, SAMA PERSIS strukturnya dengan versi user.
    final timeline = <StaffCommentEntry>[
      StaffCommentEntry(authorLabel: 'Sistem', message: 'Tiket dibuat', isMine: false),
      ...List<StaffCommentEntry>.from(
        (comments as List).map((e) {
          final isMine = e['user_id'] == currentUserId;
          final commentProfile = e['profiles'];

          String authorLabel;
          if (isMine) {
            authorLabel = 'Anda';
          } else if (commentProfile is Map) {
            final name = (commentProfile['full_name'] ?? commentProfile['username'] ?? 'Staff').toString();
            final role = commentProfile['role']?.toString();
            final roleLabel = role == 'admin'
                ? 'Admin'
                : role == 'helpdesk'
                ? 'Helpdesk'
                : role == 'user'
                ? null // komentar dari user pemilik tiket, tampilkan nama saja
                : null;
            authorLabel = roleLabel != null ? '$name ($roleLabel)' : name;
          } else {
            authorLabel = 'Staff';
          }

          return StaffCommentEntry(
            authorLabel: authorLabel,
            message: e['message']?.toString() ?? '',
            isMine: isMine,
          );
        }),
      ),
    ];

    // Riwayat status TERPISAH dari timeline komentar, sama seperti versi user.
    final statusHistory = List<String>.from(
      (tracking as List).map((e) {
        final oldStatus = e['old_status']?.toString();
        final newStatus = e['new_status']?.toString() ?? '-';
        return oldStatus == null
            ? 'Status ditetapkan: $newStatus'
            : 'Status: $oldStatus → $newStatus';
      }),
    );

    final attachmentUrls = List<String>.from(
      (attachments as List).map((e) => e['file_url']?.toString() ?? ''),
    ).where((url) => url.isNotEmpty).toList();

    return AdminTicketModel(
      id: (ticket['ticket_code'] ?? 'TCK-${ticket['id']}').toString(),
      title: ticket['title'] ?? '',
      userName: userName,
      category: ticket['category'] ?? '',
      description: ticket['description'] ?? '',
      priority: ticket['priority'] ?? 'medium',
      status: ticket['status'] ?? 'open',
      createdAt: ticket['created_at']?.toString().split('T').first ?? '',
      timeline: timeline,
      statusHistory: statusHistory,
      attachmentUrls: attachmentUrls,
    );
  }

  Future<void> addResponse({
    required String ticketCodeOrId,
    required String response,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final ticket = await _findTicket(ticketCodeOrId);

    await _supabase.from('comments').insert({
      'ticket_id': ticket['id'],
      'user_id': user.id,
      'message': response,
    });
  }

  Future<void> updateStatus({
    required String ticketCodeOrId,
    required String newStatus,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final ticket = await _findTicket(ticketCodeOrId, columns: 'id, status');

    await _supabase.from('tickets').update({
      'status': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', ticket['id']);

    await _supabase.from('ticket_tracking').insert({
      'ticket_id': ticket['id'],
      'old_status': ticket['status'],
      'new_status': newStatus,
      'changed_by': user.id,
    });
  }

  Future<void> assignTicket({
    required String ticketCodeOrId,
    required String assigneeUserId,
  }) async {
    final ticket = await _findTicket(ticketCodeOrId);

    await _supabase.from('tickets').update({
      'assigned_to': assigneeUserId,
      'status': 'assigned',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', ticket['id']);
  }

  /// Hapus banyak tiket sekaligus berdasarkan ticket_code (format "TCK-xxx",
  /// sesuai AdminTicketModel.id). Semua data terkait (comments, tracking,
  /// attachments) ikut terhapus otomatis lewat ON DELETE CASCADE di
  /// database -- lihat migrasi SQL yang menyertai fitur ini.
  ///
  /// RLS di tabel tickets membatasi DELETE hanya untuk role admin; kalau
  /// dipanggil oleh helpdesk, Postgres akan menolak dan Supabase melempar
  /// PostgrestException yang akan naik ke pemanggil sebagai exception.
  Future<void> deleteTickets(List<String> ticketCodes) async {
    if (ticketCodes.isEmpty) return;

    await _supabase
        .from('tickets')
        .delete()
        .inFilter('ticket_code', ticketCodes);
  }

  // ============================================================
  // BARU: staff (admin/helpdesk) membuat tiket atas nama dirinya sendiri.
  // SAMA PERSIS pola-nya dengan UserTicketRepository.createTicket():
  // insert ke tickets lalu upload lampiran satu per satu (gagal upload
  // 1 file tidak boleh membatalkan file lain / tiket yang sudah dibuat).
  //
  // user_id diisi dengan akun staff yang sedang login, karena kolom ini
  // NOT NULL + foreign key ke profiles. Artinya staff tercatat sebagai
  // pelapor sekaligus staff untuk tiket yang ia buat sendiri.
  // ============================================================
  Future<AdminTicketModel?> createTicket({
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
        .select('id, ticket_code, title, category, description, priority, status, created_at')
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

    // Ambil nama staff sendiri untuk field userName, karena staff yang
    // membuat tiket ini otomatis jadi "pelapor"-nya juga.
    final profile = await _supabase
        .from('profiles')
        .select('full_name, username')
        .eq('id', user.id)
        .maybeSingle();

    final userName = profile != null
        ? (profile['full_name'] ?? profile['username'] ?? '-').toString()
        : '-';

    return AdminTicketModel(
      id: (inserted['ticket_code'] ?? 'TCK-$ticketId').toString(),
      title: inserted['title'] ?? '',
      userName: userName,
      category: inserted['category'] ?? '',
      description: inserted['description'] ?? '',
      priority: inserted['priority'] ?? 'medium',
      status: inserted['status'] ?? 'open',
      createdAt: inserted['created_at']?.toString().split('T').first ?? '',
    );
  }

  /// SAMA PERSIS dengan UserTicketRepository._uploadAttachment().
  /// Diduplikasi (bukan di-share) karena kedua repository memang
  /// independen satu sama lain sesuai struktur folder tickets/staff
  /// vs tickets/user yang sudah ada.
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

    await _supabase.storage.from('ticket-attachments').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: 'image/$ext'),
    );

    final publicUrl =
    _supabase.storage.from('ticket-attachments').getPublicUrl(path);

    await _supabase.from('ticket_attachments').insert({
      'ticket_id': ticketId,
      'uploaded_by': userId,
      'file_url': publicUrl,
      'file_name': file.name,
      'file_type': 'image/$ext',
    });
  }
}