import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/admin_ticket_model.dart';
import '../../data/repositories/staff_ticket_repository.dart';

class StaffTicketProvider extends ChangeNotifier {
  final _repo = StaffTicketRepository();
  final ImagePicker _picker = ImagePicker();

  final List<AdminTicketModel> _tickets = [];
  final List<XFile> _pendingAttachments = [];
  List<Map<String, dynamic>> _helpdeskList = [];
  bool _isLoading = false;

  // BARU: menyimpan pilihan filter helpdesk yang sedang aktif (FR-007.3).
  // null berarti "tampilkan semua tiket" (perilaku default/lama).
  // Disimpan sebagai state (bukan cuma parameter sekali pakai) supaya
  // setiap aksi lain (assign, update status, delete, create) yang
  // memanggil ulang loadAllTickets() TIDAK diam-diam mereset filter ini.
  String? _filterHelpdeskId;

  List<AdminTicketModel> get tickets => List.unmodifiable(_tickets);
  List<XFile> get pendingAttachments => List.unmodifiable(_pendingAttachments);
  List<Map<String, dynamic>> get helpdeskList => _helpdeskList;
  bool get isLoading => _isLoading;
  String? get filterHelpdeskId => _filterHelpdeskId;

  /// role wajib selalu dikirim (dari mana pun halaman memanggil ini,
  /// AuthProvider tahu role yang sedang login).
  ///
  /// updateFilter + filterByHelpdeskId BEKERJA BERPASANGAN:
  /// - updateFilter: true  -> filter yang tersimpan DIGANTI dengan nilai
  ///   filterByHelpdeskId (termasuk diganti jadi null, saat admin memilih
  ///   "Semua Helpdesk" di dropdown untuk membersihkan filter).
  /// - updateFilter: false (default) -> filterByHelpdeskId diabaikan,
  ///   filter yang SUDAH tersimpan sebelumnya tetap dipakai apa adanya.
  ///   Ini dipakai oleh addResponse/updateStatus/assignTicket/
  ///   deleteTickets/createTicket di bawah, supaya refresh list setelah
  ///   sebuah aksi tidak diam-diam mereset filter yang admin sedang lihat.
  Future<void> loadAllTickets({
    required String role,
    String? filterByHelpdeskId,
    bool updateFilter = false,
  }) async {
    if (updateFilter) {
      _filterHelpdeskId = filterByHelpdeskId;
    }

    _isLoading = true;
    notifyListeners();

    _tickets
      ..clear()
      ..addAll(await _repo.getAllTickets(
        role: role,
        filterByHelpdeskId: _filterHelpdeskId,
      ));

    _helpdeskList = await _repo.getHelpdeskList();

    _isLoading = false;
    notifyListeners();
  }

  Future<AdminTicketModel?> getTicket(String id) {
    return _repo.getTicket(id);
  }

  Future<void> addResponse(String ticketId, String response, {required String role}) async {
    await _repo.addResponse(ticketCodeOrId: ticketId, response: response);
    await loadAllTickets(role: role);
  }

  Future<void> updateStatus(String ticketId, String status, {required String role}) async {
    await _repo.updateStatus(ticketCodeOrId: ticketId, newStatus: status);
    await loadAllTickets(role: role);
  }

  Future<void> assignTicket(String ticketId, String assigneeUserId, {required String role}) async {
    await _repo.assignTicket(
      ticketCodeOrId: ticketId,
      assigneeUserId: assigneeUserId,
    );
    await loadAllTickets(role: role);
  }

  /// Hapus banyak tiket sekaligus. Exception dari repository (misal RLS
  /// menolak karena bukan admin) DIBIARKAN merambat ke pemanggil (halaman),
  /// supaya try-catch di sana bisa menampilkan pesan gagal yang jelas --
  /// bukan "ditelan" diam-diam seperti bug lama di updateStatus staff.
  Future<void> deleteTickets(List<String> ticketCodes, {required String role}) async {
    await _repo.deleteTickets(ticketCodes);
    await loadAllTickets(role: role);
  }

  // ============================================================
  // BARU: fitur create ticket untuk staff.
  // Empat method di bawah (pickFromCamera, pickFromGallery,
  // removeAttachment, createTicket) SENGAJA disalin sejajar 1:1 dengan
  // UserTicketProvider, supaya CreateTicketPage bisa dipakai ulang oleh
  // staff tanpa perlu tahu provider mana yang sedang aktif di baliknya.
  // ============================================================

  Future<void> pickFromCamera() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (photo != null) {
      _pendingAttachments.add(photo);
      notifyListeners();
    }
  }

  Future<void> pickFromGallery() async {
    final photos = await _picker.pickMultiImage(imageQuality: 70);
    if (photos.isNotEmpty) {
      _pendingAttachments.addAll(photos);
      notifyListeners();
    }
  }

  void removeAttachment(int index) {
    if (index < 0 || index >= _pendingAttachments.length) return;
    _pendingAttachments.removeAt(index);
    notifyListeners();
  }

  /// role wajib dikirim supaya setelah tiket dibuat, list tiket staff
  /// (yang terfilter by role -- lihat getAllTickets di repository) ikut
  /// ter-refresh dan tiket baru langsung kelihatan di halaman antrian.
  Future<void> createTicket({
    required String title,
    required String category,
    required String description,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repo.createTicket(
        title: title,
        category: category,
        description: description,
        attachments: _pendingAttachments,
      );

      if (result == null) {
        throw Exception('Gagal membuat tiket. Silakan login ulang.');
      }

      _pendingAttachments.clear();
      await loadAllTickets(role: role);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}