class AdminTicketModel {
  final String id;
  final String title;
  final String userName;
  final String priority;
  final String status;
  final String createdAt;
  final List<String> actions;

  AdminTicketModel({
    required this.id,
    required this.title,
    required this.userName,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.actions = const [],
  });

  AdminTicketModel copyWith({
    String? id,
    String? title,
    String? userName,
    String? priority,
    String? status,
    String? createdAt,
    List<String>? actions,
  }) {
    return AdminTicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      userName: userName ?? this.userName,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      actions: actions ?? this.actions,
    );
  }
}