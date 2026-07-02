class Task {
  final String id;
  String title;
  String description;
  bool isDone;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isDone: json['isDone'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
