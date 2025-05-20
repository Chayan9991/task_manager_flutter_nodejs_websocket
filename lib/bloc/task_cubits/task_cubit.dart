import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:task_manager_flutter_nodejs/bloc/task_cubits/task_state.dart';
import 'package:task_manager_flutter_nodejs/model/task_model.dart';
import 'package:task_manager_flutter_nodejs/utils/api_constants.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskInitial());

  final String baseUrl = '${ApiConstants.baseUrl}/tasks';
  final String socketUrl = ApiConstants.socketUrl;
  IO.Socket? socket;
  String? _currentToken; // Store the token for socket re-initialization

  /// Initializes the socket connection and fetches tasks.
  /// This should be called once, typically from `_HomePageState.initState`.
  Future<void> initializeTasksAndSocket(String token) async {
    _currentToken = token; // Store the token
    await fetchTasks(token); // Fetch initial tasks first
    initSocket(token); // Then set up the socket
  }

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
      // The backend will emit 'task_updated' which will be handled by the socket listener
      await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );
      // No need to call fetchTasks here, socket will update the state
    } catch (e) {
      // Handle error, maybe emit a specific error state or show a snackbar
      print('Error creating task: $e');
      if (state is TaskLoaded) {
        emit(
          TaskError('Failed to create task: $e', (state as TaskLoaded).tasks),
        );
      } else {
        emit(TaskError('Failed to create task: $e', []));
      }
    }
  }

  Future<void> updateTask(Task task, String token) async {
    try {
      // The backend will emit 'task_updated' which will be handled by the socket listener
      await http.put(
        Uri.parse('$baseUrl/${task.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(task.toJson()),
      );
      // No need to call fetchTasks here, socket will update the state
    } catch (e) {
      // Handle error
      print('Error updating task: $e');
      if (state is TaskLoaded) {
        emit(
          TaskError('Failed to update task: $e', (state as TaskLoaded).tasks),
        );
      } else {
        emit(TaskError('Failed to update task: $e', []));
      }
    }
  }

  Future<void> deleteTask(String id, String token) async {
    try {
      // The backend will emit 'task_deleted' which will be handled by the socket listener
      await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      // No need to call fetchTasks here, socket will update the state
    } catch (e) {
      // Handle error
      print('Error deleting task: $e');
      if (state is TaskLoaded) {
        emit(
          TaskError('Failed to delete task: $e', (state as TaskLoaded).tasks),
        );
      } else {
        emit(TaskError('Failed to delete task: $e', []));
      }
    }
  }

  void initSocket(String token) {
    // Ensure only one socket connection is active
    if (socket != null && socket!.connected) {
      print('Socket already connected. Skipping re-initialization.');
      return;
    }

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer $token'},
      'autoConnect': true, // Auto-connect on init
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket!.onConnect((_) {
      print('Socket connected: ${socket!.id}');
    });

    socket!.on('task_updated', (data) {
      print('Received task_updated event: $data');
      try {
        final updatedTask = Task.fromJson(data);
        _updateTaskInList(updatedTask);
      } catch (e) {
        print('Error parsing updated task from socket: $e');
      }
    });

    socket!.on('task_deleted', (data) {
      print('Received task_deleted event: $data');
      // Backend emits `task._id` as a string for deletion
      String id;
      if (data is String) {
        id = data;
      } else {
        // Fallback for unexpected data format, log and ignore
        print('Unexpected data type for task_deleted, expected String: $data');
        return;
      }
      _removeTaskFromList(id);
    });

    socket!.on('disconnect', (_) {
      print('Socket disconnected');
      // Attempt to re-initialize socket on disconnect if a token exists
      if (_currentToken != null) {
        print('Attempting to re-initialize socket...');
        Future.delayed(const Duration(seconds: 2), () {
          initSocket(_currentToken!);
        });
      }
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
        // If task exists, update it
        currentTasks[index] = updatedTask;
      } else {
        // If task is new, add it
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
    socket?.dispose(); // Disposes of the socket connection
    return super.close();
  }
}
