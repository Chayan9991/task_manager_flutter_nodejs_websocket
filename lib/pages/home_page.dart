import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_flutter_nodejs/bloc/user_cubits/user_cubit.dart';
import 'package:task_manager_flutter_nodejs/bloc/user_cubits/user_state.dart';
import 'package:task_manager_flutter_nodejs/bloc/task_cubits/task_cubit.dart';
import 'package:task_manager_flutter_nodejs/bloc/task_cubits/task_state.dart';
import 'package:task_manager_flutter_nodejs/model/task_model.dart';
import 'package:task_manager_flutter_nodejs/widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchData();
  }

  Future<void> _loadTokenAndFetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      setState(() {
        _token = token;
      });

      // Fetch user info
      context.read<UserCubit>().fetchUser();

      // Fetch tasks
      await context.read<TaskCubit>().fetchTasks(token);

      // Get current state of TaskCubit
      final taskState = context.read<TaskCubit>().state;
      if (taskState is TaskLoaded) {
        for (var task in taskState.tasks) {
          print('Fetched Task: ${task.title} (ID: ${task.id})');
        }
      }
    } catch (e) {
      print('Error fetching data in HomePage: $e');
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _editTask(Task task) {
    _showAddTaskModal(task: task);
  }

  void _deleteTask(Task task, String token, TaskCubit taskCubit) {
    print('Delete task: ${task.title}');
    taskCubit.deleteTask(task.id, token);
  }

  void _showAddTaskModal({Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    TaskStatus selectedStatus = task?.status ?? TaskStatus.pending;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task == null ? 'Add Task' : 'Edit Task',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items:
                    TaskStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(Task.statusToString(status)),
                      );
                    }).toList(),
                onChanged: (status) {
                  if (status != null) selectedStatus = status;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('jwt_token');
                  final userState = context.read<UserCubit>().state;

                  if (token != null && userState is UserLoaded) {
                    final updatedTask = Task(
                      id: task?.id ?? '',
                      title: titleController.text,
                      description: descriptionController.text,
                      status: selectedStatus,
                      userId: userState.id,
                      createdAt: task?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    if (task == null) {
                      // Create new task
                      await context.read<TaskCubit>().createTask(
                        updatedTask,
                        token,
                      );
                    } else {
                      // Update existing task
                      await context.read<TaskCubit>().updateTask(
                        updatedTask,
                        token,
                      );
                    }

                    Navigator.of(context).pop();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    task == null ? "Create Task" : "Update Task",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.grey.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: const Text(
          "Task Manager",
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              String name = '';
              if (state is UserLoaded && state.name.isNotEmpty) {
                name = state.name.substring(0, 2).toUpperCase();
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: PopupMenuButton<String>(
                  tooltip: "User Menu",
                  onSelected: (value) {
                    if (value == 'logout') _logout();
                  },
                  itemBuilder:
                      (context) => const [
                        PopupMenuItem(value: 'logout', child: Text('Logout')),
                      ],
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            final tasks = state.tasks;

            if (tasks.isEmpty) {
              return const Center(child: Text('No tasks found.'));
            }

            return BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                String currentUserId = '';
                String username = '';

                if (userState is UserLoaded) {
                  currentUserId = userState.id;
                  username = userState.name;
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width > 600 ? 200 : 24,
                    vertical: 32,
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('jwt_token');
                      if (token != null) {
                        await context.read<TaskCubit>().fetchTasks(token);
                      }
                    },
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final taskOwnerId = task.userId ?? '';
                        return TaskTile(
                          task: task,
                          username:
                              taskOwnerId == currentUserId ? username : 'User',
                          currentUserId: currentUserId,
                          onEdit: () => _editTask(task),
                          onDelete:
                              () => _deleteTask(
                                task,
                                _token!,
                                context.read<TaskCubit>(),
                              ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          } else if (state is TaskError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No tasks loaded.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskModal,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
