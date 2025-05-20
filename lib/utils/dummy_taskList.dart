import 'package:task_manager_flutter_nodejs/model/task_model.dart';

final dummyTasks = [
  Task(
    id: '682c4226fa42aa395ec00cef',
    title: 'Java Supremacy',
    description: 'Java is the OG language',
    status: TaskStatus.completed,
    userId: 'Tom Holland',
    createdAt: DateTime.parse('2025-05-20T08:49:42.948Z'),
    updatedAt: DateTime.parse('2025-05-20T08:49:42.948Z'),
  ),
  Task(
    id: '682c4226fa42aa395ec00cf0',
    title: 'Flutter Widgets',
    description: 'Learn how to build custom widgets in Flutter',
    status: TaskStatus.inProgress,
    userId: 'Json Statham',
    createdAt: DateTime.parse('2025-05-19T12:00:00.000Z'),
    updatedAt: DateTime.parse('2025-05-20T07:00:00.000Z'),
  ),
  Task(
    id: '682c4226fa42aa395ec00cf1',
    title: 'React Redux',
    description: 'Understand state management with Redux',
    status: TaskStatus.pending,
    userId: 'John Wick',
    createdAt: DateTime.parse('2025-05-18T09:30:00.000Z'),
    updatedAt: DateTime.parse('2025-05-18T09:30:00.000Z'),
  ),
  Task(
    id: '682c4226fa42aa395ec00cf2',
    title: 'Database Design',
    description: 'Create efficient database schema',
    status: TaskStatus.completed,
    userId: 'Adam Levine',
    createdAt: DateTime.parse('2025-05-17T15:45:00.000Z'),
    updatedAt: DateTime.parse('2025-05-19T10:20:00.000Z'),
  ),
  Task(
    id: '682c4226fa42aa395ec00cf3',
    title: 'API Integration',
    description: 'Integrate REST API with Flutter app',
    status: TaskStatus.inProgress,
    userId: 'Chayan Barman',
    createdAt: DateTime.parse('2025-05-20T06:00:00.000Z'),
    updatedAt: DateTime.parse('2025-05-20T08:00:00.000Z'),
  ),
];
