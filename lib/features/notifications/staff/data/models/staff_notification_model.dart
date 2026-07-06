class StaffNotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String? ticketId;

  StaffNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    this.ticketId,
  });

  factory StaffNotificationModel.fromMap(Map<String, dynamic> map) {
    return StaffNotificationModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      time: map['created_at']?.toString().split('T').first ?? '',
      isRead: map['is_read'] ?? false,
      ticketId: map['ticket_id']?.toString(),
    );
  }

  StaffNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? isRead,
    String? ticketId,
  }) {
    return StaffNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      ticketId: ticketId ?? this.ticketId,
    );
  }
}