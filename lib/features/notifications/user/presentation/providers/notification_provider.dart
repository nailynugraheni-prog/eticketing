import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final _repo = NotificationRepository();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  StreamSubscription<List<NotificationModel>>? _sub;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
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
        debugPrint('Notification stream error: $e');
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