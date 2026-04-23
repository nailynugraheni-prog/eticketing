import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/ticket_detail_model.dart';

class UserTicketProvider extends ChangeNotifier {
  final List<TicketModel> _tickets = [
    TicketModel(
      id: 'TCK-001',
      title: 'Laptop tidak bisa connect WiFi',
      category: 'Network',
      description: 'WiFi terdeteksi tapi tidak bisa connect',
      status: 'Open',
      createdAt: '2026-04-08',
      comments: ['Sudah dicoba restart'],
    ),
    TicketModel(
      id: 'TCK-002',
      title: 'Aplikasi crash saat login',
      category: 'Application',
      description: 'Aplikasi langsung close setelah login',
      status: 'In Progress',
      createdAt: '2026-04-08',
      comments: ['Masalah terjadi setelah update'],
    ),
  ];

  List<TicketModel> get tickets => List.unmodifiable(_tickets);

  TicketDetailModel getDetail(String id) {
    final ticket = _tickets.firstWhere((e) => e.id == id);
    return TicketDetailModel(
      id: ticket.id,
      title: ticket.title,
      category: ticket.category,
      description: ticket.description,
      status: ticket.status,
      createdAt: ticket.createdAt,
      timeline: [
        'Tiket dibuat',
        'Tiket diterima helpdesk',
        'Sedang diproses',
      ],
    );
  }

  void createTicket({
    required String title,
    required String category,
    required String description,
  }) {
    final newTicket = TicketModel(
      id: 'TCK-${(_tickets.length + 1).toString().padLeft(3, '0')}',
      title: title,
      category: category,
      description: description,
      status: 'Open',
      createdAt: DateTime.now().toIso8601String().split('T').first,
      comments: const [],
    );
    _tickets.insert(0, newTicket);
    notifyListeners();
  }

  void addComment(String ticketId, String comment) {
    final index = _tickets.indexWhere((e) => e.id == ticketId);
    if (index == -1) return;

    final ticket = _tickets[index];
    final updated = ticket.copyWith(
      comments: [...ticket.comments, comment],
    );
    _tickets[index] = updated;
    notifyListeners();
  }

  void updateStatus(String ticketId, String status) {
    final index = _tickets.indexWhere((e) => e.id == ticketId);
    if (index == -1) return;

    _tickets[index] = _tickets[index].copyWith(status: status);
    notifyListeners();
  }
}