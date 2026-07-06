import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 5 kategori sesuai FR-009 SRS: Total, Open, Assign, In Progress, Closed.
/// "Closed" di sini adalah gabungan status resolved + closed di database,
/// bukan status closed saja -- sesuai keputusan yang sudah disepakati,
/// karena dari sisi user, tiket "resolved" dan "closed" sama-sama berarti
/// "sudah tidak butuh tindakan lagi".
class StaffDashboardProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  int _totalTickets = 0;
  int _openTickets = 0;
  int _assignedTickets = 0;
  int _inProgressTickets = 0;
  int _closedTickets = 0;
  bool _isLoading = false;

  int get totalTickets => _totalTickets;
  int get openTickets => _openTickets;
  int get assignedTickets => _assignedTickets;
  int get inProgressTickets => _inProgressTickets;
  int get closedTickets => _closedTickets;
  bool get isLoading => _isLoading;

  Future<void> loadStats({required String role}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;

      var query = _supabase.from('tickets').select('status');

      // Helpdesk cuma lihat statistik tiket yang ditugaskan ke dia (FR-006.7)
      // Admin tetap lihat semua tiket (FR-007.2)
      if (role == 'helpdesk' && user != null) {
        query = query.eq('assigned_to', user.id);
      }

      final data = await query;

      final list = data as List;
      _totalTickets = list.length;
      _openTickets = list.where((e) => e['status'] == 'open').length;
      _assignedTickets = list.where((e) => e['status'] == 'assigned').length;
      _inProgressTickets = list.where((e) => e['status'] == 'in_progress').length;
      _closedTickets = list.where((e) =>
      e['status'] == 'resolved' || e['status'] == 'closed').length;
    } catch (e) {
      debugPrint('Error load staff stats: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}