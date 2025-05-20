enum TaskStatus { pending, inProgress, completed }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: _statusFromString(json['status'] as String),
      userId: json['user'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': statusToString(status),
      'user': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static TaskStatus _statusFromString(String status) {
    switch (status) {
      case 'Pending':
        return TaskStatus.pending;
      case 'In Progress':
        return TaskStatus.inProgress;
      case 'Completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }

  static String statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}
