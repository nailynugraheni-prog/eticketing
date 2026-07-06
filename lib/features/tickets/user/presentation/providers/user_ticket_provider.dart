import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/ticket_detail_model.dart';
import '../../data/repositories/user_ticket_repository.dart';

class UserTicketProvider extends ChangeNotifier {
  final _repo = UserTicketRepository();
  final ImagePicker _picker = ImagePicker();

  final List<TicketModel> _tickets = [];
  final List<XFile> _pendingAttachments = [];
  bool _isLoading = false;

  List<TicketModel> get tickets => List.unmodifiable(_tickets);
  List<XFile> get pendingAttachments => List.unmodifiable(_pendingAttachments);
  bool get isLoading => _isLoading;

  Future<void> loadMyTickets() async {
    _isLoading = true;
    notifyListeners();

    _tickets
      ..clear()
      ..addAll(await _repo.getMyTickets());

    _isLoading = false;
    notifyListeners();
  }

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

  Future<void> createTicket({
    required String title,
    required String category,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // FIX: sebelumnya return value dibuang, jadi kalau repository balik
      // null (misal user == null / session expired), provider tetap
      // lanjut seolah sukses. Sekarang di-cek dan di-throw kalau gagal,
      // supaya try-catch di halaman punya sesuatu untuk ditangkap.
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
      await loadMyTickets();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TicketDetailModel?> getDetail(String id) {
    return _repo.getDetail(id);
  }

  Future<void> addComment(String ticketId, String comment) async {
    await _repo.addComment(ticketCodeOrId: ticketId, message: comment);
    await loadMyTickets();
  }
}