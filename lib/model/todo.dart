import 'dart:convert';

class Todo {
  final String title;
  bool isCompleted;
  DateTime timestamp; // Add timestamp property

  Todo({
    required this.title,
    this.isCompleted = false,
    DateTime? timestamp, // Make timestamp optional
  }) : timestamp = timestamp ??
            DateTime.now(); // Initialize timestamp when creating a todo

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
