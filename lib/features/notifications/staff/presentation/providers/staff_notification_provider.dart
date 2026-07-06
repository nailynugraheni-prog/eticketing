import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/staff_notification_model.dart';
import '../../data/repositories/staff_notification_repository.dart';

class StaffNotificationProvider extends ChangeNotifier {
  final _repo = StaffNotificationRepository();

  List<StaffNotificationModel> _notifications = [];
  bool _isLoading = false;
  StreamSubscription<List<StaffNotificationModel>>? _sub;

  List<StaffNotificationModel> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((e) => !e.isRead).length;

  void startListening() {
    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _repo.watchMyNotifications().listen(
          (list) {
        _notifications = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e, st) {
        _isLoading = false;
        notifyListeners();
        debugPrint('Staff notification stream error: $e');
      },
    );
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}