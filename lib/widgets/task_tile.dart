import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:task_manager_flutter_nodejs/model/task_model.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final String username;
  final String currentUserId;
  final void Function() onEdit;
  final void Function() onDelete;

  const TaskTile({
    Key? key,
    required this.task,
    required this.username,
    required this.onEdit,
    required this.onDelete,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createdAt = task.createdAt;
    final updatedAt = task.updatedAt;

    final isUpdated = createdAt != updatedAt;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        timeago.format(updatedAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                
                  Text(task.description, style: const TextStyle(fontSize: 14)),

                  const SizedBox(height: 6),

                 
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              task.status == TaskStatus.completed
                                  ? Colors.green[300]
                                  : task.status == TaskStatus.inProgress
                                  ? Colors.orange[300]
                                  : Colors.red[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          Task.statusToString(task.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isUpdated)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'updated',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Right side: cog menu button (only if current user is owner)
          if (task.userId == currentUserId)
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings, color: Colors.grey),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
        ],
      ),
    );
  }
}
