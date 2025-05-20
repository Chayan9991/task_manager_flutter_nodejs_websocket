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

      // Fetch user info and tasks concurrently
      await Future.wait([
        context.read<UserCubit>().fetchUser(),
        context.read<TaskCubit>().initializeTasksAndSocket(
          token,
        ), //this is responsible for websocket init
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
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
    taskCubit.deleteTask(task.id, token);
  }

  void _showAddTaskModal({Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    TaskStatus selectedStatus = task?.status ?? TaskStatus.pending;
    String? titleError;
    String? descriptionError;

    bool validateInputs() {
      titleError =
          titleController.text.trim().isEmpty ? 'Title is required' : null;
      descriptionError =
          descriptionController.text.trim().isEmpty
              ? 'Description is required'
              : null;
      return titleError == null && descriptionError == null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task == null ? 'Add Task' : 'Edit Task',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green.shade400,
                            width: 2,
                          ),
                        ),
                        errorText: titleError,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green.shade400,
                            width: 2,
                          ),
                        ),
                        errorText: descriptionError,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskStatus>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green.shade400,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items:
                          TaskStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                Task.statusToString(status),
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                      onChanged: (status) {
                        if (status != null) {
                          setState(() {
                            selectedStatus = status;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        onPressed: () async {
                          setState(() {
                            validateInputs();
                          });
                          if (!validateInputs()) return;

                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('jwt_token');
                          final userState = context.read<UserCubit>().state;

                          if (token != null && userState is UserLoaded) {
                            final updatedTask = Task(
                              id: task?.id ?? '',
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              status: selectedStatus,
                              userId: userState.id,
                              createdAt: task?.createdAt ?? DateTime.now(),
                              updatedAt: DateTime.now(),
                            );

                            if (task == null) {
                              await context.read<TaskCubit>().createTask(
                                updatedTask,
                                token,
                              );
                            } else {
                              await context.read<TaskCubit>().updateTask(
                                updatedTask,
                                token,
                              );
                            }

                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Failed to authenticate. Please log in again.',
                                ),
                                backgroundColor: Colors.red.shade400,
                              ),
                            );
                          }
                        },
                        child: Text(
                          task == null ? 'Create Task' : 'Update Task',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
        title: Text(
          "Task Manager",
          style: TextStyle(
            color: Colors.green[400],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              String initials = '';
              String fullName = '';
              if (state is UserLoaded && state.name.isNotEmpty) {
                fullName = state.name;
                initials =
                    state.name
                        .trim()
                        .split(' ')
                        .map((word) => word[0])
                        .take(2)
                        .join()
                        .toUpperCase();
              }

              return Padding(
                padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width > 600 ? 32.0 : 16.0,
                ),
                child: PopupMenuButton<String>(
                  tooltip: "User Menu",
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  onSelected: (value) {
                    if (value == 'logout') _logout();
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem<String>(
                          enabled: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName.isNotEmpty ? fullName : 'User',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.green.shade400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Divider(),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.green.shade400),
                              const SizedBox(width: 10),
                              const Text("Logout"),
                            ],
                          ),
                        ),
                      ],
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green.shade400,
                    child: Text(
                      initials.isNotEmpty ? initials : '?',
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

                // --- IMPORTANT CHANGE HERE ---
                // Reverse the tasks list to display the last as first
                final reversedTasks = tasks.reversed.toList();

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
                      itemCount: reversedTasks.length,
                      itemBuilder: (context, index) {
                        final task = reversedTasks[index];
                        return TaskTile(
                          task: task,
                          username: task.userName ?? 'User',
                          currentUserId: currentUserId,
                          onEdit: () => _editTask(task),
                          onDelete:
                              () => _deleteTask(
                                task,
                                _token ?? '',
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
        backgroundColor: Colors.green.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
