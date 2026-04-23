class TicketDetailModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String status;
  final String createdAt;
  final List<String> timeline;

  TicketDetailModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.timeline,
  });
}