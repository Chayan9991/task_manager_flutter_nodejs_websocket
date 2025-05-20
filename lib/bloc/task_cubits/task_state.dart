import 'package:task_manager_flutter_nodejs/model/task_model.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;

  TaskLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String message;
  final List<Task> tasks;

  TaskError(this.message, [this.tasks = const []]);
}