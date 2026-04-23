class TicketActionModel {
  final String ticketId;
  final String actionType;
  final String note;

  TicketActionModel({
    required this.ticketId,
    required this.actionType,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'actionType': actionType,
      'note': note,
    };
  }
}