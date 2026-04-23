import 'package:flutter/material.dart';
import '../../data/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'N-001',
      title: 'Tiket diperbarui',
      message: 'Status tiket TCK-001 berubah menjadi In Progress.',
      time: '10 menit lalu',
      isRead: false,
    ),
    NotificationModel(
      id: 'N-002',
      title: 'Balasan baru',
      message: 'Helpdesk membalas tiket TCK-002.',
      time: '1 jam lalu',
      isRead: false,
    ),
    NotificationModel(
      id: 'N-003',
      title: 'Tiket selesai',
      message: 'Tiket TCK-004 sudah ditutup.',
      time: 'Kemarin',
      isRead: true,
    ),
  ];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((e) => !e.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }
}