import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:task_manager_flutter_nodejs/bloc/task_cubits/task_state.dart';
import 'package:task_manager_flutter_nodejs/model/task_model.dart';
import 'package:task_manager_flutter_nodejs/utils/api_constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskInitial());

  final String baseUrl = '${ApiConstants.baseUrl}/tasks';
  final String socketUrl = ApiConstants.socketUrl;
  IO.Socket? socket;

  Future<void> fetchTasks(String token) async {
    emit(TaskLoading());
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final tasks = data.map((json) => Task.fromJson(json)).toList();

        emit(TaskLoaded(tasks));
      } else {
        emit(
          TaskError('Failed to load tasks with status ${response.statusCode}'),
        );
      }
    } catch (e) {
      emit(TaskError('Exception: $e'));
    }
  }

  Future<void> createTask(Task task, String token) async {
    try {
      final jsonBody = jsonEncode(task.toJson());
      print('Creating task with payload: $jsonBody');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTasks(token);
      } else {
        emit(TaskError('Failed to create task: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TaskError('Error: $e'));
    }
  }

  Future<void> updateTask(Task task, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${task.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTasks(token);
      } else {
        emit(TaskError('Failed to update task: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TaskError('Error: $e'));
    }
  }

  Future<void> deleteTask(String id, String token) async {
    try {
      print('Deleting task with id: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Task deleted successfully, fetching updated list...');
        await fetchTasks(token);
      } else {
        emit(TaskError('Failed to delete task: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TaskError('Error: $e'));
    }
  }

  void initSocket(String token) {
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer $token'},
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket!.on('connect', (_) {
      print('Socket connected: ${socket!.id}');
    });

    socket!.on('task_updated', (data) {
      try {
        final updatedTask = Task.fromJson(data);
        _updateTaskInList(updatedTask);
      } catch (e) {
        print('Error parsing updated task from socket: $e');
      }
    });

    socket!.on('task_deleted', (data) {
      // Depending on backend, data may be id string or object with id property
      String id;
      if (data is String) {
        id = data;
      } else if (data is Map && data['id'] != null) {
        id = data['id'];
      } else {
        print('Invalid data for task_deleted event: $data');
        return;
      }
      _removeTaskFromList(id);
    });

    socket!.on('disconnect', (_) {
      print('Socket disconnected');
    });

    socket!.on('connect_error', (error) {
      print('Socket connection error: $error');
    });
  }

  void _updateTaskInList(Task updatedTask) {
    if (state is TaskLoaded) {
      final currentTasks = List<Task>.from((state as TaskLoaded).tasks);
      final index = currentTasks.indexWhere((t) => t.id == updatedTask.id);
      if (index >= 0) {
        currentTasks[index] = updatedTask;
      } else {
        currentTasks.add(updatedTask);
      }
      emit(TaskLoaded(currentTasks));
    }
  }

  void _removeTaskFromList(String id) {
    if (state is TaskLoaded) {
      final currentTasks = List<Task>.from((state as TaskLoaded).tasks)
        ..removeWhere((t) => t.id == id);
      emit(TaskLoaded(currentTasks));
    }
  }

  @override
  Future<void> close() {
    socket?.dispose();
    return super.close();
  }
}
