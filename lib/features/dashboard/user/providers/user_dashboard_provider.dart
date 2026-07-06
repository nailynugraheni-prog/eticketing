import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 5 kategori sesuai FR-009 SRS, sama seperti StaffDashboardProvider,
/// hanya berbeda di filter: user cuma lihat statistik tiketnya sendiri.
/// Sebelumnya provider ini cuma punya 3 kategori (Terbuka/Proses/Selesai),
/// sekarang disamakan jadi 5 agar konsisten dengan dashboard staff.
class UserDashboardProvider extends ChangeNotifier {
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

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('tickets')
          .select('status')
          .eq('user_id', user.id);

      final list = data as List;
      _totalTickets = list.length;
      _openTickets = list.where((e) => e['status'] == 'open').length;
      _assignedTickets = list.where((e) => e['status'] == 'assigned').length;
      _inProgressTickets = list.where((e) => e['status'] == 'in_progress').length;
      _closedTickets = list.where((e) =>
      e['status'] == 'resolved' || e['status'] == 'closed').length;
    } catch (e) {
      debugPrint('Error load user stats: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}