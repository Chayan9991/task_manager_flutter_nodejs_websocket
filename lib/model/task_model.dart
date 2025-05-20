enum TaskStatus { pending, inProgress, completed }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final String? userId;
  final String? userName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.userId,
    this.userName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Safely extract user information
    String? extractedUserId;
    String? extractedUserName;

    final user = json['user'];
    if (user != null) {
      if (user is Map<String, dynamic>) {
        // Case 1: user is a populated object (e.g., from GET /tasks)
        extractedUserId = user['_id'] as String?;
        extractedUserName = user['name'] as String?;
      } else if (user is String) {
        extractedUserId = user;
      }
    }

    return Task(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: _statusFromString(json['status'] as String),
      userId: extractedUserId, // Use the safely extracted userId
      userName: extractedUserName, // Use the safely extracted userName
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