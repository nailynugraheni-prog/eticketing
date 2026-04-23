import 'package:flutter/material.dart';
import '../../data/models/admin_ticket_model.dart';

class StaffTicketProvider extends ChangeNotifier {
  final List<AdminTicketModel> _tickets = [
    AdminTicketModel(
      id: 'TCK-001',
      title: 'Laptop tidak bisa connect WiFi',
      userName: 'Budi',
      priority: 'High',
      status: 'Open',
      createdAt: '2026-04-08',
    ),
    AdminTicketModel(
      id: 'TCK-002',
      title: 'Aplikasi crash saat login',
      userName: 'Ani',
      priority: 'Medium',
      status: 'In Progress',
      createdAt: '2026-04-08',
    ),
  ];

  List<AdminTicketModel> get tickets => List.unmodifiable(_tickets);

  AdminTicketModel getTicket(String id) {
    return _tickets.firstWhere((e) => e.id == id);
  }

  void addResponse(String ticketId, String response) {
    final index = _tickets.indexWhere((e) => e.id == ticketId);
    if (index == -1) return;
    _tickets[index] = _tickets[index].copyWith(
      actions: [..._tickets[index].actions, 'Response: $response'],
    );
    notifyListeners();
  }

  void updateStatus(String ticketId, String status) {
    final index = _tickets.indexWhere((e) => e.id == ticketId);
    if (index == -1) return;
    _tickets[index] = _tickets[index].copyWith(
      status: status,
      actions: [..._tickets[index].actions, 'Status changed to $status'],
    );
    notifyListeners();
  }

  void assignTicket(String ticketId, String assignee) {
    final index = _tickets.indexWhere((e) => e.id == ticketId);
    if (index == -1) return;
    _tickets[index] = _tickets[index].copyWith(
      actions: [..._tickets[index].actions, 'Assigned to $assignee'],
    );
    notifyListeners();
  }
}