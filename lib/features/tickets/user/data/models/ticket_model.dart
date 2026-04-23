class TicketModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String status;
  final String createdAt;
  final List<String> comments;

  TicketModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.comments = const [],
  });

  TicketModel copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? status,
    String? createdAt,
    List<String>? comments,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
    );
  }
}